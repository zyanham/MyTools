#!/bin/bash

# 対象ディレクトリを指定する
TARGET_DIR="/home/ubuntu/SEND"

if [ -d "$TARGET_DIR" ]; then
  for dir in "$TARGET_DIR"/*; do
    if [ -d "$dir" ] && [ ! -L "$dir" ]; then
      dir_name=$(basename "$dir")
      
      echo "TARGET Directory: $dir_name"

      for file in "$TARGET_DIR"/$dir_name/velodyne_points/data/*; do
        if [ -f "$file" ]; then
          # 拡張子を取り除いたファイル名を取得
          file_name=$(basename "$file" | sed 's/\.[^.]*$//')
          
          # 変数をechoで出力
#          echo "Filename: $file_name"
#          echo "./test_bin_pointpillars  pointpillars_kitti_12000_0_pt pointpillars_kitti_12000_1_pt $TARGET_DIR/$dir_name/velodyne_points/data/$file_name.bin $TARGET_DIR/$dir_name/image_02/data/$file_name.png"
          ./test_bin_pointpillars  pointpillars_kitti_12000_0_pt pointpillars_kitti_12000_1_pt $TARGET_DIR/$dir_name/velodyne_points/data/$file_name.bin $TARGET_DIR/$dir_name/image_02/data/$file_name.png
        fi
      done

    fi
  done
else
  echo "指定されたディレクトリは存在しません。"
fi
