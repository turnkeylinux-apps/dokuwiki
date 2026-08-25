DokuWiki - Documentation Wiki Platform
======================================

`DokuWiki`_ is wiki software aimed at small companies documentation
needs. It works on plain text files and thus needs no database. It has a
simple but powerful syntax (similar to the one used by MediaWiki) which
makes sure the data files remain readable outside the wiki and eases the
creation of structured texts.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

- DokuWiki configurations:
   
   - Installed from the Debian Trixie package. Application code is in
     ``/usr/share/dokuwiki``, configuration is in ``/etc/dokuwiki`` and wiki
     data is in ``/var/lib/dokuwiki``.
   - Created admin user and group.
   - Granted authenticated users with upload privileges.
   - Clean URLs out of the box.

   DokuWiki security updates are delivered through the signed Debian package
   repositories. Application code remains managed by APT while wiki content
   and local configuration remain persistent.

- SSL support out of the box.
- Postfix MTA (bound to localhost) to allow sending of email (e.g.,
  password recovery).
- Webmin modules for configuring Apache2, PHP and Postfix.


Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH: username **root**
-  DokuWiki: username **admin**

.. _DokuWiki: http://www.dokuwiki.org
.. _TurnKey Core: https://www.turnkeylinux.org/core
