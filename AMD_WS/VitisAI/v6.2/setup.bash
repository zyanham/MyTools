# このbashを実行したカレントディレクトリを作業ディレクトリにする
WORK_DIR="$(pwd)"
DOWNLOAD_DIR="$WORK_DIR/Download"
LICENSE_DIR="$WORK_DIR/license"

DOCKER_IMAGE="amdih/vitis-ai:versal-2ve-release_v6.2_0612"
VITIS_AI_TAG="vai_6.2-GA-release-06122026"

VITIS_AI_ARCHIVE="$DOWNLOAD_DIR/Vitis-AI-${VITIS_AI_TAG}.tar.gz"
VITIS_AI_URL="https://github.com/amd/Vitis-AI/archive/refs/tags/${VITIS_AI_TAG}.tar.gz"
VITIS_AI_EXTRACTED_DIR="$WORK_DIR/Vitis-AI-${VITIS_AI_TAG}"
VITIS_AI_DIR="$WORK_DIR/Vitis-AI"

# Vitis AI 6.2 Dockerイメージ取得
docker pull "$DOCKER_IMAGE"

# Vitis AI 6.2 GAソースをDownloadへ保存
if [ ! -f "$VITIS_AI_ARCHIVE" ]; then
    wget \
        -O "$VITIS_AI_ARCHIVE" \
        "$VITIS_AI_URL"
fi

# カレントディレクトリへ展開
if [ ! -d "$VITIS_AI_DIR" ]; then
    tar -xzf "$VITIS_AI_ARCHIVE" -C "$WORK_DIR"

    if [ -d "$VITIS_AI_EXTRACTED_DIR" ]; then
        mv "$VITIS_AI_EXTRACTED_DIR" "$VITIS_AI_DIR"
    fi
fi

# Docker起動
# licenses/Xilinx.lic にAIE-MLv2ライセンスを配置しておく
docker run \
    --ulimit stack=-1:-1 \
    -it \
    --rm \
    --network host \
    -v "$LICENSE_DIR:/usr/licenses:ro" \
    -v "$WORK_DIR:/workspace" \
    -w /workspace \
    -e XILINXD_LICENSE_FILE=/usr/licenses/Xilinx.lic \
    --entrypoint bash \
    "$DOCKER_IMAGE" \
    -lc "source /opt/xilinx/arm_env.bash && exec bash"
