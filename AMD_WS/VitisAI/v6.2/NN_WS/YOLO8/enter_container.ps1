param(
    [string]$Image = "amdih/vitis-ai:versal-2ve-release_v6.2_0612"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VaiRoot = Resolve-Path (Join-Path $ScriptDir "..\..")
$LicenseDir = Join-Path $VaiRoot "license"

docker run `
  --ulimit stack=-1:-1 `
  -it `
  --rm `
  --network host `
  -v "${LicenseDir}:/usr/licenses:ro" `
  -v "${ScriptDir}:/workspace" `
  -w /workspace `
  -e XILINXD_LICENSE_FILE=/usr/licenses/Xilinx.lic `
  --entrypoint bash `
  $Image `
  -lc "source /opt/xilinx/arm_env.bash && exec bash"
