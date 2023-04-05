******************************************************  
Vivado v2020.2  
  
Digilentのリファレンス・プロジェクトを文字起こし  
******************************************************  
  
Create Project  
Board file -> [Zybo Z7-20]を選択  
  
IP CatalogでDigilentのファイルを[Add repository]  
  
[Create Block Design]でIPIを作成  
  
■[ZYNQ7 Processing System]を呼び出し  
->[Run Block Automation]でPresetを実施  
->I2C0を有効化してEMIOで選択する  
->PS-PL Configuration -> [HP Slave AXI Interface] -> [S AXI HP0 interface]を有効  
->FCLK_CLK0を有効化 IO PLL 100MHz  
->FCLK_CLK1を有効化 DDR PLL 134MHz  
->FCLK_CLK2を有効化 IO PLL 200MHz  
Fabric Interruptsを有効化して[PL-PS Interrupt Ports]->IRQ_F2Pをチェックする  
IIC_0を[Make External]を実施。端子名を[hdmi_out_ddc]に変更する  
  
■[AXI GPIO]を呼び出し  
->名称を[axi_gpio_video]と設定  
->Enable Dual Channelを設定  
->GPIOを[All Outputs]に設定し、ビット幅を1に設定する  
->GPIO2を[All Inputs]に設定し、ビット幅を1に設定する  
->Enable Interruptを設定  
->Make External -> GPIO_0をhdmi_in_hpdに名称変更  
->Boardタグからhdmi_in_hpdを端子に関連付ける  
  
■[RGB to DVI Video Encoder(source)]を呼び出し  
->BoardタグからHDMI outを持ってきてrgb2dviを呼び出す。  
Reset active high  
Generate SerialClk internally from pixel clock  
のチェックを外す  
  
■[AXI4-Stream to Video out]を呼び出し  
FIFO DEPTHを1024->4096  
Clock Mode [Common -> Independent]  
Timing Mode [Slave -> Master]  
に設定する  
  
■[AXI Video Direct Memory Access]  
Basicタグより  
[Enable Write Channel]  
Frame Buffers 3->4  
Write Burst Size 8->32  
Line Buffer Depth 512->2048  
  
[Enable Read Channel]  
Stream Data WIdth 32->24  
Line Buffer Depth 512->2048  
  
  
■[AXI4 Stream Subset Converter]を呼び出す  
スクリーンショット参照  
axis_subset_converter_outに名称を変更  
  
  
■[Video Timing Controller]を呼び出す  
名称をv_tc_outに変更する  
Enable Detectionをチェックを外す  
  
■[Video Timing Controller]を呼び出す  
名称をv_tc_inに変更する  
Enable Generationをチェックを外す  
Detection OptionsのVertical Blank Detection, Horizontal Blank Detectionをはずす  
  
■[AXI Interconnect]を呼び出す  
名称をaxi_interconnect_gp0に変更する  
Number of Master Interfacesを2->5に変更  
  
■[AXI4 Stream Subset Converter]を呼び出す  
スクリーンショット参照  
axis_subset_converter_inに名称を変更  
  
■[Video In to AXI4-Stream]を呼び出す  
FIFO DEPTHを1024->4096  
Clock Mode [Common -> Independent]  
に設定する  
  
■[Concat]を呼び出す  
Number of Ports 2->5  
  
■[Processor System Reset]を2つ呼び出す  
名称をproc_sys_reset_fclk0, proc_sys_reset_fclk1  
  
■[Constant]を呼び出す  
名称をsubset_converter_reset  
  
■[Processor System Reset]を呼び出す  
名称をproc_sys_reset_0  
  
■[AXI Interconnect]を呼び出す  
名称をaxi_interconnect_hp0に変更する  
Number of Slave Interfaces 1->2  
Number of Master Interfaces 2->1  
  
■[DVI to RGB Video Decoder(sink)]を呼び出し  
->BoardタグからHDMI inを持ってきてdvi2rgbを呼び出す。  
Reset active high  
Add BUFG to PixelCLK  
のチェックを外す  
  
******************************************************  
******************************************************  
  
