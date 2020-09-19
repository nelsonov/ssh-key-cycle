#!/usr/local/bin/bash

usage() { echo "$0 usage:" && grep " .)\ #" $0; exit 0; }
[ $# -eq 0 ] && usage
while getopts ":?p:c:u:h:t:" arg; do
  case $arg in
      p) # path/prefix for user private key
      PRIVATE=${OPTARG}
      ;;
      c) # path/prefix for ca private key
      CA=${OPTARG}
      ;;
      u) # user to list as principal in cert
      KEYUSER=${OPTARG}
      ;;
      h) # hostname of machine to create keys for
      KEYHOST=${OPTARG}
      ;;
      t) # key type (rsa, ed25519)
      TYPE=${OPTARG}
      ;;
      ? | *) # Display help.
	  usage
	  exit 1
	  ;;
  esac
done

IDENTITY="$KEYUSER@$KEYHOST"     #string to use as identity in cert

[[ -d $KEYHOST ]] || mkdir $KEYHOST

OWD=`pwd`
cd $KEYHOST

REVOKED=revoked_keys
OPTIONS=

if [ "${TYPE}X" = "X" ]; then
    TYPE=rsa
fi

CA=${CA}_${TYPE}
PRIVATE=${PRIVATE}_${TYPE}
PUBLIC=${PRIVATE}.pub
CERT=${PRIVATE}-cert.pub

if [ $TYPE = "rsa" ]; then
    OPTIONS="-b 4096"
elif [ $TYPE = "ed25519" ]; then
    OPTIONS="-a 100"
else
    echo "Unknown key type: $TYPE"
    exit 1
fi

####Generate new key pair
ssh-keygen $OPTIONS -t $TYPE -C "$IDENTITY" -f $PRIVATE

###Add public key (if exists) to revoked keys
if [ -f $PUBLIC ]; then
    echo "Found $PUBLIC"
    cat $PUBLIC >> $REVOKED
fi

####Sign public key
ssh-keygen -s $CA -n $KEYUSER -I $IDENTITY $PUBLIC

cd $OWD
