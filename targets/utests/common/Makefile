###############################################################################
#
# 
#
###############################################################################

include ../../../init.mk
MODULE := common_utest
TEST_MODULE := common
BUILDER_EXCLUDE_SETCAP = 1
DEPENDMODULES := AIM SocketManager VPI BigList OS indigo cjson \
  Configuration timer_wheel
GLOBAL_CFLAGS += -DINDIGO_LINUX_LOGGING
GLOBAL_CFLAGS += -DINDIGO_LINUX_TIME
GLOBAL_CFLAGS += -DINDIGO_FAULT_ON_ASSERT
GLOBAL_CFLAGS += -DINDIGO_MEM_STDLIB
GLOBAL_CFLAGS += -DAIM_CONFIG_INCLUDE_MODULES_INIT=1
GLOBAL_CFLAGS += -DAIM_CONFIG_INCLUDE_MAIN=1
GLOBAL_CFLAGS += -DNO_LOCI_TYPES=1
GLOBAL_LINK_LIBS += -lpthread -lcrafter -lpcap
GXX_PEDANTIC_FLAGS += --std=c++11
include $(BUILDER)/build-unit-test.mk
