### Ubuntu20.04LTS設定メモ  
##### ■ スクリーンのブランク設定を外す  
設定→電源→ブランクスクリーン→しない  
  
##### ■ 日本語化  
設定→地域と言語→日本語(Mozc)を選択  
  
##### ■ タスクバーの設定  
いらないものは削除して、Chromeをインストールし、  
Terminal/memo/system monitor/disk/chromeなど追加しておくとよい。  
  
##### ■デスクトップのディレクトリ類が日本語だった場合英語に戻すコマンド。  
LANG=en_US.utf8 xdg-user-dirs-gtk-update  
sudo reboot  
  
##### ■ターミナルにフルパスではなくカレントディレクトリのみ表示するには  
.bashrcのPS1に表記されている\Wを大文字Wにする。  
Historyの記憶サイズを変更する→HISTSIZE=の数値を変更する。  
  
##### ■ いろいろインストールしておく  
bash install.bash  
  
##### ■ コーデックを入れるためGstreamerをインストールしよう  
  
https://gstreamer.freedesktop.org/documentation/installing/on-linux.html?gi-language=c  
  
##### ■OpenCVのインストール(4.4.0)  
  
##### ■ OpenCVが入っているかどうかを調べる(python3経由)  
```
Python3  
import cv2  
cv2.__version__  
```
  
##### ■cmakeが古い場合はアップグレードする  
  
まず、既にaptなどでcmakeをインストールしてしまっている場合は、アンインストールしましょう。  
sudo apt purge cmake  
  
libssl-devを削除してlibssl1.0-devをインストールする  
  
wget https://cmake.org/files/v3.6/cmake-3.6.2.tar.gz  
tar xvf cmake-3.6.2.tar.gz  
  
./bootstrap && make && sudo make install  
  
echo 'export PATH=$HOME/cmake-3.6.2/bin/:$PATH' >> ~/.bashrc  
  
##### ■ OpenCVの古いバージョンをアンインストールする  
  
cd ~/src/cpp/opencv/build  
sudo make install  
sudo make uninstall  
sudo rm -rf /usr/local/include/opencv  
rm -rf ~/.cache/opencv  
cd ~/src/cpp  
rm -rf ~/src/cpp/opencv  
  
Linux 基本設定メモ  
ユーザーを作成,パスワードを設定する  
  
adduser <user name>  
passwd <user name>  
  
sudoグループにユーザを追加する  
  
gpasswd -a <user name> sudo  
  
ユーザーを削除する  
  
userdel -r <user name>  
  
ユーザーを確認する  
  
cat /etc/passwd  
  
メモ https://qiita.com/mocobt/items/726024fa1abf54d843e1  
  
xhost +local:  
xhost -local:  

MicroBlazeでFreeRTOSを動かす https://qiita.com/Rohira/items/6d0b8e9b848bc4b9db6  
  
docker run -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY $IMAGE  
  
中央から横1280:縦960でクロップ  
  
ffmpeg -i <input> -vf crop=w=1280:h=960 <output>  
  
縦480pixにあわせて動画を圧縮  
  
ffmpeg -i <input> -vf scale=-1:480 <output>  
  
カレントディレクトリのファイルの名前と番号をつけ直すmvのリストを出力するスクリプト  
  
ls | awk '{ printf "mv %s TEST_IMG%03d.JPG\n", $0, NR }' > xlist.txt  
  
Ubuntu18.04にNVIDIAドライバを入れる:参考記事  
  
シェルの種類はだいたい  
bash, csh/tcsh, dash, zshなど  
  
    ls -l /bin/sh で現在のシェルが何になっているかを調べることができる  
  
find command  
  
grep command  
sed command  
