#########################################################################################################
# 1.Creating a Project
#
# Instead of
#   > petalinux-create -t project -n <PROJECT NAME> --template [microblaze,zynq,zynqMP,versal,versal-net]
#########################################################################################################
repo init -u https://github.com/Xilinx/yocto-manifests.git  -b rel-v2023.2
repo sync
source setupsdk
ls -l ../sources/meta-xilinx/meta-xilinx-core/conf/machine/*.conf  # Show available templates
sed -i "/MACHINE ??=/c\MACHINE ??= \"zynqmp-generic\"" conf/local.conf # Set the machine template in conf/local.conf (change as desired)
# Alternatively, you could just override with MACHINE=zynqmp-generic on the bitbake command when building to select the appropriate board.

############################################################################
# 2.Configuring and Building - Setting up the PetaLinux / Yocto environment
#
# Instead of
#   > source /opt/tools/PetaLinux/2023.1/tool/settings.sh
#   > cd xilinx-zcu102-2023.1 #PetaLinux project directory
############################################################################
#cd myproject
#source setupsdk #This file is made during initial clone with repo.

############################################################################
# 2.Configuring and Building - Importing a Hardware Configuration
#
# Instead of
#   > petalinux-config --get-hw-description <path to XSA file>
############################################################################
# Part 1 - Setting up a new layer and machine configuration (do once)
bitbake-layers create-layer ../sources/meta-myhardware # Create a new layer for your custom hardware configuration to live (name as applicable)
bitbake-layers add-layer ../sources/meta-myhardware # Allow bitbake to find the layer when building
mkdir ../sources/meta-myhardware/conf/machine # Make a new folder in your layer to store machine configurations

cat << EOF > ../sources/meta-myhardware/conf/machine/myhardware-zcu102-zynqmp.conf 
#Base this machine configuration off of the zcu102 board and then make changes below
require conf/machine/zcu102-zynqmp.conf
HDF_BASE = "file://"
# Replace with the path to your XSA file from hardware
HDF_PATH = "$ROOT/zcu102_custom/system_wrapper.xsa"
EOF

# Part 2 - Edit the configuration to use the newly created machine configuration
sed -i "/MACHINE ??=/c\MACHINE ??= \"myhardware-zcu102-zynqmp\"" conf/local.conf # Set the machine in conf/local.conf (change name as applicable)

# SD Card Image
echo 'IMAGE_FSTYPES += "wic"' >>  ../sources/meta-myhardware/conf/machine/myhardware-zcu102-zynqmp.conf # Change path to match your machine layer

############################################################################
# 3.Building a System Image
#
# Instead of
#   > petalinux-build # The default image built is petalinux-image-minimal
############################################################################

bitbake petalinux-image-minimal


############################################################################
# 4.Packaging and Booting
#
# Instead of
#   > petalinux-package --boot --u-boot
############################################################################
# bitbake xilinx-bootbin

