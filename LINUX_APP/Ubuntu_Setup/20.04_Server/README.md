## Ubuntu Server 20.04のセットアップ  
  
Ubuntu Server 20.04ではCUIのみの構成のため  
まずGUI環境をインストールする  
  
```bash
sudo apt-get install ubuntu-desktop  
sudo shutdown -r now  
```
  
GUIが立ち上がったあと、有線LANが"管理対象外"となって  
設定コンソールが出ない場合。  
  
```bash
sudo vim /etc/NetworkManager/conf.d/10-globally-managed-devices.conf  
```
  
```
[keyfile]  
unmanaged-devices=none  
```
  
```bash
# ネットワークマネージャーの再起動  
sudo service network-manager restart  
```

```bash
# 日本語環境設定   
sudo apt install language-pack-ja-base language-pack-ja ibus-mozc  
sudo apt install ibus-mozc  
ibus restart  
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'jp'), ('ibus', 'mozc-jp')]"  
```



以降のセットアップはDesktopと同一
