### ZYBO Z7-20向け  
  
ZYBOZ7_TEST.tclを実行後petalinuxは下記の手順で実行する  
ZYBOにpetalinuxを適用してデバイスドライバで何かを動かすソース  

```
petalinux-create --type project --template zynq --name zyboz7_cultom_plnx  
```
  
##### Petalinux clean build  
```
petalinux-build -x mrproper  
```
  
##### petalinux-config  
```
petalinux-config --get-hw-description=<vivado_design_dir>  
Exit->Exit  
```

##### kernel setting  
```
petalinux-config -c kernel  
  
Device Drivers > USB suport > USB Gadget Support >  
[*] USB Webcam function  
<*> USB Webcam Gadget  
  
Device Drivers > Multimedia support  >  
[*] Media USB Adapters > ←チェックを入れると、さらに下層に入れるようになる  
<*> USB Video Class (UVC) (NEW)  
```

```
petalinux-config -c rootfs  
  
Filesystem Packages > base > tar >  
[*] tar  
Filesystem Packages > base > i2c-tools >  
[*] i2c-tools  
Filesystem Packages > benchmark > tests > dhrystone  
[*] dhrystone  
Filesystem Packages > console > utils > unzip  
[*] unzip  
Filesystem Packages > console > utils > vim  
[*] vim  
Filesystem Packages > devel > make  
[*] make  
Filesystem Packages > multimedia > gstreamer1.0  
[*] gstreamer1.0  
Filesystem Packages > misc > python3 >  
[*] python3  
Filesystem Packages > misc > v4l-utils >  
[*] v4l-utils  
Filesystem Packages > misc > xauth >  
[*] xauth  
Filesystem Packages > misc > packagegroup-core-x11 >  
[*] packagegroup-core-x11  
Petalinux Package Groups > packagegroup-petalinux-openamp >  
[*] packagegroup-petalinux-openamp  
Petalinux Package Groups > packagegroup-petalinux-opencv >  
[*] packagegroup-petalinux-opencv  
Petalinux Package Groups > packagegroup-petalinux-x11 >  
[*] packagegroup-petalinux-x11  
```

```
vim project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi  
```

```
/include/ "system-conf.dtsi"  
  
/{  
    usb_phy0: usb_phy@0 {  
        compatible = "ulpi-phy";  
        #phy-cells = <0>;  
        reg = <0xe0002000 0x1000>;  
        view-port = <0x0170>;  
        drv-vbus;  
    };  
};  
  
&usb0 {  
    compatible = "xlnx,zynq-usb-2.20a", "chipidea,usb2";  
    status = "okay";  
    clocks = <0x1 0x1c>;  
    dr_mode = "host";  
    interrupt-parent = <0x4>;  
    interrupts = <0x0 0x15 0x4>;  
    reg = <0xe0002000 0x1000>;  
    usb-phy = <&usb_phy0>;  
};  
```

```
petalinux-build  
```

```
petalinux-package --boot --force --fsbl images/linux/zynq_fsbl.elf --fpga <bit path> --u-boot  
```
