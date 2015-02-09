include ../../init.mk

MODULE := bfns_ctl
include $(BUILDER)/standardinit.mk

LIBRARY := bfns_ctl_main
$(LIBRARY)_SUBDIR := $(dir $(lastword $(MAKEFILE_LIST)))
include $(BUILDER)/lib.mk

DEPENDMODULES += bfns_common AIM
include $(BUILDER)/dependmodules.mk

BINARY := bfns-ctl
$(BINARY)_LIBRARIES := $(LIBRARY_TARGETS)
include $(BUILDER)/bin.mk
include $(BUILDER)/targets.mk

GLOBAL_CFLAGS += -g
GLOBAL_CFLAGS += -I .
GLOBAL_CFLAGS += -O1

LIBNL_CFLAGS :=

LIBNL_LIBS := -lhiredis

GLOBAL_CFLAGS += $(LIBNL_CFLAGS)
GLOBAL_LINK_LIBS += $(LIBNL_LIBS)

install: all
	mv build/gcc-local/bin/${BINARY} .
