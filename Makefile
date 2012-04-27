COMMON_CONF = postfix-local apache-credit apache-vhost

CREDIT_ANCHORTEXT = DokuWiki Appliance
CREDIT_LOCATION = ~ "^/(?!(lib))"

include $(FAB_PATH)/common/mk/turnkey/php.mk
include $(FAB_PATH)/common/mk/turnkey.mk
