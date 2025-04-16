## Install dependencies
sudo apt update
sudo apt upgrade

wget https://apt.kitware.com/kitware-archive.sh
sudo bash kitware-archive.sh

sudo apt install --no-install-recommends git cmake ninja-build gperf ccache dfu-util device-tree-compiler wget python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1

## Get Zephyr and install Python dependencies
sudo apt install python3-venv
python3 -m venv zephyr_env
source zephyr_env/bin/activate
pip install west
west init ./zephyrproject
cd ./zephyrproject
west update
west zephyr-export
west packages pip --install

## Install the Zephyr SDK
cd ./zephyrproject/zephyr
west sdk install

## Build the Blinky Sample
cd ./zephyrproject/zephyr
west build -p always -b <your-board-name> samples/basic/blinky

## Flash the Sample
#west flash

