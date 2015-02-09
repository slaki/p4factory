###############################################################################
#
# bfns_common Unit Test Makefile.
#
###############################################################################
UMODULE := bfns_common
UMODULE_SUBDIR := $(dir $(lastword $(MAKEFILE_LIST)))
include $(BUILDER)/utest.mk
