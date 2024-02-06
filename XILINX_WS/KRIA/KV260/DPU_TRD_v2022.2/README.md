# DPUを構築するメモ  
Petalinux向けのイメージは公式ページで配布している  
[Petalinux Image deploy page](https://japan.xilinx.com/products/som/kria/kv260-vision-starter-kit/kv260-getting-started/setting-up-the-sd-card-image.html)  
  
ここでダウンロードした公式イメージでDPUが動かせるかどうか試して見るテスト  
  
デフォルトでDPUはB4096 x2の300MHz他。動作も確認。

ここでダウンロードできるpetalinux2021.1 update1のSDイメージではSmartCAMは何らかの理由でリリースされていない。
ダウンロードやインストールができないかも  
>sudo dnf install packagegroup-kv260-smartcam.noarch  
>xmutil getpkgs  
参考ソース  
https://support.xilinx.com/s/question/0D54U00005SfAEtSAN/failed-to-dnf-download-smartcam-app-on-20221?language=ja  
  
■Tips  
[Ptalinux v2022.2では動かない？](https://community.element14.com/products/roadtest/b/blog/posts/amd-xilinx-kria-kv260-vision-ai-starter-kit-preparing-the-kv260)  
  
Petalinuxの配布版に[これ](https://qiita.com/lp6m/items/df1b87b11f8275ee6210)を合わせてもNG
  
[kria-vitis-platforms](https://github.com/Xilinx/kria-vitis-platforms)ベースで試してみる  
’''
> git clone -b xlnx_rel_v2022.2 https://github.com/Xilinx/kria-vitis-platforms.git  
> cd kria-vitis-platforms/kv260/  
> make overlay OVERLAY=benchmark  
>  
'''