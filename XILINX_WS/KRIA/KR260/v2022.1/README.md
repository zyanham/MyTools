### KR260 Memo  
update 2023/2/2　　
  
#### 参考文献　　
[Kria　KR260 Getting Started](https://japan.xilinx.com/products/som/kria/kr260-robotics-starter-kit/kr260-getting-started/getting-started.html)　　
[Kria　KR260 ロボティクススターターキット ユーザーガイド UG1092](https://docs.xilinx.com/r/ja-JP/ug1092-kr260-starter-kit)　　
[Canonical Kria向けUbuntu 20.04配布ページ](https://ubuntu.com/download/amd-xilinx)　　
[Image Writer Balena Etcher配布ページ](https://www.balena.io/etcher)　　
　　
KRIAはプライマリブートデバイスとセカンダリブートデバイスがある。  
[ブートデバイスおよびファームウェアの概要](https://docs.xilinx.com/r/ja-JP/ug1092-kr260-starter-kit/%E3%83%96%E3%83%BC%E3%83%88-%E3%83%87%E3%83%90%E3%82%A4%E3%82%B9%E3%81%8A%E3%82%88%E3%81%B3%E3%83%95%E3%82%A1%E3%83%BC%E3%83%A0%E3%82%A6%E3%82%A7%E3%82%A2%E3%81%AE%E6%A6%82%E8%A6%81).　　
・プライマリブートデバイスはSOMに組み込まれたQSPIフラッシュメモリ内にあり、セカンダリブートデバイスはスターターキットのベースボード側のSDを示す。　　
　　
まず、プライマリブートのためのブートイメージはQSPIにプリインストールされているため、　　
動作確認のためにはセカンダリブートのイメージを準備する必要があります。　　
　　
セカンダリブートをすぐに試す場合はUbuntuから配布されているKR260用のブートイメージを使用するのが早いです。　　
[KR260用ブートイメージ]()　　

Ethernet向かって右側がPS,左側がPLに接続されている。  
| ----------- | ---------- |  
| PL Ether 0  | PS Ether 0 |  
| ----------- | ---------- |  
| PL Ether 1  | PS Ether 1 |  
| ----------- | ---------- |  
  
