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
 
