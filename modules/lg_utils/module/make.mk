###############################################################################
#
# 
#
###############################################################################
THIS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
lg_utils_INCLUDES := -I $(THIS_DIR)inc -I $(THIS_DIR)/inc/lg_utils
lg_utils_INTERNAL_INCLUDES := -I $(THIS_DIR)src
lg_utils_DEPENDMODULE_ENTRIES := init:lg_utils ucli:lg_utils

