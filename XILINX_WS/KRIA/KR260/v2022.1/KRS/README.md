## KR260 KRS Setup MEMO  
Ubuntuの公式イメージが配布されているのでまずは動作確認。

[1.Kria KR260 ロボティクス スターター キットで 開発を始める](https://japan.xilinx.com/products/som/kria/kr260-robotics-starter-kit/kr260-getting-started/getting-started.html)  
  
ボードの動作確認が完了したら、KRSのセットアップと動作確認を実施する  
[2.Kria Robotics Stack(KRS)を触ってみる](https://xilinx.github.io/KRS/sphinx/build/html/index.html)  

KRSは産業向けのROS2スーパーセットで、産業クラスのロボット開発保守商用化を加速させる  
ロボットライブラリとユーティリティの統合セットです。(翻訳のまま)  
  
[ROS2 Humbleのページはこちら](https://docs.ros.org/en/humble/index.html)  
[KRSのGithubページはこちら](https://github.com/Xilinx/KRS)  

KRSには２パターンのOSへの帰結がある。  
最終的にMPSOC上でどちらで動かすかでフローが変わるらしい。  
・Yocto/Petalinux  
・Ubuntu22.04  
  
いずれも確認してみる。  
  
いずれも環境も、  
まずは開発に使用するワークステーション側に開発環境のインストールが必要  
・ワークステーションのOS Ubuntu 22.04 Jammy Jellyfish  
・Vitis 2022.1スイート (Vitis、Vivado、Vitis HLS)  
  →VitisもVivadoも2022.1はUbuntu22.04をサポートしてないので矛盾してる？  
・ROS 2 Humble Hawksbill ディストリビューション  
・Gazebo Classic 11.0   
  
すでにUbuntu上でVitis/Vivado/VitisHLSをインストール済みとして、  
ROS2 Humble HawksbillとGazebo Classic 11.0のインストールを試みる。  
  
host_setup.bashにまとめてあるので、実行します  
```  
> bash host_setup.bash
```  

ROS2がインストールできたか確認するには
まずターミナルを２個用意して、ROSのセットアップを読み込む
```  
> source /opt/ros/humble/setup.bash
```  

その後ros2のコマンドでメッセージの送受信を各ターミナルで実行する
```  
# Terminal 1
> ros2 run demo_nodes_cpp talker

# Terminal 2
> ros2 run demo_nodes_py listener
```  

次にGAZEBOのインストールを確認するにはコマンドで呼び出して見るだけ
```  
> gazebo
```  
GUIが立ち上がったら成功  
  
Cyclone DDSのセットアップも実施しています  
  
  
***  
## Yocto/Petalinuxフロー  
ここではKRS+Petalinux+MPSOCの環境を構築する確認をします。  

Yocto/PetaLinux を使用してロボット OS を作成するためのビルド済みファームウェア アーティファクト  
なるものをダウンロードする必要があるようで、githubの２GB制限を超えているので手動でダウンロードする  

https://drive.google.com/file/d/1gzrGHB-J_fKNBmcGYhClXdWo6wGw8k43/view?usp=sharing  




***  
## Ubuntu 22.04フロー  
ここではKRS+Ubuntu22.04+MPSOCの環境を構築する確認をします。