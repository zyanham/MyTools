### Ubuntu19でAMDのGPUドライバーをインストールしたい 
  

> lspci | grep VGA  
  
でグラフィックカードの番号が出力される。  
この情報を使用してドライバをインストールする  
```
09:00.0 VGA compatible controller: Advanced Micro Devices, Inc.[AMD/ATI] Lexa PRO [Radeon RX 550/550X] (rev c7)  
```  

[AMDのドライバをHPよりダウンロードする](https://www.amd.com/en/support)  

