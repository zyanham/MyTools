## RTPサーバー環境構築のためのいろいろメモ Ubuntu20.04
・リアルタイム動画配信環境を構築する。  
・mp4などからRTP/RTSPプロトコルで出力できるか確かめる。  
  
#### 試験環境  
4K60p/4K30p/FullHD60p/FullHD30p  
  
RTSP(Real-Time Streaming Protocol)  
: 映像配信の制御を行う。TCPプロトコルを使用。  
RTP(Real-Time Transport Protocol)   
: メディアデータそのものの転送を行う。UDPプロトコルを使用。  
RTCP(RTP Control Protocol)  
: 受送信間の通信状況を伝達し速度調整に使用する。UDPプロトコルを使用。  
RTSPサーバー  
: RTSPプロトコルを使った映像・音声の配信を行うコンピューター  
  
GStreamer  
: フリー（ライセンスはLGPL）のマルチメディアフレームワーク。  
sinkとsourceという入出力を持つエレメントをつなぎ合わせて目的の機能を実現するパイプライン。  
  
gst-rtsp-server  
: GStreamerで提供されている、RTSPサーバー構築用のライブラリです。  
  
### GStreamerでRTSPサーバーを構築する。  
1.20.3が安定版(20220905時点)  
  
```bash
# GStreamer本体の基本ライブラリとコマンドライン実行バイナリパッケージをインストール  
sudo apt install libgstreamer1.0-0 gstreamer1.0-tools gstreamer1.0-libav  
  
# プラグインをインストール  
sudo apt install gstreamer1.0-plugins-*  
  
# RTSPサーバーをインストール  
sudo apt install libgstrtspserver-1.0-dev  
  
# RTSPサーバーのサンプルを取得  
# （gitがインストールされていない場合は、sudo apt install git でインストールしておく）  
git clone git://anongit.freedesktop.org/gstreamer/gst-rtsp-server  
cd gst-rtsp-server  
git checkout 1.4  
cd examples  
  
# サンプルをビルド  
gcc -o test-launch test-launch.c `pkg-config --cflags --libs gstreamer-rtsp-server-1.0`  
  
# RTSPサーバーの映像受信はVLC Media PlayerでOK  
> sudo apt-get install vlc  
  
# メディア->「ネットワークストリームを開く」を選択->「ネットワーク」タブでURLを入力  
```
  
### 動画ファイル基本  
動画ファイルはコンテナフォーマットというファイル形式で管理され、  
内部の映像、音声データはコーデックというルールで不可逆的に圧縮されているのが一般的。  
コンテナフォーマットはmp4,avi,mov,mkvなど  
動画コーデックはH.264,H.265,AV,MPEG2,MotionJPEGなど  
音声コーデックはMP3,AAC,ALAC,LPC,PCMなど  
  
ストリームのIPを指定する方法  
動画のコーデック、解像度、フレームレートを調べる方法  

```bash
# H264でテスト配信する  
./test-launch '( videotestsrc ! x264enc ! rtph264pay name=pay0 pt=96 )'  
  
# テスト画像を画面に出す  
gst-launch-1.0 videotestsrc ! videoconvert ! autovideosink  
gst-launch-1.0 videotestsrc ! queue ! autovideosink autoaudiosrc ! queue ! autoaudiosink  
  
# テスト画像をRTPで送信する  
# H.264で画像出力(送信側)  
gst-launch-1.0 -v videotestsrc ! x264enc ! rtph264pay ! udpsink host=<送信先IP> port=5005 sync=false  
# RTPをH.264で受信(受信側)  
gst-launch-1.0 -v udpsrc port=5005 ! application/x-rtp,media=video,encoding-name=H264 ! queue ! rtph264depay ! avdec_h264 ! videoconvert ! autovideosink  
  
# MP4画像をRTPで送信する  
# 任意MP4(H.264)を送信する(送信側)  
gst-launch-1.0 -v filesrc location = <ファイル名> ! decodebin ! x264enc ! rtph264pay ! udpsink host=<送信先IP> port=5005  
# PTPをH.264で受信(受信側)  
gst-launch-1.0 -v udpsrc port=5005 ! application/x-rtp,media=video,encoding-name=H264 ! queue ! rtph264depay ! avdec_h264 ! videoconvert ! autovideosink  
  
# webカメラ画像を表示  
gst-launch-1.0 v4l2src ! videoconvert ! ximagesink  
  
# 解像度を指定してwebカメラ画像を表示  
gst-launch-1.0 v4l2src ! video/x-raw,width=640,height=480,framerate=15/2 ! videoconvert ! ximagesink  
gst-launch-1.0 v4l2src device="/dev/video0" ! 'video/x-raw, width=640, height=480, framerate=30/1' ! videoconvert ! ximagesink  
  
gst-launch-1.0 filesrc location="~/Desktop/MOVIE/HD.mp4" ! decodebin ! x264enc ! ximagesink  

# パイプライン作成のためのエレメント一覧を表示  
gst-inspect-1.0  
```
  
videotestsrc は、テスト用のビデオソースでテストパターンを出力します。  
videoconvert は、カラースペース変換器？  
ximagesink は、ビデオ フレームをローカルまたはリモート ディスプレイ上のドローアブル (XWindow) にレンダリングします  

