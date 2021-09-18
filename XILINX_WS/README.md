#### ★Vivado 2021.1で外部ボードファイルの適用する方法  
外部からボードファイルを適用しにくくなった。  
  
まずはXILINXブランド以外のボードファイルをダウンロード  
Digilent: git clone https://github.com/Digilent/vivado-boards.git  
AVNET: git clone https://github.com/Avnet/bdf.git  
  
通常インストール時なら下記のパスにTCLを配置する。  
.Xilinx/Vivado/2021.1/Vivado_init.tcl  
  
記述例  
***********************************************************  
set_param board.repoPaths /mnt/backup/Digilent/board_files  
set_param board.repopaths /mnt/backup/Avnet  
***********************************************************  
    
#### ■ Vitisアクセラレーションフロー使用後のSDカードへのイメージ書き込みについて
[UG1393 Vitis Application Acceleration P483](https://japan.xilinx.com/support/documentation/sw_manuals_j/xilinx2020_1/ug1393-vitis-application-acceleration.pdf#page=483)
  
#### ■ PetalinuxのDTG Settings->MAHINE_NAMEは規定の評価ボードがある場合は選択する
[UG1144 Petalinux tools Reference Guide P25](https://japan.xilinx.com/support/documentation/sw_manuals_j/xilinx2020_1/ug1144-petalinux-tools-reference-guide.pdf#page=25)  
    

### HLSメモ
[ZYBOでVitisアクセラレーションプラットフォームを作る(Vitis2021.1)](https://www.hackster.io/mohammad-hosseinabady2/vitis-2021-1-embedded-platform-for-zybo-z7-20-d39e1a)  

#### HLSのCFLAGS設定メモ(v2020.2で確認)
Synthesis CFLAGS:  
>-I/XXXX/Vitis_Libraries/vision/L1/include -std=c++0x  
  
Simulation CFLAGS:  
>-I<path-to-L1-include-directory> -std=c++0x -I<path-to-opencv-include-folder>  
>-I/XXXX/Vitis_Libraries/vision/L1/include -std=c++0x -I/usr/local/include/opencv2/  
  
Linker:  
>-L<path-to-opencv-lib-folder> -lopencv_core -lopencv_imgcodecs -lopencv_imgproc  
>-L/usr/local/lib -lopencv_core -lopencv_imgcodecs -lopencv_imgproc  
  
Argument:  
>/XXXX/Vitis_Libraries/vision/data/128x128.png  
>/XXXX/TST01_720p.jpg  

[参考Vitis Vision Library で AXI4-Stream 入出力の medianblur を実装する1](https://marsee101.blog.fc2.com/blog-entry-5107.html)

##### HLSではZynq製品はAXI Interface axi_addr64のチェックを外す



### V2020.1 ALVEO Command
```
U50 command  
sudo /opt/xilinx/xrt/bin/xbmgmt flash --update --shell xilinx_u50_xdma_201920_1  
  
U200 command  
sudo /opt/xilinx/xrt/bin/xbmgmt flash --update --shell xilinx_u200_gen3x16_xdma_base_1  
  
U250  
sudo /opt/xilinx/xrt/bin/xbutil flash -a xilinx_u250_xdma_201830_2 -t 1561656294  
  
U280  
sudo /opt/xilinx/xrt/bin/xbmgmt flash --update --shell xilinx_u280_xdma_201920_3  
```
