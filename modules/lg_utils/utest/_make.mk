###############################################################################
#
# lg_utils Unit Test Makefile.
#
###############################################################################
UMODULE := lg_utils
UMODULE_SUBDIR := $(dir $(lastword $(MAKEFILE_LIST)))
include $(BUILDER)/utest.mk
