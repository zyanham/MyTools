convert test.bmp -crop 1920x1080+10+10 -compress none test.ppm  

### フォルダ以下のHEICをJPGに変換する  
mogrify -format jpg *.HEIC  
