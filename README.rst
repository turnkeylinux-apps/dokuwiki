DokuWiki - Documentation Wiki Platform
======================================

`DokuWiki`_ is wiki software aimed at small companies documentation
needs. It works on plain text files and thus needs no database. It has a
simple but powerful syntax (similar to the one used by MediaWiki) which
makes sure the data files remain readable outside the wiki and eases the
creation of structured texts.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

- Dokuwiki configurations:
   
   - Installed from upstream source code to /var/www/dokuwiki.
   - Created admin user and group.
   - Granted authenticated users with upload privileges.
   - Fixed permissions for Configuration Manager plugin.
   - Clean URLs out of the box.

   **Security note**: Updates to DokuWiki may require supervision so they
   **ARE NOT** configured to install automatically. See DokuWiki
   documentation for how to upgrade, either `manually`_, or via the
   `upgrade plugin`_.

- SSL support out of the box.
- Postfix MTA (bound to localhost) to allow sending of email (e.g.,
  password recovery).
- Webmin modules for configuring Apache2, PHP and Postfix.


Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, Webshell, SSH, MySQL: username **root**
-  Dokuwiki: username **admin**

.. _DokuWiki: http://www.dokuwiki.org
.. _TurnKey Core: https://www.turnkeylinux.org/core
.. _manually: https://www.dokuwiki.org/install:upgrade
.. _upgrade plugin: https://www.dokuwiki.org/plugin:upgrade
