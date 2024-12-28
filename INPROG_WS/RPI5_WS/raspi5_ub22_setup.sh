sudo apt install build-essential cmake git locales curl wget gnupg lsb-release python3 python3-pip vim

sudo locale-gen en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8
locale  # verify settings

sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(source /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

sudo apt-get update && sudo apt-get upgrade
sudo apt-get install ros-jazzy-desktop-full python3-colcon-common-extensions

source /opt/ros/jazzy/setup.bash

#USBカメラをRaspberry Piに接続し、必要なパッケージをインストールします。
sudo apt-get install ros-jazzy-usb-cam


