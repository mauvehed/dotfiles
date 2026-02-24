---
name: remove-black-bg
description: Remove black backgrounds from mauveHAUS banner images (mauveAUTH, mauveAPPS, mauveHAUS, etc.) while preserving the yin-yang symbol and all design elements. Use when asked to make a banner background transparent.
argument-hint: <input-file> [output-file]
allowed-tools: Read, Bash, Glob
---

# Remove Black Background from mauveHAUS Banners

Remove the black background from a mauveHAUS-family banner image and save it as a transparent PNG.

## Arguments

- `$0` - Input image path (required)
- `$1` - Output image path (optional, defaults to input name with `-transparent` suffix)

## Instructions

1. Read the input image `$0` to visually confirm it is a mauveHAUS-style banner (black background, yin-yang symbol, purple/mauve design elements).

2. Run the Python script below via `python3`, substituting the input and output paths. If no output path `$1` was provided, derive one by inserting `-transparent` before the `.png` extension of the input filename.

3. Read the output image to visually verify the result.

4. Report the result to the user. If the yin-yang interior was eaten away or design elements were lost, note which parameters may need tuning (see Tuning section below).

## Dependencies

Requires `Pillow` and `numpy`. Install if missing:

```
pip3 install Pillow numpy
```

## Script

```python
from PIL import Image
import numpy as np
from collections import deque


def remove_black_bg(input_path, output_path):
    img = Image.open(input_path).convert("RGBA")
    pixels = np.array(img, dtype=np.float64)
    h, w = pixels.shape[:2]
    brightness = pixels[:, :, :3].max(axis=2)

    # --- Step 1: Detect the yin-yang circle ---
    # Find very bright pixels (>200) in the left third of the image.
    # These form the purple glow ring around the yin-yang.
    very_bright = brightness > 200
    left_vb = very_bright.copy()
    left_vb[:, w // 3:] = False

    ys, xs = np.where(left_vb)
    if len(ys) > 0:
        cx_yy = int(np.median(xs))
        cy_yy = int(np.median(ys))
        dists = np.sqrt((ys.astype(float) - cy_yy) ** 2
                        + (xs.astype(float) - cx_yy) ** 2)
        # Filter outlier bright pixels (cubes far from yin-yang center)
        # before computing the glow ring radius.
        median_dist = np.median(dists)
        core = dists < 2 * median_dist
        r_yy = int(np.percentile(dists[core], 90)) + 60
    else:
        cx_yy, cy_yy, r_yy = 0, 0, 0

    Y, X = np.ogrid[:h, :w]
    dist_from_yy = np.sqrt((X - cx_yy) ** 2 + (Y - cy_yy) ** 2)
    protected = dist_from_yy < r_yy

    # --- Step 2: Flood fill from edges ---
    # BFS with 8-connectivity. Threshold must stay below the dark purple
    # gap brightness (~40+) to avoid leaking through into the cube field.
    threshold = 25
    visited = np.zeros((h, w), dtype=bool)
    background = np.zeros((h, w), dtype=bool)

    queue = deque()
    for x in range(w):
        for y in [0, h - 1]:
            if (brightness[y, x] < threshold
                    and not visited[y, x] and not protected[y, x]):
                queue.append((y, x))
                visited[y, x] = True
    for y in range(h):
        for x in [0, w - 1]:
            if (brightness[y, x] < threshold
                    and not visited[y, x] and not protected[y, x]):
                queue.append((y, x))
                visited[y, x] = True

    while queue:
        cy2, cx2 = queue.popleft()
        background[cy2, cx2] = True
        for dy in [-1, 0, 1]:
            for dx in [-1, 0, 1]:
                if dy == 0 and dx == 0:
                    continue
                ny, nx = cy2 + dy, cx2 + dx
                if 0 <= ny < h and 0 <= nx < w and not visited[ny, nx]:
                    if brightness[ny, nx] < threshold and not protected[ny, nx]:
                        visited[ny, nx] = True
                        queue.append((ny, nx))

    # --- Step 3: Build alpha channel ---
    # Only flood-filled pixels become transparent. Everything else is opaque.
    alpha = np.full((h, w), 255.0)
    alpha[background] = 0.0

    # Boundary feathering: pixels within 3px of background get graduated alpha
    distances = np.full((h, w), 999, dtype=np.int32)
    distances[background] = 0
    feather_radius = 3
    for dist in range(1, feather_radius + 1):
        prev = (distances == dist - 1)
        expanded = np.zeros((h, w), dtype=bool)
        expanded[1:, :] |= prev[:-1, :]
        expanded[:-1, :] |= prev[1:, :]
        expanded[:, 1:] |= prev[:, :-1]
        expanded[:, :-1] |= prev[:, 1:]
        new_pixels = expanded & (distances == 999)
        distances[new_pixels] = dist

    for dist in range(1, feather_radius + 1):
        feather_zone = (distances == dist) & ~background & ~protected
        feather_alpha = (dist / feather_radius) * 255.0
        alpha[feather_zone] = np.minimum(alpha[feather_zone], feather_alpha)

    pixels[:, :, 3] = alpha
    result = Image.fromarray(pixels.astype(np.uint8))
    result.save(output_path)
    print(f"Saved: {output_path}")
    print(f"  Yin-yang detected: center=({cx_yy},{cy_yy}), radius={r_yy}")
    print(f"  Background removed: {background.sum()} pixels "
          f"({100 * background.sum() / (h * w):.1f}%)")


remove_black_bg("INPUT_PATH", "OUTPUT_PATH")
```

Replace `INPUT_PATH` and `OUTPUT_PATH` with the actual file paths before running.

## Tuning

If the result is not ideal, these are the parameters to adjust in the script:

| Parameter | Default | Adjust when... |
|---|---|---|
| `threshold` (flood fill) | 25 | Increase (up to ~35) if dark remnants remain near edges. Decrease if fill leaks into design elements. Must stay well below dark purple brightness (~40+). |
| `feather_radius` | 3 | Increase for softer edges. Decrease for sharper cutoff. |
| `r_yy` padding | +60 | Increase if yin-yang edge is clipped. Decrease if too much background is protected. |
| Bright pixel threshold | 200 | Lower if the purple glow is dimmer in a variant. |

## Why this approach

The yin-yang dark half is pure black (brightness 0-1), identical to the background. No color or brightness threshold can distinguish them. The solution detects the yin-yang by its purple glow ring (with outlier filtering to avoid inflated radius from distant bright cubes), protects that circular area, then uses flood fill to identify only the true background. The threshold (25) stays well below the dark purple gap brightness (~40+) so the fill won't leak into the cube field. No brightness-based alpha ramp is applied — only flood-filled pixels become transparent, with a thin distance-based feather at the boundary for smooth edges.
