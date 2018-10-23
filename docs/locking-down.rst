Locking Down DokuWiki
=====================

As of v15.1 the turnkeylinux dokuwiki appliance comes shipped with the upgrade plugin
(http://www.dokuwiki.org/plugin:upgraded) by Andreas Gohr to streamline dokuwiki
upgrades. Because of this the permissions on the webroot of dokuwiki have been loosened.

These instructions show you how to lock the permissions back down although remember
this will disable the functionality of the dokuwiki upgrade plugin
(and possibly plugins in general).


.. code-block:: bash

    cd /var/www/dokuwiki

    chown -R root:root . # disable access to everything
    chown www-data:www-data ./lib # enable access to lib directory
    chown -R www-data:www-data ./data # enable access to data directory (where pages are stored)
    chown -R www-data:www-data ./conf # enable access to conf directory

    # this will enable some plugins although anything which requires write access outside
    # of it's installation directory will not work due to the permissions we've set
    chown www-data:www-data ./lib/plugins # enable access to plugins directory


To re-loosen permissions do the following:

.. code-block:: bash

    cd /var/www/dokuwiki

    chown -R www-data:www-data . # enable access to everything
