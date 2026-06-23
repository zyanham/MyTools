### Vitis AI v6.2セットアップ事前準備
Vitis AI v6.2を準備する  
基本的にAMDアカウントが必要になるので、手でダウンロードする  
(ドキュメント)[https://vitisai.docs.amd.com/projects/gen2/en/latest/index.html]  
(Github)[https://github.com/amd/Vitis-AI/tree/main]  

> mkdir license Download

実行前にLicenseディレクトリにライセンスを発行してlicense以下に配置すること。  
License発行方法は(ここ)[https://vitisai.docs.amd.com/projects/gen2/en/latest/docs/additional_information/license.html]  
  
#### SDKダウンロード  
ここからSDKファイルをダウンロードしてDownloadディレクトリに配置(SDK for cross-compilation)[https://account.amd.com/en/forms/downloads/amd-software-license-agreement-xef.html?filename=vitis_ai_2ve_sdk_v6.2.sh]  

#### ソースコード＆ビルドイメージ  
VEK385のリビジョンごとに配布。ダウンロードしてDownloadディレクトリに配置  
(RevBならここから)[https://account.amd.com/en/forms/downloads/amd-software-license-agreement-xef.html?filename=vitis_ai_2ve_prebuilt_boot_images_v6.2_RevB.tar]  
(RevAならここから)[https://account.amd.com/en/forms/downloads/amd-software-license-agreement-xef.html?filename=vitis_ai_2ve_prebuilt_boot_images_v6.2_RevA.tar]  

> mkdir -p amd/boot_images  
> tar -xvf ./Download/vitis_ai_2ve_prebuilt_boot_images_v6.2_RevB.tar -C ./amd/boot_images --strip-components=1  
> bash setup.bash  
二回目以降もsetup.bashで起動  