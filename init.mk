################################################################
#
#        Copyright 2013, Big Switch Networks, Inc. 
#        Copyright 2013, Barefoot Networks, Inc. 
# 
# Licensed under the Eclipse Public License, Version 1.0 (the
# "License"); you may not use this file except in compliance
# with the License. You may obtain a copy of the License at
# 
#        http://www.eclipse.org/legal/epl-v10.html
# 
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
# either express or implied. See the License for the specific
# language governing permissions and limitations under the
# License.
#
################################################################

#
# The root of of our repository is here:
#
ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

#
# Resolve submodule dependencies. 
# Please keep alphabetized

ifndef SUBMODULE_BIGCODE
  ifdef SUBMODULES
    SUBMODULE_BIGCODE := $(SUBMODULES)/bigcode
  else
    SUBMODULE_BIGCODE := $(ROOT)/submodules/bigcode
    SUBMODULES_LOCAL += bigcode
  endif
endif

ifndef SUBMODULE_INFRA
  ifdef SUBMODULES
    SUBMODULE_INFRA := $(SUBMODULES)/infra
  else
    SUBMODULE_INFRA := $(ROOT)/submodules/infra
    SUBMODULES_LOCAL += infra
  endif
endif

ifndef SUBMODULE_INDIGO
  ifdef SUBMODULES
    SUBMODULE_INDIGO := $(SUBMODULES)/indigo
  else
    SUBMODULE_INDIGO := $(ROOT)/submodules/indigo
    SUBMODULES_LOCAL += indigo
  endif
endif

ifndef SUBMODULE_OFT_INFRA
  ifdef SUBMODULES
    SUBMODULE_OFT_INFRA := $(SUBMODULES)/oft-infra
  else
    SUBMODULE_OFT_INFRA := $(ROOT)/submodules/oft-infra
    SUBMODULES_LOCAL += oft-infra
  endif
endif

ifndef SUBMODULE_P4C_BEHAVIORAL
  ifdef SUBMODULES
    SUBMODULE_P4C_BEHAVIORAL := $(SUBMODULES)/p4c-behavioral
  else
    SUBMODULE_P4C_BEHAVIORAL := $(ROOT)/submodules/p4c-behavioral
    SUBMODULES_LOCAL += p4c-behavioral
  endif
endif

ifndef SUBMODULE_P4C_GRAPHS
  ifdef SUBMODULES
    SUBMODULE_P4C_GRAPHS := $(SUBMODULES)/p4c-graphs
  else
    SUBMODULE_P4C_GRAPHS := $(ROOT)/submodules/p4c-graphs
    SUBMODULES_LOCAL += p4c-graphs
  endif
endif

ifdef SUBMODULES_LOCAL
  SUBMODULES_LOCAL_UPDATE := $(shell python $(ROOT)/submodules/init.py --update $(SUBMODULES_LOCAL))
  ifneq ($(lastword $(SUBMODULES_LOCAL_UPDATE)),submodules:ok.)
    $(info Local submodule update failed.)
    $(info Result:)
    $(info $(SUBMODULES_LOCAL_UPDATE))
    $(error Abort)
  endif
endif

export SUBMODULE_BIGCODE
export SUBMODULE_INDIGO
export SUBMODULE_INFRA
export SUBMODULE_OFT_INFRA
export SUBMODULE_P4C_BEHAVIORAL
export SUBMODULE_P4C_GRAPHS
export BUILDER := $(SUBMODULE_INFRA)/builder/unix

MODULE_DIRS := $(ROOT)/modules \
    $(SUBMODULE_INFRA)/modules \
    $(SUBMODULE_INDIGO)/modules \
    $(SUBMODULE_BIGCODE)/modules

.show-submodules:
	@echo bigcode @ $(SUBMODULE_BIGCODE)
	@echo indigo @ $(SUBMODULE_INDIGO)
	@echo infra @ $(SUBMODULE_INFRA)
	@echo oft_infra @ $(SUBMODULE_OFT_INFRA)
	@echo p4c_behavioral @ $(SUBMODULE_P4C_BEHAVIORAL)
	@echo p4c_graphs @ $(SUBMODULE_P4C_GRAPHS)
