#################################################################
#
# Common makefile fragment for P4 projects
#
# DO NOT EDIT: See below.
#
# This file is kept in targets/common and copied to the P4
# specific target directory when make is invoked. You can edit
# this version, but note that all changes will be applied to 
# all P4 program targets.
#
#################################################################

################################################################
#
# Assumes the following are defined:
#    TARGET_ROOT: The directory for the target
#    COMMON_DIR: The common include directory
#    P4_INPUT: The input file for P4 processing
#    P4_NAME: The name of the P4 project
#
################################################################

ifndef TOOLCHAIN
TOOLCHAIN := gcc-local
endif

ifndef P4_INPUT
$(error common.mk needs P4_INPUT defined)
endif

ifndef P4_NAME
$(error common.mk needs P4_NAME defined)
endif

ifndef COMMON_DIR
$(error common.mk needs COMMON_DIR defined)
endif

ifndef TARGET_ROOT
$(error common.mk needs TARGET_ROOT defined)
endif

ifndef ROOT
$(error common.mk needs ROOT defined)
endif

# Check if p4-validate is installed (indicating glass-hlir is)
P4_VALIDATE=$(shell which p4-validate)
ifeq (,${P4_VALIDATE})
$(error You need to install glass-hlir; try 'make -f ../common/install-hlir.mk')
endif


################################################################
#
# PRIMARY TARGETS
#
################################################################

all: behavioral-model p4-graphs

BEHAVIORAL_MK := ${COMMON_DIR}/behavioral.mk

# The behavioral model executable

lg lionsgate behavioral ${P4_NAME}: behavioral-model

behavioral-model: .lgsim_ts .thrift_ts main.c thrift_python
	@echo Building ${P4_NAME} behavioral simulation
	@$(MAKE) -f ${BEHAVIORAL_MK}
	@cp build/$(TOOLCHAIN)/bin/${P4_NAME} ./behavioral-model

# Grab common main.c
main.c: ${COMMON_DIR}/main.c
	@cp $< $@


################################################################
# Graphs
################################################################

ifndef P4C_GRAPHS
P4C_GRAPHS := ${SUBMODULE_P4C_GRAPHS}/p4c_dot/shell.py
endif
ALL_TMP_DIRS += graphs

p4-graphs: ${P4_INPUT} graphs
	@echo Create ${P4_NAME} graphs
	@${P4C_GRAPHS} ${P4_INPUT} --gen-dir=graphs
# Post process dot files?


################################################################
#
# Supporting targets
#
################################################################

################################################################
# Glass and thrift code to generate the source for the Behavioral Simulation
################################################################

# The module with the source for the P4-specific behavioral simulation
LGSIM_MODULE_PATH := ${ROOT}/modules/${P4_NAME}_sim

# Behavioral model auto-gen code destination
LGSIM_SRC_INSTALL_PATH := ${LGSIM_MODULE_PATH}/module/src

# Public header files go in the special subdirectory of this module
LGSIM_HEADER_INSTALL_PATH := ${LGSIM_MODULE_PATH}/module/inc/p4_sim

# This is cheating a bit for now; not creating a full pd_thrift module
PD_HEADER_INSTALL_PATH := ${LGSIM_MODULE_PATH}/module/inc/pd_thrift
PD_SRC_INSTALL_PATH := ${LGSIM_MODULE_PATH}/module/src

P4C_WORKING_DIR := build/p4c_lg_working_dir
P4C_TABLE_WORKING_DIR = build/p4c_table_output
ALL_TMP_DIRS += ${P4C_WORKING_DIR}

# pd.h, pre.h, pd_static.h and rmt.h and mirroring.h are public headers; 
# others are private.
LGSIM_PUBLIC_HEADERS = $(addprefix ${P4C_WORKING_DIR}/inc/, pd.h pd_static.h rmt.h mirroring.h pre.h)

# Behavioral compiler; default is to use the one in local submodule
ifndef P4C_BEHAVIORAL
P4C_BEHAVIORAL := ${SUBMODULE_P4C_BEHAVIORAL}/p4c_lg/shell.py
endif

P4C_LG_PARAMS := --gen-dir=${P4C_WORKING_DIR} --thrift --public-inc-path=p4_sim/

