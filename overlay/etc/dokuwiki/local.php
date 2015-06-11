<?php
$conf['title'] = 'TurnKey DokuWiki';

$conf['useacl'] = 1;
$conf['superuser'] = '@admin';
$conf['passcrypt']      = 'md5';
$conf['mailfrom']       = 'admin@example.com';

#$conf['license'] = 'cc-by-sa';
$conf['lang'] = 'en';

$conf['userewrite']     = 1;  //use .htaccess to provide clean-urls
$conf['updatecheck']    = 0;  //managed by apt package manager
?>

