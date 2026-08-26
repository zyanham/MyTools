import argparse
from pathlib import Path
import cv2
import numpy as np

from lraspp_utils import (
    build_session,
    infer_mask,
    make_overlay,
    summarize_classes,
    draw_class_legend,
    save_mask_as_png,
)

ROOT = Path(__file__).resolve().parent
DEFAULT_ONNX = ROOT / "weights" / "lraspp_mobilenetv3_large_op17_1x3x512x512.onnx"
DEFAULT_CONFIG = ROOT / "vai_ep_config.json"
DEFAULT_CACHE = ROOT / "cache"
DEFAULT_RESULTS = ROOT / "results"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", required=True, help="入力画像パス")
    ap.add_argument("--output_dir", default=str(DEFAULT_RESULTS), help="出力ディレクトリ")
    ap.add_argument("--onnx", default=str(DEFAULT_ONNX))
    ap.add_argument("--config", default=str(DEFAULT_CONFIG))
    ap.add_argument("--cache_dir", default=str(DEFAULT_CACHE))
    ap.add_argument("--cache_key", default="lraspp_mnv3_bf16_op17_512")
    ap.add_argument("--show", action="store_true")
    args = ap.parse_args()

    input_path = Path(args.input)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    img_bgr = cv2.imread(str(input_path))
    if img_bgr is None:
        raise FileNotFoundError(f"Failed to read image: {input_path}")

    sess = build_session(
        onnx_path=args.onnx,
        config_path=args.config,
        cache_dir=args.cache_dir,
        cache_key=args.cache_key,
        report_file="lraspp_mnv3_image_ep_report.json",
    )

    print("[INFO] providers:", sess.get_providers())
    logits, mask_512 = infer_mask(sess, img_bgr, input_size=512)

    print("[INFO] logits:", logits.shape, logits.dtype)
    print("[INFO] nan:", np.isnan(logits).any(), "inf:", np.isinf(logits).any())

    class_items = summarize_classes(mask_512)
    print("[INFO] detected classes:")
    for cls_id, name, ratio in class_items:
        print(f"  {cls_id:2d}: {name:12s} {ratio:6.2f}%")

    overlay, mask_orig = make_overlay(img_bgr, mask_512)
    overlay = draw_class_legend(overlay, class_items)

    stem = input_path.stem
    out_overlay = output_dir / f"{stem}_overlay.jpg"
    out_mask = output_dir / f"{stem}_mask.png"

    cv2.imwrite(str(out_overlay), overlay)
    save_mask_as_png(mask_orig, out_mask)

    print("[OK] saved:", out_overlay)
    print("[OK] saved:", out_mask)

    if args.show:
        cv2.imshow("LRASPP Overlay", overlay)
        cv2.waitKey(0)
        cv2.destroyAllWindows()


if __name__ == "__main__":
    main()