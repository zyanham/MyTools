#!/bin/bash

TARGET_DIR="./"

if [ ! -d "$TARGET_DIR" ]; then
    echo "ディレクトリがありません"
    exit 1
fi

#cd "$TARGET_DIR" || exit 1

count=1
find . -maxdepth 1 -type f -name "*.jpg" | sort | while IFS= read -r file; do
    base_file=$(basename "$file")
    new_name=$(printf "%05d.jpg" "$count")

    mv -- "$base_file" "$new_name"
    echo "Renamed '$base_file' to '$new_name'"
    count=$((count + 1))
done

if [ "$count" -eq 1 ]; then
    echo "jpgファイルが見つかりませんでした"
else
    echo "リネームが完了しました"
fi

