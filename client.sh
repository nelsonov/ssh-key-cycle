#!/usr/local/bin/bash

usage() {
    echo
    echo "$0 usage:" && grep " .)\ #" $0
    echo "Will prompt for passphrase unless environment varaible:"
    echo "KEYCYCLEPASS"
    echo "is set to the desired passphrase."
    echo "To do this without leaving the passphrase in history,"
    echo "see passphrase.py"
    exit 0
}
[ $# -eq 0 ] && usage
while getopts ":?p:c:u:h:t:n:" arg; do
  case $arg in
      p) # path/prefix for user private key
      OPT_PRIVATE=${OPTARG}
      ;;
      c) # path/prefix for ca private key
      OPT_CA=${OPTARG}
      ;;
      u) # user to list as principal in cert
      KEYUSER=${OPTARG}
      ;;
      h) # hostname of machine to create keys for
      KEYHOST=${OPTARG}
      ;;
      n) # optional EXTRA principals. Ex: -n "bob,fred,phil"
      PRINCIPALS=${OPTARG}
      ;;
      t) # key type (ALL, rsa, ecdsa, ed25519).  Ex: -t "ecdsa ed25519"
      TYPE=${OPTARG}
      ;;
      ? | *) # Display help.
	  usage
	  exit 1
	  ;;
  esac
done

set history off

IDENTITY="$KEYUSER@$KEYHOST"     #string to use as identity in cert

if [ "${PRINCIPALS}X" = "X" ]; then
    PRINCIPALS=$KEYUSER
else
    PRINCIPALS="${KEYUSER},${PRINCIPALS}"
fi

[[ -d $KEYHOST ]] || mkdir $KEYHOST

OWD=`pwd`
cd $KEYHOST

REVOKED=revoked_keys
OPTIONS=

if [ "${TYPE}X" = "X" ]; then
    TYPE=rsa
fi

if [ "${KEYCYCLEPASS}X" = "X" ]; then
    PASS=""
else
    PASS=$(echo -e "-N '${KEYCYCLEPASS}'")
fi

if [ $TYPE = "ALL" ]; then
    TYPELIST="rsa ecdsa ed25519"
else
    TYPELIST=$TYPE
fi

for THISTYPE in $TYPELIST
do
    CA=${OPT_CA}_${THISTYPE}
    PRIVATE=${OPT_PRIVATE}_${THISTYPE}
    PUBLIC=${PRIVATE}.pub
    CERT=${PRIVATE}-cert.pub

    if [ $THISTYPE = "rsa" ]; then
	OPTIONS="-b 4096"
    elif [ $THISTYPE = "ecdsa" ]; then
	OPTIONS="-b 384"
    elif [ $THISTYPE = "ed25519" ]; then
	OPTIONS="-a 100"
    else
	echo "Unknown key type: $THISTYPE"
	exit 1
    fi

    ####Generate new key pair
    echo sh -c "echo \"y\" | ssh-keygen $OPTIONS -t $THISTYPE -C \"$IDENTITY\" -f $PRIVATE $PASS"
    sh -c "echo \"y\" | ssh-keygen $OPTIONS -t $THISTYPE -C \"$IDENTITY\" -f $PRIVATE $PASS"

    ###Add public key (if exists) to revoked keys
    if [ -f $PUBLIC ]; then
	echo "Found $PUBLIC"
	cat $PUBLIC >> $REVOKED
    fi

    ####Sign public key
    echo ssh-keygen -s $CA -n $PRINCIPALS -I $IDENTITY $PUBLIC
    ssh-keygen -s $CA -n $PRINCIPALS -I $IDENTITY $PUBLIC
done
cd $OWD


