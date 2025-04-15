#!/bin/bash

# 引数チェック
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_dir_A> <destination_dir_B>"
    exit 1
fi

DIR_A="$1"
DIR_B="$2"

# Bディレクトリがなければ作成
mkdir -p "$DIR_B"

# PDFファイルを再帰的に検索
find "$DIR_A" -type f -name '*.pdf' | while read -r pdf_path; do
    # ファイル名と拡張子を分解
    filename=$(basename "$pdf_path" .pdf)
    parent_dir=$(basename "$(dirname "$pdf_path")")
    
    # 新しいファイル名の基本形：doc_dir2.pdf
    new_name="${filename}_${parent_dir}.pdf"
    dest_path="${DIR_B}/${new_name}"

    # 名前が重複していたら連番を追加
    counter=1
    while [ -e "$dest_path" ]; do
        new_name="${filename}_${parent_dir}_$counter.pdf"
        dest_path="${DIR_B}/${new_name}"
        ((counter++))
    done

    # コピー実行
    cp "$pdf_path" "$dest_path"
done

