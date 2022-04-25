#!/usr/bin/python3
"""Set Dokuwiki admin password and email

Option:
    --pass=     unless provided, will ask interactively
    --email=    unless provided, will ask interactively

"""

import re
import sys
import getopt
from libinithooks import inithooks_cache
from subprocess import check_output

from libinithooks.dialog_wrapper import Dialog

def usage(s=None):
    if s:
        print("Error:", s, file=sys.stderr)
    print("Syntax: %s [options]" % sys.argv[0], file=sys.stderr)
    print(__doc__, file=sys.stderr)
    sys.exit(1)

def genpasswd(password):
    return check_output(['openssl', 'passwd', '-1', password],
            encoding='utf8').rstrip()
    

def main():
    try:
        opts, args = getopt.gnu_getopt(sys.argv[1:], "h",
                                       ['help', 'pass=', 'email='])
    except getopt.GetoptError as e:
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

    inithooks_cache.write('APP_EMAIL', email)
    
    authfile = "/var/www/dokuwiki/conf/users.auth.php"
    hashpass = genpasswd(password)

    lines = []
    with open(authfile, 'r') as fob:
        for line in fob:
            line = line.strip()
            if not line or line.count(":") < 4:
                lines.append(line)
                continue

            username, password, name, mailaddr, groups = line.split(":")
            if username == "admin":
                password = hashpass
                mailaddr = email

            lines.append(":".join([username, password, name, mailaddr, groups]))

    with open(authfile, 'w') as fob:
        fob.write('\n'.join(lines))

if __name__ == "__main__":
    main()

