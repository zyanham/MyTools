## Install For Yocto Project
sudo apt install -y gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint xterm python3-subunit mesa-common-dev zstd liblz4-tool make python3-pip bmap-tools

sudo pip3 install sphinx sphinx_rtd_theme pyyaml

if [ ! -d "./poky" ]; then
  git clone -b kirkstone https://github.com/yoctoproject/poky.git
else
  echo "pokyがおありになりましたのでgit cloneをスキップしますわ"
fi

## ENV Setting
source poky/oe-init-build-env

## get meta-raspberrypi
bitbake-layers layerindex-fetch meta-raspberrypi

## Raspberry Pi Zero2 W Setting
#vim conf/local.conf
#  => MACIHNE = "raspberrypi0-2w-64"

# 処理対象のテキストファイル名
file_name="conf/local.conf"

# 一時ファイル名
temp_file=$(mktemp)

# ファイル内容を一行ずつ読み込み処理
while IFS= read -r line; do
  # "MACHINE"で始まる行を判定
  if [[ ${line:0:7} == "MACHINE" ]]; then
    # 行頭に"#"を追加
    echo "#${line}" >> "$temp_file"
    # 次の行に"MACHINE=XX"を追加
    echo 'MACHINE = "raspberrypi0-2w-64"' >> "$temp_file"
  else
    # その他の行はそのまま出力
    echo "$line" >> "$temp_file"
  fi
done < "$file_name"

# 元のファイルをバックアップ（必要であれば）
cp "$file_name" "$file_name.bak"

# 一時ファイルの内容で元のファイルを更新
mv "$temp_file" "$file_name"

bitbake core-image-minimal
cd tmp/deploy/images/raspberrypi0-2w-64

