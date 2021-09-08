#### ★GitHub「Personal access tokens」の設定方法  
https://qiita.com/kz800/items/497ec70bff3e555dacd0  
  
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
  
#### ★2021.1 Ultra96: Ultra96 ボードで PS DisplayPort が機能しない  
  
https://japan.xilinx.com/support/answers/76568.html  
  
  
#### ■ Vitisアクセラレーションフロー使用後のSDカードへのイメージ書き込みについて
[UG1393 Vitis Application Acceleration P483](https://japan.xilinx.com/support/documentation/sw_manuals_j/xilinx2020_1/ug1393-vitis-application-acceleration.pdf#page=483)
  
#### ■ PetalinuxのDTG Settings->MAHINE_NAMEは規定の評価ボードがある場合は選択する
[UG1144 Petalinux tools Reference Guide P25](https://japan.xilinx.com/support/documentation/sw_manuals_j/xilinx2020_1/ug1144-petalinux-tools-reference-guide.pdf#page=25)  
  
#### ■ Vitis Libraryは一部 対応ボードが存在する。
Vitis Vision LibraryはU200にしか対応していない。(DDRの容量などの関係か？)  
→これによりU50などではプロジェクトで呼び出すことができなかった。  
Vision Libraryを実行するのにOpenCVのインストールは別途必要のよう。  
→ [ソース](https://forums.xilinx.com/t5/High-Level-Synthesis-HLS/Using-Vitis-Vision-Libraries-and-OpenCV/td-p/1170435)  
  
#### ■ OpenCVのインストール  
```
https://github.com/opencv/opencv
opencvとopencv_contribをダウンロード
opencvディレクトリにbuildディレクトリを作成
cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D INSTALL_PYTHON_EXAMPLES=ON -D INSTALL_C_EXAMPLES=OFF -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-4.4.0/modules -D BUILD_EXAMPLES=ON ..  

make -j4
sudo make install
sudo ldconfig
opencv_version
```

#### ■ OpenCVが入っているかどうかを調べる(python3経由)
```
Python3  
import cv2  
cv2.__version__  
```

#### ■ OpenCVの古いバージョンをアンインストールする  
```
cd ~/src/cpp/opencv/build  
sudo make install  
sudo make uninstall  
sudo rm -rf /usr/local/include/opencv  
rm -rf ~/.cache/opencv  
cd ~/src/cpp  
rm -rf ~/src/cpp/opencv  
```
  
#### ■ U96V2+PetalinuxでUSBカメラの絵出しを確認
```
import cv2

capture = cv2.VideoCapture(0)

while(True):
    ret, frame = capture.read()
    cv2.imshow('frame',frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

capture.release()
cv2.destroyAllWindows()
```


V2020.1  

U50 command  
```
sudo /opt/xilinx/xrt/bin/xbmgmt flash --update --shell xilinx_u50_xdma_201920_1  
```

U200 command  
```
sudo /opt/xilinx/xrt/bin/xbmgmt flash --update --shell xilinx_u200_gen3x16_xdma_base_1  
```

U250  
```
sudo /opt/xilinx/xrt/bin/xbutil flash -a xilinx_u250_xdma_201830_2 -t 1561656294  
```

U280  
```
sudo /opt/xilinx/xrt/bin/xbmgmt flash --update --shell xilinx_u280_xdma_201920_3  
```
