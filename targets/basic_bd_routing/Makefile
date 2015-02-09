################################################################
#
# Makefile for basic_routing P4 project
#
################################################################

export TARGET_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

include ../../init.mk

# This target's P4 name
export P4_INPUT := p4src/basic_bd_routing.p4
export P4_NAME := basic_bd_routing

# Common defines targets for P4 programs
COMMON_DIR := ${ROOT}/targets/common
include ${COMMON_DIR}/common.mk

# Put custom targets in basic_routing-local.mk
-include basic_routing-local.mk

