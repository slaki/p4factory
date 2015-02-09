################################################################
#
# Makefile for building thrift products
#
# Assumes thrift input files exist
#
################################################################

ifndef INSTALL_DIR
$(error "thrift.mk needs INSTALL_DIR defined")
endif

all: behavioral-thrift

################################################################
# PD layer rules
################################################################

# Enable line below if CPP thrift client is needed
PD_THRIFT_CPP_CLIENT = 1

PD_THRIFT_SOURCE = bfn_pd_constants.cpp \
    bfn_pd_types.cpp

ifeq ($(TOOLCHAIN),clang)
PD_THRIFT_SOURCE += bfn_pd_rpc.cpp 
else
ifdef PD_THRIFT_CPP_CLIENT
PD_THRIFT_SOURCE += bfn_pd_rpc.cpp 
endif
endif

PD_THRIFT_PRIVATE_HEADERS = bfn_pd_rpc.h \
    bfn_pd_constants.h \
    bfn_pd_types.h

PD_THRIFT_SRC_FILES =  $(addprefix gen-cpp/, \
    ${PD_THRIFT_PRIVATE_HEADERS} ${PD_THRIFT_SOURCE})

behavioral-thrift: .behavioral_ts

.behavioral_ts: bfn_pd.thrift
	@thrift --gen cpp bfn_pd.thrift
	@cp ${PD_THRIFT_SRC_FILES} ${INSTALL_DIR}

################################################################
# API layer rules
################################################################

API_THRIFT_SOURCE += bfn_api_rpc.cpp \
    bfn_api_constants.cpp \
    bfn_api_types.cpp

API_THRIFT_PRIVATE_HEADERS += bfn_api_rpc.h \
    bfn_api_constants.h \
    bfn_api_types.h

API_THRIFT_SRC_FILES =  $(addprefix gen-cpp/, \
    ${API_THRIFT_PRIVATE_HEADERS} ${API_THRIFT_SOURCE})

api-thrift: .api_ts

.api_ts: bfn_api.thrift
	@thrift --gen cpp bfn_api.thrift
	@cp -r ${API_THRIFT_SRC_FILES} ${INSTALL_DIR}

################################################################
# Python layer rules
################################################################

PYTHON_FILES_SRC_DIR = gen-py/bfnrpc

python-thrift: .python_ts

.python_ts: bfn_pd.thrift
	@thrift --gen py bfn_pd.thrift
	@cp -r gen-py/bfnrpc/* ${INSTALL_DIR}


.PHONY: behavioral-thrift api-thrift python-thrift
