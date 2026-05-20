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

IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}


def find_images(input_dir, recursive=False):
    input_dir = Path(input_dir)
    if recursive:
        files = [p for p in input_dir.rglob("*") if p.suffix.lower() in IMAGE_EXTS]
    else:
        files = [p for p in input_dir.iterdir() if p.is_file() and p.suffix.lower() in IMAGE_EXTS]
    return sorted(files)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--input_dir", required=True, help="入力画像ディレクトリ")
    ap.add_argument("--output_dir", default=str(DEFAULT_RESULTS / "dir_infer"), help="出力ディレクトリ")
    ap.add_argument("--onnx", default=str(DEFAULT_ONNX))
    ap.add_argument("--config", default=str(DEFAULT_CONFIG))
    ap.add_argument("--cache_dir", default=str(DEFAULT_CACHE))
    ap.add_argument("--cache_key", default="lraspp_mnv3_bf16_op17_512")
    ap.add_argument("--recursive", action="store_true")
    args = ap.parse_args()

    input_dir = Path(args.input_dir)
    output_dir = Path(args.output_dir)
    overlay_dir = output_dir / "overlay"
    mask_dir = output_dir / "mask"
    overlay_dir.mkdir(parents=True, exist_ok=True)
    mask_dir.mkdir(parents=True, exist_ok=True)

    files = find_images(input_dir, recursive=args.recursive)
    if not files:
        print("[WARN] no images found")
        return

    print(f"[INFO] found {len(files)} images")

    sess = build_session(
        onnx_path=args.onnx,
        config_path=args.config,
        cache_dir=args.cache_dir,
        cache_key=args.cache_key,
        report_file="lraspp_mnv3_dir_ep_report.json",
    )
    print("[INFO] providers:", sess.get_providers())

    for idx, fp in enumerate(files, 1):
        img_bgr = cv2.imread(str(fp))
        if img_bgr is None:
            print(f"[WARN] skip unreadable: {fp}")
            continue

        logits, mask_512 = infer_mask(sess, img_bgr, input_size=512)
        class_items = summarize_classes(mask_512)
        overlay, mask_orig = make_overlay(img_bgr, mask_512)
        overlay = draw_class_legend(overlay, class_items)

        rel_name = fp.stem
        out_overlay = overlay_dir / f"{rel_name}_overlay.jpg"
        out_mask = mask_dir / f"{rel_name}_mask.png"

        cv2.imwrite(str(out_overlay), overlay)
        save_mask_as_png(mask_orig, out_mask)

        print(f"[{idx}/{len(files)}] OK {fp.name}")
        for cls_id, name, ratio in class_items[:5]:
            print(f"    {name}: {ratio:.2f}%")

    print("[OK] directory inference done")


if __name__ == "__main__":
    main()