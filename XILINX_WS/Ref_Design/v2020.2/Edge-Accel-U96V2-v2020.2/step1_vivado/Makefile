# Copyright 2020 Xilinx Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ROOT_DIR=$(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ABS_BUILD_PATH=$(ROOT_DIR)/build
ABS_HW_PATH=$(ABS_BUILD_PATH)/vivado
BD_TCL=U96V2_vivado.tcl
ABS_BD_TCL=$(ROOT_DIR)/$(BD_TCL)

all: hw

hw:
	mkdir -p $(ABS_HW_PATH)
#	cd $(ABS_HW_PATH); vivado -mode batch -notrace -source $(ABS_BD_TCL) -source ../../export_xsa.tcl
	cd $(ABS_HW_PATH); vivado -mode batch -notrace -source $(ABS_BD_TCL)


clean:
	$(RM) -r $(ABS_BUILD_PATH) vivado*.log vivado*.jou 
