DokuWiki permissions and updates
================================

DokuWiki 19.0 uses Debian's package layout. APT owns the application code in
``/usr/share/dokuwiki`` and the web server cannot modify it. Local
configuration is stored in ``/etc/dokuwiki``. Wiki pages, media, indexes and
authentication files are stored under ``/var/lib/dokuwiki`` with only the
state needed by the application writable by ``www-data``.

Use the standard Debian update path for DokuWiki itself:

.. code-block:: bash

    apt update
    apt install --only-upgrade dokuwiki

Back up ``/etc/dokuwiki`` and ``/var/lib/dokuwiki`` before a major upgrade or
permission customization.
