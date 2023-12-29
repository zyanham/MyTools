# FFMPEG使用メモ

```
# 中央から横1280:縦960でクロップ  
ffmpeg -i <input> -vf crop=w=1280:h=960 <output>  

# 縦480pixにあわせて動画を圧縮  
ffmpeg -i <input> -vf scale=-1:480 <output>  

# 動画から静止画を抜き出す  
ffmpeg -i <input> -ss <start_sec> -t <end_sec> -r <image_num/sec> -f image2 <%03d>.jpg  
Ex) ffmpeg -i IMG_2468.MOV -r 1 IMG_2468_%05d.jpg  


# 連番静止画から動画を作成する
ffmpeg -i <input> -vcodec <codec name> -q:v 1 <output>
Ex) ffmpeg -r 25 -i ./TEST01_%05d.jpg -vcodec libx264 -q:v 1 TEST06.mp4

# 動画の品質を変えずにファイル形式を変える  
ffmpeg -i TEST.MOV -q:v 1 TEST.mp4  
ffmpeg -i TEST.MOV -crf 1 TEST.mp4  

# 静止画のリサイズについて  
ffmpeg.exe -i input.jpg -vf "scale=1920:1080" -q 2 output.jpg  

# 静止画のリサイズ 横幅に合わせて高さを決定(アスペクト比キープ)  
ffmpeg.exe -i input.jpg -vf "scale=1920:-1" -q 2 output.jpg  
```