# Where thrift is built
THRIFT_BUILD_DIR := build/thrift
ALL_TMP_DIRS += ${THRIFT_BUILD_DIR}

THRIFT_PYTHON_DIR := ${TARGET_ROOT}/of-tests/pd_thrift
ALL_TMP_DIRS += ${THRIFT_PYTHON_DIR}

# How to create a new module in BigCode/Infra
NEW_MOD_SCRIPT := ${ROOT}/tools/newmodule.py
NEW_MOD_PARAMS := ${P4_NAME}_sim "Sim code for ${P4_NAME}" > /dev/null

# Glass converts the P4 program to C files for behavioral model
# This target also ensures the module directory is properly set up
.lgsim_ts: ${P4_INPUT} ${P4C_WORKING_DIR} ${THRIFT_BUILD_DIR}
	@echo "Recreating behavioral sim module"
	@rm -rf ${LGSIM_MODULE_PATH}
	@python ${NEW_MOD_SCRIPT} ${NEW_MOD_PARAMS}
	@mkdir -p ${LGSIM_HEADER_INSTALL_PATH}
	@mkdir -p ${PD_HEADER_INSTALL_PATH}
	@echo "Create C files from P4 source with p4c_lg"
	@${P4C_BEHAVIORAL} ${P4_INPUT} ${P4C_LG_PARAMS}
	@cp ${P4C_WORKING_DIR}/src/* ${LGSIM_SRC_INSTALL_PATH}
	@mv ${LGSIM_PUBLIC_HEADERS} ${LGSIM_HEADER_INSTALL_PATH}
	@cp ${P4C_WORKING_DIR}/inc/* ${LGSIM_SRC_INSTALL_PATH}
	@cp ${P4C_WORKING_DIR}/thrift-if-src/*.cpp ${PD_SRC_INSTALL_PATH}
	@cp ${P4C_WORKING_DIR}/thrift-if-src/*.h ${PD_HEADER_INSTALL_PATH}/
	@cp ${P4C_WORKING_DIR}/thrift/*.thrift ${THRIFT_BUILD_DIR}
	@touch $@

################################################################
# Thrift rules
################################################################

# Glass converts P4 program to thrift input for various interfaces
# Thrift then creates source code to be compiled
.thrift_ts: ${P4_INPUT} ${THRIFT_BUILD_DIR} .lgsim_ts
	@echo Create C files from P4 source with glass-lg
	@cp ${COMMON_DIR}/thrift.mk ${THRIFT_BUILD_DIR}
	@$(MAKE) -C ${THRIFT_BUILD_DIR} -f thrift.mk INSTALL_DIR=${LGSIM_SRC_INSTALL_PATH}
	@touch $@

thrift_python: ${THRIFT_PYTHON_DIR} .thrift_ts
	@echo Create Python API files
	@$(MAKE) -C ${THRIFT_BUILD_DIR} -f thrift.mk python-thrift INSTALL_DIR=${THRIFT_PYTHON_DIR}

################################################################
#
# Clean and help rules
#
################################################################

rm-tmp-dirs:
	rm -rf ${ALL_TMP_DIRS}

behavioral-clean:
	@$(MAKE) -f ${BEHAVIORAL_MK} clean

clean: ${TOFINO_CLEAN} rm-tmp-dirs behavioral-clean
	@rm -f .*_ts dependmodules.x lg_pd.mk ${ROOT}/modules/Manifest.mk
	@rm -f behavioral-model
	@rm -f ${ARCH_EXEC}
	@rm -rf ${LGSIM_MODULE_PATH}

help:
	@echo "Targets include"
	@echo "  behavioral-model (aka: lg, lionsgate, behavioral, ${P4_NAME})"
	@echo "       Build the behavioral model."
	@echo "  arch-model-install "
	@echo "       Build the arch model and driver exec, results in arch_model"
	@echo "  p4-graphs"
	@echo "       Build table and parse graphs for ${P4_NAME}"
	@echo "  crunch"
	@echo "       Run Walle (binary file cruncher) on JSON intermediates for ${P4_NAME}"
	@echo "  all"
	@echo "       Build behavioral model, arch-model-install and graphs"

${ALL_TMP_DIRS}:
	mkdir -p $@

.PHONY: p4-graphs lg lionsgate behavioral ${P4_NAME} clean help \
  behavioral-clean

