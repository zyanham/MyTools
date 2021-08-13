#### ■ Vitisアクセラレーションフロー使用後のSDカードへのイメージ書き込みについて
[UG1393 Vitis Application Acceleration P483](https://japan.xilinx.com/support/documentation/sw_manuals_j/xilinx2020_1/ug1393-vitis-application-acceleration.pdf#page=483)
  
#### ■ PetalinuxのDTG Settings->MAHINE_NAMEは規定の評価ボードがある場合は選択する
[UG1144 Petalinux tools Reference Guide P25](https://japan.xilinx.com/support/documentation/sw_manuals_j/xilinx2020_1/ug1144-petalinux-tools-reference-guide.pdf#page=25)  
  
#### ■ Vitis Libraryは一部 対応ボードが存在する。
Vitis Vision LibraryはU200にしか対応していない。(DDRの容量などの関係か？)  
→これによりU50などではプロジェクトで呼び出すことができなかった。  
Vision Libraryを実行するのにOpenCVのインストールは別途必要のよう。  
→ [ソース](https://forums.xilinx.com/t5/High-Level-Synthesis-HLS/Using-Vitis-Vision-Libraries-and-OpenCV/td-p/1170435)  
  
#### ■ OpenCVが入っているかどうかを調べる(python3経由)
```
Python3  
import cv2  
cv2.__version__  
```

#### ■ 古いバージョンをアンインストールする
cd ~/src/cpp/opencv/build
sudo make install
sudo make uninstall
sudo rm -rf /usr/local/include/opencv
rm -rf ~/.cache/opencv
cd ~/src/cpp
rm -rf ~/src/cpp/opencv

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
