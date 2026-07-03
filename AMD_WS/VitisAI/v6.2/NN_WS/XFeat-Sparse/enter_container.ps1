param(
    [string]$Image = "amdih/vitis-ai:versal-2ve-release_v6.2_0612"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$NnWsRoot = Resolve-Path (Join-Path $ScriptDir "..")
$VaiRoot = Resolve-Path (Join-Path $ScriptDir "..\..")
$LicenseDir = Join-Path $VaiRoot "license"

docker run `
  --ulimit stack=-1:-1 `
  -it `
  --rm `
  --network host `
  -v "${LicenseDir}:/usr/licenses:ro" `
  -v "${NnWsRoot}:/nn_ws" `
  -w /nn_ws/XFeat-Sparse `
  -e XILINXD_LICENSE_FILE=/usr/licenses/Xilinx.lic `
  --entrypoint /bin/bash `
  $Image `
  -lc "exec bash"
