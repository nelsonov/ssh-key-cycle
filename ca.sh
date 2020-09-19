#!/usr/local/bin/bash

usage() { echo "$0 usage:" && grep " .)\ #" $0; exit 0; }
[ $# -eq 0 ] && usage
while getopts ":?p:c:u:h:t:" arg; do
  case $arg in
      c) # path/prefix for ca private key
      CA=${OPTARG}
      ;;
      u) # user identifier (ie email)
      IDENTITY=${OPTARG}
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

if [ "${TYPE}X" = "X" ]; then
    TYPE=rsa
fi

CA=${CA}_${TYPE}
PUBLIC=${CA}.pub
REVOKED=revoked_keys

if [ $TYPE = "rsa" ]; then
    OPTIONS="-b 4096"
elif [ $TYPE = "ed25519" ]; then
    OPTIONS="-a 100"
else
    echo "Unknown key type: $TYPE"
    exit 1
fi

####Generate new key pair
ssh-keygen -t $TYPE $OPTIONS -N '' -C "$IDENTITY" -f $CA

###Add public key (if exists) to revoked keys
if [ -f $PUBLIC ]; then
    echo "Found $PUBLIC"
    cat $PUBLIC >> $REVOKED
fi

exit 0
