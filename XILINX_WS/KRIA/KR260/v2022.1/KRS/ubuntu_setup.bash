#! /bin/bash

###################################################
# 0. install Vitis 2022.1 https://www.xilinx.com/support/download.html       
#   and ROS 2 Rolling https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debians.html
#    we recommend the Desktop-Full flavour (ros-humble-desktop-full)
###################################################

###################################################
# 1. install some dependencies you might be missing
#
# NOTE: gcc-multilib conflicts with Yocto/PetaLinux 2022.1 dependencies
# so you can't have both paths simultaneously enabled in a single
# development machine
###################################################
sudo apt-get -y install curl build-essential libssl-dev git wget \
                          ocl-icd-* opencl-headers python3-vcstool \
                          python3-colcon-common-extensions python3-colcon-mixin \
                          kpartx u-boot-tools pv gcc-multilib
sudo apt-get -y install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

###################################################
# 2. create a new ROS 2 workspace with examples and
#    firmware for KR260
###################################################
mkdir -p krs_ubuntu_ws/src; cd krs_ubuntu_ws

###################################################
# 3. Create file with KRS 1.0 additional repos
###################################################
cat << 'EOF' > krs_humble.repos
repositories:  
  perception/image_pipeline:
    type: git
    url: https://github.com/ros-acceleration/image_pipeline
    version: ros2

  tracing/tracetools_acceleration:
    type: git
    url: https://github.com/ros-acceleration/tracetools_acceleration
    version: humble

  firmware/acceleration_firmware_kr260:
    type: zip
    url: https://github.com/ros-acceleration/acceleration_firmware_kr260/releases/download/v1.0.0/acceleration_firmware_kr260.zip

  acceleration/adaptive_component:
    type: git
    url: https://github.com/ros-acceleration/adaptive_component
    version: humble
  acceleration/ament_acceleration:
    type: git
    url: https://github.com/ros-acceleration/ament_acceleration
    version: humble
  acceleration/ament_vitis:
    type: git
    url: https://github.com/ros-acceleration/ament_vitis
    version: humble
  acceleration/colcon-hardware-acceleration:
    type: git
    url: https://github.com/colcon/colcon-hardware-acceleration
    version: main
  acceleration/ros2_kria:
    type: git
    url: https://github.com/ros-acceleration/ros2_kria
    version: main
  acceleration/ros2acceleration:
    type: git
    url: https://github.com/ros-acceleration/ros2acceleration
    version: humble
  acceleration/vitis_common:
    type: git
    url: https://github.com/ros-acceleration/vitis_common
    version: humble
  acceleration/acceleration_examples:
    type: git
    url: https://github.com/ros-acceleration/acceleration_examples
    version: main
EOF

###################################################
# 4. import repos of KRS 1.0 release
###################################################
vcs import src --recursive < krs_humble.repos  # about 3 mins in an AMD Ryzen 5 PRO 4650G

###################################################
# 5. build the workspace and deploy firmware for hardware acceleration
###################################################
source /opt/Xilinx/Vitis/2022.1/settings64.sh  # source Xilinx tools
source /opt/ros/humble/setup.bash  # Sources system ROS 2 installation.

# Note: The path above is valid if one installs ROS 2 from a pre-built debian
# packages. If one builds ROS 2 from the source the directory might
# vary (e.g. ~/ros2_humble/ros2-linux).
export PATH="/usr/bin":$PATH  # FIXME: adjust path for CMake 3.5+

colcon build --merge-install  # about 18 mins in an AMD Ryzen 5 PRO 4650G

###################################################
# 6. source the overlay to enable all features
###################################################
source install/setup.bash

###################################################
# 6.B workaround for KR260 additional firmware elements
#   see https://github.com/Xilinx/KRS/issues/62#issue-1292007180
#
# TODO: remove this once these artifacts are added to KR260
#   firmware ROS package (acceleration_firmware_kr260)
###################################################
# fetch KV260 firmware
cd ~/krs_ws
wget https://www.xilinx.com/bin/public/openDownload?filename=acceleration_firmware_kv260.zip -P src/firmware/acceleration_firmware_kv260
unzip src/firmware/acceleration_firmware_kv260/openDownload\?filename\=acceleration_firmware_kv260.zip -d src/firmware/acceleration_firmware_kv260/

# deploy KV260 firmware
colcon build --merge-install --packages-select acceleration_firmware_kv260

# select KV260 firmware artifacts and re-build accelerators targeting KR260 build configuration
source install/setup.bash
colcon acceleration select kv260


###################################################
# 7.A cross-compile and generate ONLY CPU binaries
###################################################
colcon build --build-base=build-kr260-ubuntu --install-base=install-kr260-ubuntu --merge-install --mixin kr260 --cmake-args -DNOKERNELS=true

###################################################
# 7.B cross-compile and generate CPU binaries and accelerators
###################################################
colcon build --build-base=build-kr260-ubuntu --install-base=install-kr260-ubuntu --merge-install --mixin kr260
