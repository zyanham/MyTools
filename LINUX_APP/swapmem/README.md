freeコマンドを使って現在のスワップメモリ領域を確認する  
> free -h  
  
DDコマンドでスワップファイルを作成。単位はこの場合MBでcountの値を任意に変更する例は1GB  
sudo dd if=/dev/zero of=/swapfile bs=1M count=1024  
  
16GBで試験(SWAPがもうある場合は2)  
> sudo dd if=/dev/zero of=/swapfile2 bs=1M count=16384  
  
mkswapコマンドを使ってスワップファイルを設定する  
> sudo mkswap /swapfile2  

作成したスワップファイルを有効化  
> sudo swapon /swapfile2  
  
永続化とか  
echo '/swapfile2 none swap sw 0 0' | sudo tee -a /etc/fstab  
  
もう一度スワップメモリ領域を確認する  
> free -h  
