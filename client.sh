#!/usr/local/bin/bash

PRIVATE=$1      #path/filename for user private key
CA=$2           #path/filename for ca private key
USERNAME=$3     #user to list as principal in cert
IDENTITY=$4     #string to use as identity in cert

PUBLIC=${PRIVATE}.pub
CERT=${PRIVATE}-cert.pub
REVOKED=revoked-keys
APPEND=
SIZE=4096
TYPE=rsa

###Check for revoked keys file
if [ -f $REVOKED ]; then
    echo "Found $REVOKED"
    APPEND=-u
fi

###Add public key (if exists) to revoked keys
if [ -f $PUBLIC ]; then
    echo "Found $PUBLIC"
    ssh-keygen -k -f $REVOKED $APPEND $PUBLIC
fi

####Add cert (if exists) to revoked keys
if [ -f $CERT ]; then
    echo "Found $CERT"
    ssh-keygen -k -f $REVOKED $APPEND $CERT
fi

####Generate new key pair
ssh-keygen -b 4096 -t rsa -f $PRIVATE

####Sign public key
ssh-keygen -s $CA -n $USERNAME -I $IDENTITY $PUBLIC

