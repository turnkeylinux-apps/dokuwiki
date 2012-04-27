#!/usr/bin/python
"""Set Dokuwiki admin password and email

Option:
    --pass=     unless provided, will ask interactively
    --email=    unless provided, will ask interactively

"""

import re
import sys
import getopt
import hashlib

from dialog_wrapper import Dialog

def usage(s=None):
    if s:
        print >> sys.stderr, "Error:", s
    print >> sys.stderr, "Syntax: %s [options]" % sys.argv[0]
    print >> sys.stderr, __doc__
    sys.exit(1)

def main():
    try:
        opts, args = getopt.gnu_getopt(sys.argv[1:], "h",
                                       ['help', 'pass=', 'email='])
    except getopt.GetoptError, e:
        usage(e)

    password = ""
    email = ""
    for opt, val in opts:
        if opt in ('-h', '--help'):
            usage()
        elif opt == '--pass':
            password = val
        elif opt == '--email':
            email = val

    if not password:
        d = Dialog('TurnKey Linux - First boot configuration')
        password = d.get_password(
            "DokuWiki Password",
            "Enter new password for the DokuWiki 'admin' account.")

    if not email:
        if 'd' not in locals():
            d = Dialog('TurnKey Linux - First boot configuration')

        email = d.get_email(
            "DokuWiki Email",
            "Enter email address for the DokuWiki 'admin' account.",
            "admin@example.com")
    
    authfile = "/var/lib/dokuwiki/acl/users.auth.php"
    hashpass = hashlib.md5(password).hexdigest()

    new = []
    for line in file(authfile).readlines():
        line = line.strip()
        if not line:
            continue

        username, password, name, mailaddr, groups = line.split(":")
        if username == "admin":
            password = hashpass
            mailaddr = email

        new.append(":".join([username, password, name, mailaddr, groups]))

    fh = file(authfile, "w")
    print >> fh, "\n".join(new)
    fh.close()

if __name__ == "__main__":
    main()

