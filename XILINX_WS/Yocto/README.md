# Yocto Project for AMD FPGA  

AMD(XILINX)のYoctoLinux使用についてここに情報あり   
[Yocto : Xilinx Wiki](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18841883/Yocto)  
・関連するPokyのタグについてこちらに対応表がまとまっている。

Yocto Project公式情報    
[Yocto Project Wiki](https://wiki.yoctoproject.org/wiki/Main_Page)  

->  
  [BSPのつくりかた](https://docs.yoctoproject.org/bsp-guide/bsp.html)
  
  
[meta-xilinx](https://github.com/Xilinx/meta-xilinx)  
[yocto manifest](https://github.com/Xilinx/yocto-manifests)  
[meta-AMD adaptible SoCs](https://github.com/Xilinx/meta-amd-adaptive-socs/tree/rel-v2024.2)



```  
wicを書き込む方法  
> sudo dd if=petalinux-sdimage.wic of=/dev/sd<X> conv=fsync
> sudo parted /dev/sd<X> resizepart 2 100%  
> sudo e2fsck -f /dev/<device partition 2>  
> sudo resize2fs /dev/<device partition 2>  
```  
  
[参考PALTEK Tech Blog](https://www.paltek.co.jp/techblog/techinfo/240626_01) 
  
try00_Raspi0-2w           -> 試行0:raspi0wのビルド  
try01_v23.2_zcu102_min    -> 試行1:最小構成のzcu102向けビルド(v2023.2)  
try02_v24.2_vek280_min    -> 試行2:最小構成のvek280向けビルド(v2024.2)  
try03_v24.2_zcu102_min    -> 試行3:最小構成のzcu102向けビルド(v2024.2)  
try04_v23.2_zcu102_custom -> 試行4:最小構成のzcu102に加えてFPGA回路情報を含めてbuild(v2023.2)  
try05_v23.2_zub1cg_custom -> 試行5:カスタムボード向けzynqmp-genericと、FPGA回路情報含めてbuild(v2023.2)  

