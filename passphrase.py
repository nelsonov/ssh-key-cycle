#!/usr/bin/env python3
##
## Usage: eval $(./passphrase.py)
##

import getpass

passwd=getpass.getpass(prompt='Passphrase: ')

print("export KEYCYCLEPASS=\"{}\"".format(passwd))
