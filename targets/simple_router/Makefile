################################################################
#
# Makefile for simple_router P4 project
#
################################################################

export TARGET_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

include ../../init.mk

# This target's P4 name
export P4_INPUT := p4src/simple_router.p4
export P4_NAME := simple_router

# Common defines targets for P4 programs
COMMON_DIR := ${ROOT}/targets/common
include ${COMMON_DIR}/common.mk

# Put custom targets in simple_router-local.mk
-include simple_router-local.mk

