## ALVEO Card Debug Guide  
  
```bash  
# Golden Imageへの戻し方  
  
  
# Card BDFの確認方法  
# ALVEOにはManagement BDF, User BDFの両方が割り当てられる。  
# Management BDFを確認するためのコマンドは  
sudo /opt/xilinx/xrt/bin/xbmgmt examine  
# Formatはvvvv:xx:yy.0  
  
# User BDFを確認するためのコマンドは  
sudo /opt/xilinx/xrt/bin/xbutil examine  
# Formatはvvvv:xx:yy.1  
  
# 初期セットアップ  
# ベースパーティションをALVEOカードに書き込みます。  
sudo /opt/xilinx/xrt/bin/xbmgmt program --base --device <management BDF>  
  
# 正常終了したらCold Rebootを実施します。  
```

# Vitisアクセラレーション(Emulation)を実行する  
実行前に下記の環境変数を設定する。  
  
Emulation-SWを実行するとき  
export XCL_EMULATION_MODE=sw_emu  
  
Emulation-HWを実行するとき  
export XCL_EMULATION_MODE=hw_emu  
