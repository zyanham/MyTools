import os
import argparse
import cv2
import numpy as np


IMAGE_EXTS = (".jpg", ".jpeg", ".png", ".bmp", ".tif", ".tiff")


def add_gaussian_noise(img, sigma, rng):
    """
    Add Gaussian noise to uint8 image.

    sigma is expressed in normal 0-255 image scale.
    Example:
        sigma=20
    """

    img_f = img.astype(np.float32)

    noise = rng.normal(
        loc=0.0,
        scale=sigma,
        size=img.shape
    ).astype(np.float32)

    noisy = img_f + noise

    # Image fileへ保存するので0～255へclip
    noisy = np.clip(noisy, 0, 255)

    return noisy.astype(np.uint8)


def get_image_files(directory, recursive=False):
    files = []

    if recursive:
        for root, _, filenames in os.walk(directory):
            for filename in filenames:
                if filename.lower().endswith(IMAGE_EXTS):
                    files.append(os.path.join(root, filename))
    else:
        for filename in os.listdir(directory):
            path = os.path.join(directory, filename)

            if (
                os.path.isfile(path)
                and filename.lower().endswith(IMAGE_EXTS)
            ):
                files.append(path)

    return sorted(files)


def main():
    parser = argparse.ArgumentParser(
        description="Add Gaussian noise to images and overwrite them."
    )

    parser.add_argument(
        "--dir",
        required=True,
        help="Directory containing calibration images"
    )

    parser.add_argument(
        "--sigma",
        type=float,
        default=None,
        help="Fixed Gaussian noise sigma, e.g. 20"
    )

    parser.add_argument(
        "--sigma_min",
        type=float,
        default=0.0,
        help="Minimum random sigma (default: 0)"
    )

    parser.add_argument(
        "--sigma_max",
        type=float,
        default=55.0,
        help="Maximum random sigma (default: 55)"
    )

    parser.add_argument(
        "--seed",
        type=int,
        default=12345,
        help="Random seed (default: 12345)"
    )

    parser.add_argument(
        "--recursive",
        action="store_true",
        help="Process subdirectories recursively"
    )

    args = parser.parse_args()

    directory = os.path.abspath(args.dir)

    if not os.path.isdir(directory):
        raise RuntimeError(f"Directory not found: {directory}")

    files = get_image_files(
        directory,
        recursive=args.recursive
    )

    if not files:
        raise RuntimeError(
            f"No images found in: {directory}"
        )

    rng = np.random.default_rng(args.seed)

    print(f"Directory : {directory}")
    print(f"Images    : {len(files)}")

    if args.sigma is not None:
        print(f"Noise     : fixed sigma={args.sigma}")
    else:
        print(
            f"Noise     : random sigma="
            f"{args.sigma_min} - {args.sigma_max}"
        )

    print("")
    print("WARNING: Images will be overwritten.")
    print("")

    for i, path in enumerate(files):

        img = cv2.imread(
            path,
            cv2.IMREAD_UNCHANGED
        )

        if img is None:
            print(f"[SKIP] Failed to load: {path}")
            continue

        # Alpha channelがあればRGB部分だけ処理
        alpha = None

        if img.ndim == 3 and img.shape[2] == 4:
            alpha = img[:, :, 3].copy()
            img = img[:, :, :3]

        if args.sigma is not None:
            sigma = args.sigma
        else:
            sigma = rng.uniform(
                args.sigma_min,
                args.sigma_max
            )

        noisy = add_gaussian_noise(
            img,
            sigma,
            rng
        )

        if alpha is not None:
            noisy = np.dstack((noisy, alpha))

        ok = cv2.imwrite(path, noisy)

        if not ok:
            print(f"[ERROR] Failed to save: {path}")
            continue

        print(
            f"[{i + 1:03d}/{len(files):03d}] "
            f"sigma={sigma:5.2f}  "
            f"{os.path.basename(path)}"
        )

    print("")
    print("Completed.")


if __name__ == "__main__":
    main()