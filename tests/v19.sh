#!/bin/bash
set -Eeuo pipefail
umask 077

result=${TKL_TEST_RESULT:?TKL_TEST_RESULT is required}
app_password=${TKL_TEST_APP_PASS:?TKL_TEST_APP_PASS is required}
base=https://127.0.0.1
cookie=/tmp/tkl-dokuwiki-cookie.$$
page=/tmp/tkl-dokuwiki-page.$$
headers=/tmp/tkl-dokuwiki-headers.$$
edit=/tmp/tkl-dokuwiki-edit.$$
policy=/tmp/tkl-dokuwiki-policy.$$

report_error() {
    printf 'test_failure line=%s status=%s command=%q\n' \
        "$1" "$2" "$3" >&2
    exit "$2"
}

cleanup() {
    rm -f -- "$cookie" "$page" "$headers" "$edit" "$policy"
}
trap 'report_error "$LINENO" "$?" "$BASH_COMMAND"' ERR
trap cleanup EXIT

systemctl --quiet is-active apache2.service postfix.service multi-user.target
systemctl --quiet is-enabled apache2.service postfix.service
apache2ctl -t
apache2ctl -M 2>/dev/null | grep -q ' rewrite_module '
grep -Fxq 'VERSION_CODENAME=trixie' /etc/os-release
grep -Eq '^turnkey-dokuwiki-19\.0' /etc/turnkey_version

dokuwiki_version=$(dpkg-query -W -f='${Version}' dokuwiki)
[[ $dokuwiki_version == 2024-02-06b+dfsg-9* ]]
grep -Fxq '2024-02-06b "Kaos"' /usr/share/dokuwiki/VERSION
dpkg-query -S /usr/share/dokuwiki/doku.php | grep -q '^dokuwiki:'
stat -c '%U:%G %a' /usr/share/dokuwiki/doku.php | grep -Fxq 'root:root 644'
stat -c '%U:%G %a' /var/lib/dokuwiki/data | grep -Fxq 'www-data:root 700'
grep -Fq "\$conf['title'] = 'TurnKey Linux DokuWiki';" \
    /etc/dokuwiki/local.php
grep -Fq "\$conf['userewrite'] = 1;" /etc/dokuwiki/local.php
grep -Eq '^\* +@ALL +4$' /var/lib/dokuwiki/acl/acl.auth.php
grep -Eq '^\* +@user +8$' /var/lib/dokuwiki/acl/acl.auth.php
grep -Eq '^admin:[^:]+:admin:admin@example\.invalid:admin,user$' \
    /var/lib/dokuwiki/acl/users.auth.php

php_version=$(php --version | head -n 1)
[[ $php_version == 'PHP 8.4.'* ]]
for module in dom gd intl mbstring xml; do
    php -m | grep -Fxiq "$module"
done

curl --insecure --fail --silent --show-error \
    --cookie-jar "$cookie" "$base/start?do=login" >"$page"
grep -Fq 'TurnKey Linux DokuWiki' "$page"
grep -Fq 'id="dw__login"' "$page"

curl --insecure --silent --show-error \
    --cookie "$cookie" --cookie-jar "$cookie" \
    --data-urlencode id=start --data-urlencode do=login \
    --data-urlencode u=admin --data-urlencode "p=$app_password" \
    --dump-header "$headers" --output "$page" "$base/start"
grep -q '^HTTP/.* 302' "$headers"
curl --insecure --fail --silent --show-error \
    --cookie "$cookie" "$base/start" >"$page"
grep -Fq 'Logged in as:' "$page"
grep -Fq '<bdi>admin</bdi>' "$page"
grep -Fq 'title="Log Out"' "$page"

page_id="turnkey-v19-acceptance-$$"
marker="DokuWiki web edit round trip $$"
wiki_text=$(printf '====== TurnKey v19 acceptance ======\n\n%s\n' "$marker")
curl --insecure --fail --silent --show-error \
    --cookie "$cookie" "$base/$page_id?do=edit" >"$edit"
sectok=$(sed -n 's/.*name="sectok" value="\([^"]*\)".*/\1/p' "$edit" |
    head -n 1)
changecheck=$(sed -n 's/.*name="changecheck" value="\([^"]*\)".*/\1/p' "$edit" |
    head -n 1)
[[ -n $sectok && -n $changecheck ]]
curl --insecure --silent --show-error \
    --cookie "$cookie" --cookie-jar "$cookie" \
    --data-urlencode "sectok=$sectok" \
    --data-urlencode "id=$page_id" \
    --data-urlencode rev=0 --data-urlencode date= \
    --data-urlencode prefix=. --data-urlencode suffix= \
    --data-urlencode "changecheck=$changecheck" \
    --data-urlencode target=section \
    --data-urlencode "wikitext=$wiki_text" \
    --data-urlencode 'summary=TurnKey v19 acceptance' \
    --data-urlencode 'do[save]=1' \
    --dump-header "$headers" --output "$page" \
    "$base/$page_id?do=edit"
grep -q '^HTTP/.* 302' "$headers"
curl --insecure --fail --silent --show-error \
    --cookie "$cookie" "$base/$page_id" >"$page"
grep -Fq 'TurnKey v19 acceptance' "$page"
grep -Fq "$marker" "$page"
grep -Fq "$marker" "/var/lib/dokuwiki/data/pages/$page_id.txt"

systemctl restart apache2.service
curl --insecure --fail --silent --show-error \
    --cookie "$cookie" "$base/$page_id" >"$page"
grep -Fq "$marker" "$page"

test -x /etc/cron.daily/dokuwiki
dpkg-query -W webmin-apache webmin-phpini postfix >/dev/null
curl --insecure --fail --silent --show-error --head \
    https://127.0.0.1:12321/ >/dev/null

before="$dokuwiki_version|$(dpkg-query -W -f='${Version}' apache2)|$(dpkg-query -W -f='${Version}' php-cli)"
apt-get update >/dev/null
for package in dokuwiki apache2 php-cli; do
    apt-cache policy "$package" >"$policy"
    candidate=$(awk '/Candidate:/ {print $2}' "$policy")
    [[ -n $candidate && $candidate != '(none)' ]]
    grep -Eq 'trixie|deb13' "$policy"
done
after="$(dpkg-query -W -f='${Version}' dokuwiki)|$(dpkg-query -W -f='${Version}' apache2)|$(dpkg-query -W -f='${Version}' php-cli)"
[[ $after == "$before" ]]
grep -Rqs '^Suites: trixie' /etc/apt/sources.list.d
! grep -Rqi bookworm /etc/apt/sources.list /etc/apt/sources.list.d

cat >"$result" <<EOF
package_source=Debian 13 Trixie APT repositories for DokuWiki, PHP 8.4 and Apache
installed_version=dokuwiki $dokuwiki_version; $php_version; apache2 $(dpkg-query -W -f='${Version}' apache2)
runtime_checks=normal init; Apache and Postfix supervision; firstboot admin HTTPS login; clean URL rendering; authenticated wiki page create-read round trip; plain-text persistence and Apache restart; Debian split code, configuration and state permissions; Webmin HTTPS endpoint
updater_command=apt-get update; apt install --only-upgrade dokuwiki
updater_result=signed Debian metadata refreshed; eligible DokuWiki, Apache and PHP candidates found; installed packages remained unchanged
updater_channel=Debian Trixie and Trixie security APT repositories
integrity_evidence=dpkg owns the immutable DokuWiki application code; APT accepted signed Trixie metadata; no Bookworm source remained
EOF
