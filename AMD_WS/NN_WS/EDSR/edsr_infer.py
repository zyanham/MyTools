import torch
from model import edsr
from PIL import Image
from torchvision.transforms import ToTensor, ToPILImage
import sys
import matplotlib.pyplot as plt
from types import SimpleNamespace  # これを追加！
from torchvision.transforms.functional import to_pil_image

# パラメータ設定
scale = 2
model_path = f"../Models/EDSR/EDSR_x{scale}.pt"

# argsをSimpleNamespaceで包む
#args = SimpleNamespace(
#    scale=scale,
#    n_resblocks=16,
#    n_feats=256,
#    res_scale=1.0,
#    n_colors=3,
#    rgb_range=255
#)
args = SimpleNamespace(
    scale=[2],
    n_resblocks=32,
    n_feats=256,
    res_scale=0.1,
    n_colors=3,
    rgb_range=255
)



# モデル構築と読み込み
model = edsr.make_model(args)
model.load_state_dict(torch.load(model_path, map_location='cpu'), strict=False)
model.eval()

# 入力画像
image_path = sys.argv[1] if len(sys.argv) > 1 else 'input.png'
image = Image.open(image_path).convert("RGB")
input_tensor = ToTensor()(image).unsqueeze(0)

# 推論
with torch.no_grad():
    output = model(input_tensor).clamp(0, 1)

# 出力を画像に変換
output_tensor = (output.squeeze(0).cpu() * 255.0).clamp(0, 255).byte()
output_image = to_pil_image(output_tensor)

# 表示と保存
output_image.show()
output_image.save(f"output_x{scale}.png")
