#################################################################
#
# Makefile for the Lions Gate Behavioral Model target
#
# DO NOT EDIT: See below.
#
# This file is kept in targets/common and copied to the P4
# specific target directory when make is invoked. You can edit
# this version, but note that all changes will be applied to 
# all P4 program targets.
#
#################################################################

ifndef P4_NAME
$(error behavioral.mk needs P4_NAME defined)
endif

ifndef TARGET_ROOT
$(error behavioral.mk needs TARGET_ROOT defined)
endif

LIBRARY := lg_pd_main
$(LIBRARY)_SUBDIR := $(TARGET_ROOT)

include ../../init.mk

MODULE := lg_pd
include $(BUILDER)/standardinit.mk

include $(BUILDER)/lib.mk

DEPENDMODULES := OS murmur indigo BigList AIM timer_wheel uCli IOF
DEPENDMODULES += SocketManager VPI cjson Configuration ELS
DEPENDMODULES += bfns_common common ${P4_NAME}_sim lg_utils # pd_thrift

# Allow customizations to enable l2l3 and netlink
-include $(TARGET_ROOT)/${P4_NAME}-custom.mk

include $(BUILDER)/dependmodules.mk

BINARY := ${P4_NAME}

$(BINARY)_LIBRARIES := $(LIBRARY_TARGETS) 
include $(BUILDER)/bin.mk

include $(BUILDER)/targets.mk

# These indicate Linux specific implementations to be used for
# various features
GLOBAL_CFLAGS += -DINDIGO_LINUX_LOGGING
GLOBAL_CFLAGS += -DINDIGO_LINUX_TIME
GLOBAL_CFLAGS += -DINDIGO_FAULT_ON_ASSERT
GLOBAL_CFLAGS += -DINDIGO_MEM_STDLIB
GLOBAL_CFLAGS += -DAIM_CONFIG_INCLUDE_MODULES_INIT=1
GLOBAL_CFLAGS += -DAIM_CONFIG_INCLUDE_MAIN=1
GLOBAL_CFLAGS += -DNO_LOCI_TYPES
GLOBAL_CFLAGS += -DLIBPCAP_USE_FIX
GLOBAL_CFLAGS += -DDEBUG
# uCli support for modules
#GLOBAL_CFLAGS += -DUCLI_CONFIG_INCLUDE_FGETS_LOOP=1
GLOBAL_CFLAGS += -DUCLI_CONFIG_INCLUDE_ELS_LOOP=1
GLOBAL_CFLAGS += -DCOMMON_CONFIG_INCLUDE_UCLI=1
GLOBAL_CFLAGS += -DLG_UTILS_CONFIG_INCLUDE_UCLI=1
GLOBAL_CFLAGS += -DSOCKET_MANAGER_CONFIG_INCLUDE_UCLI=1
GLOBAL_CFLAGS += -DVPI_CONFIG_INCLUDE_UCLI=1
GLOBAL_CFLAGS += -DP4RMT_CONFIG_INCLUDE_UCLI=1
GLOBAL_CFLAGS += -DPD_THRIFT_CONFIG_INCLUDE_UCLI=1
GLOBAL_CFLAGS += -DCONFIGURATION_CONFIG_INCLUDE_UCLI=1
GLOBAL_CFLAGS += -DLIBL2L3_CONFIG_INCLUDE_UCLI=1

# Turn this on to use VPI over TCP
ifdef USE_VPI_TCP
GLOBAL_CFLAGS += -DUSE_VPI_TCP
endif

# GLOBAL_CFLAGS += -DAIM_CONFIG_INCLUDE_VALGRIND=1

ifdef BEHAVIORAL_OUTPUT_STATS
P4RMT_FLAGS += -DP4RMT_OUTPUT_STATS
endif

GLOBAL_CFLAGS += ${P4RMT_FLAGS}
# @FIXME
GLOBAL_CFLAGS += -Wno-sign-compare -Wno-unused-parameter -Wno-type-limits

GLOBAL_CFLAGS += -g
# GLOBAL_CFLAGS += -flto -O3

GXX_PEDANTIC_FLAGS += --std=c++11

GLOBAL_LINK_LIBS += -lpthread -lpcap -ledit -lm -Wl,-rpath=. -lthrift -lJudy
GLOBAL_LINK_LIBS += -lhiredis

ifdef BEHAVIORAL_OUTPUT_STATS
# this library is needed for packet event logging in a non-SQL WhiteDB 
GLOBAL_LINK_LIBS += -lwgdb
endif
