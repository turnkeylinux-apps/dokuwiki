COMMON_CONF = apache-credit apache-vhost
COMMON_OVERLAYS = apache

CREDIT_ANCHORTEXT = DokuWiki Appliance
CREDIT_LOCATION = ~ "^/(?!(lib))"

include $(FAB_PATH)/common/mk/turnkey/php.mk
include $(FAB_PATH)/common/mk/turnkey.mk
