#!/usr/local/bin/bash

PUBLIC=id_rsa.pub
CERT=id_rsa-cert.pub
REVOKED=revoked-keys
APPEND=
SIZE=4096
TYPE=rsa

###Check for revoked keys file
if [ -f $REVOKED ]; then
    APPEND=-u
fi

###Revoke key
if [ -f $PUBLIC ]; then
    ssh-keygen -k -f $REVOKED $APPEND $PUBILC
fi

####Revoke key
#if [ -f $CERT ]; then
#    ssh-keygen -k -f $REVOKED $APPEND $CERT
#fi


