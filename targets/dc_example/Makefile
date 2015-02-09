################################################################
#
# Makefile for dc_example P4 project
#
################################################################

export TARGET_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

include ../../init.mk

# This target's P4 name
export P4_INPUT := p4src/dc_example.p4
export P4_NAME := dc_example

# Common defines targets for P4 programs
COMMON_DIR := ${ROOT}/targets/common
include ${COMMON_DIR}/common.mk

# Put custom targets in dc_example-local.mk
-include dc_example-local.mk

