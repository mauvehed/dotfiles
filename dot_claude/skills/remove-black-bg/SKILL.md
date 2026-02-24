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
        r_yy = int(np.percentile(dists, 90)) + 10
    else:
        cx_yy, cy_yy, r_yy = 0, 0, 0

    Y, X = np.ogrid[:h, :w]
    dist_from_yy = np.sqrt((X - cx_yy) ** 2 + (Y - cy_yy) ** 2)
    protected = dist_from_yy < r_yy

    # --- Step 2: Flood fill from edges ---
    # BFS with 8-connectivity. Threshold 48 avoids leaking through
    # the purple glow barriers around design elements.
    threshold = 48
    visited = np.zeros((h, w), dtype=bool)
    background = np.zeros((h, w), dtype=bool)

    queue = deque()
    for x in range(w):
        for y in [0, h - 1]:
            if brightness[y, x] < threshold and not visited[y, x]:
                queue.append((y, x))
                visited[y, x] = True
    for y in range(h):
        for x in [0, w - 1]:
            if brightness[y, x] < threshold and not visited[y, x]:
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
                    if brightness[ny, nx] < threshold:
                        visited[ny, nx] = True
                        queue.append((ny, nx))

    # --- Step 3: Build alpha channel ---
    alpha = np.full((h, w), 255.0)
    alpha[background] = 0.0

    # Outside protected zone: brightness-based alpha
    low, high = 15, 50
    unprotected = ~protected & ~background
    bright_alpha = np.clip((brightness - low) / (high - low) * 255.0, 0, 255)
    alpha[unprotected] = np.minimum(alpha[unprotected],
                                     bright_alpha[unprotected])

    # Inside protected zone near boundary: smooth 4px transition
    distances = np.full((h, w), 999, dtype=np.int32)
    distances[background] = 0
    for dist in range(1, 5):
        prev = (distances == dist - 1)
        expanded = np.zeros((h, w), dtype=bool)
        expanded[1:, :] |= prev[:-1, :]
        expanded[:-1, :] |= prev[1:, :]
        expanded[:, 1:] |= prev[:, :-1]
        expanded[:, :-1] |= prev[:, 1:]
        new_pixels = expanded & (distances == 999)
        distances[new_pixels] = dist

    for dist in range(1, 5):
        in_zone = (distances == dist) & protected
        zone_thresh = 45 + dist * 13
        dark_in_zone = in_zone & (brightness < zone_thresh)
        dist_factor = dist / 4.0
        bright_factor = np.clip(brightness / zone_thresh, 0, 1)
        combined = (np.clip(dist_factor * 0.4 + bright_factor * 0.6, 0, 1)
                    * 255.0)
        alpha[dark_in_zone] = np.minimum(alpha[dark_in_zone],
                                          combined[dark_in_zone])

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
| `threshold` (flood fill) | 48 | Increase if dark remnants remain near edges. Decrease if fill leaks into design. |
| `low` (alpha ramp) | 15 | Increase if dark purple design pixels outside the yin-yang are being removed. |
| `high` (alpha ramp) | 50 | Increase for softer transitions. Decrease for sharper cutoff. |
| `r_yy` padding | +10 | Increase if yin-yang edge is clipped. Decrease if too much background is protected. |
| Bright pixel threshold | 200 | Lower if the purple glow is dimmer in a variant. |

## Why this approach

The yin-yang dark half is pure black (brightness 0-1), identical to the background. No color or brightness threshold can distinguish them. The solution detects the yin-yang by its purple glow ring, protects that circular area, then uses brightness-based transparency everywhere else. The flood fill from edges handles the bulk of the background, while the brightness ramp catches interior dark pockets between cubes that the flood fill can't reach through bright barriers.
