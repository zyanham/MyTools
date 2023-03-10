FFMPEG使用メモ

中央から横1280:縦960でクロップ  
```
ffmpeg -i <input> -vf crop=w=1280:h=960 <output>
```

縦480pixにあわせて動画を圧縮  
```
ffmpeg -i <input> -vf scale=-1:480 <output>
```

動画から静止画を抜き出す  
```
ffmpeg -i <input> -ss <start_sec> -t <end_sec> -r <image_num/sec> -f image2 <%03d>.jpg

例)
ffmpeg -i IMG_2468.MOV -r 1 IMG_2468_%05d.jpg
```

動画の品質を変えずにファイル形式を変える  
```
ffmpeg -i TEST.MOV -q:v 1 TEST.mp4
ffmpeg -i TEST.MOV -crf 1 TEST.mp4
```
