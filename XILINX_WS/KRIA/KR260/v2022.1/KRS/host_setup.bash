#! /bin/bash

###############################
# ROS2 Install Flow to Host PC
###############################
locale  # check for UTF-8

sudo apt update && sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

locale  # verify settings

sudo apt install -y software-properties-common
sudo add-apt-repository universe

sudo apt update && sudo apt install -y curl
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

sudo apt update
sudo apt upgrade

sudo apt install ros-humble-desktop
sudo apt install ros-humble-ros-base
sudo apt install ros-dev-tools

source /opt/ros/humble/setup.bash
##ros2 run demo_nodes_cpp talker
##ros2 run demo_nodes_py listener

#########################################
# Gazebo Classic Install Flow to Host PC
#########################################
curl -sSL http://get.gazebosim.org | sh

###################################################
# install cyclone DDS packages 
###################################################
sudo apt-get install ros-humble-rmw-cyclonedds-cpp ros-humble-cyclonedds* 

###################################################
# Switch from other rmw to rmw_cyclonedds by specifying the environment variable.
###################################################
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
