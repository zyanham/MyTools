TGT:ZCU102  
Ver:v2023.2  
  
petalinux-minimal-image構成に加えて回路情報を追加して  
zcu102向けBSP -> zcu102-zynqmpを使用して  
ただビルドしただけ。  
Uartをつなげて起動を確認できた。  

'''
## step1 : vivado2023.2でビルドしてXSAファイルをつくる  
> vivado -source v23.2_zcu102_custom.tcl

## step2 : start.bashを叩くだけ  
> bash start.bash  
'''
