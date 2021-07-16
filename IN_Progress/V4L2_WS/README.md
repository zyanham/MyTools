### V4L2をもう少し知りたい  
  
カメラのサポートするフォーマットを確認する  
> v4l2-ctl --list-formats  

カメラのデバイス情報を確認  
> v4l2-ctl -D    
  
カメラのプロパティ情報を確認  
> v4l2-ctl --list-ctrls  

デバイス指定でカメラのフォーマット情報を表示
> v4l2-ctl -d /dev/video0 --list-formats-ext

カメラのフレームレートを設定
> v4l2-ctl --set-parm=60

カメラの解像度、ピクセルフォーマットを設定
> v4l2-ctl --set-fmt-video=width=1920,height=1080,pixelformat=0
