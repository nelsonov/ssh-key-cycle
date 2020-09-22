#!/usr/local/bin/bash

usage() { echo "$0 usage:" && grep " .)\ #" $0; exit 0; }
[ $# -eq 0 ] && usage
while getopts ":?d:c:h:t:" arg; do
  case $arg in
      d) # domain suffix (ie .somewhere.com or .local.somewhere.com)
      DOMAIN=${OPTARG}
      ;;
      c) # path for ca private key
      CA_ARG=${OPTARG}
      ;;
      h) # hostname of machine to create keys for
      KEYHOST=${OPTARG}
      ;;
      t) # key type (rsa, ecdsa, ed25519)
      TYPE=${OPTARG}
      ;;
      ? | *) # Display help.
	  usage
	  exit 1
	  ;;
  esac
done

IDENTITY="$KEYHOST"     #string to use as identity in cert

[[ -d $KEYHOST ]] || mkdir $KEYHOST

OWD=`pwd`
cd $KEYHOST

REVOKED=revoked_keys
OPTIONS=

if [ "${TYPE}X" = "X" ]; then
    TYPE=rsa
fi

IDENTITY=${KEYHOST}.${DOMAIN}

if [ $TYPE = "ALL" ]; then
    TYPELIST="rsa ecdsa ed25519"
else
    TYPELIST=$TYPE
fi

for THISTYPE in $TYPELIST
do
    CA=${CA_ARG}/ca_${THISTYPE}
    PRIVATE=ssh_host_${THISTYPE}_key
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
    ssh-keygen $OPTIONS -t $THISTYPE -N '' -f $PRIVATE

    ###Add public key (if exists) to revoked keys
    if [ -f $PUBLIC ]; then
	echo "Found $PUBLIC"
	cat $PUBLIC >> $REVOKED
    fi

    ####Sign public key
    ssh-keygen -h -s $CA -I $IDENTITY $PUBLIC
done
cd $OWD
