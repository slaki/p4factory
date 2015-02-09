###############################################################################
#
# 
#
###############################################################################
THIS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
bfns_common_INCLUDES := -I $(THIS_DIR)inc
bfns_common_INTERNAL_INCLUDES := -I $(THIS_DIR)src
bfns_common_DEPENDMODULE_ENTRIES := init:bfns_common ucli:bfns_common

