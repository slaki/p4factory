###############################################################################
#
# 
#
###############################################################################

include ../../../init.mk
MODULE := bfns_common_utest
TEST_MODULE := bfns_common
DEPENDMODULES := AIM
GLOBAL_CFLAGS += -DAIM_CONFIG_INCLUDE_MODULES_INIT=1
GLOBAL_CFLAGS += -DAIM_CONFIG_INCLUDE_MAIN=1
include $(BUILDER)/build-unit-test.mk
