#!/usr/bin/env bash
# Regenerates every store and website image from the real app widgets.
# Run after a noticeable UI change:  ./tool/store/generate.sh
# Needs `cwebp` (brew install webp); `sips` ships with macOS.
set -euo pipefail
cd "$(dirname "$0")/../.."

icon=assets/icons/app_icon_source.png
site=website/assets

flutter test tool/store/store_assets_test.dart

# Website: screenshots as WebP, social card as JPEG, icons.
mkdir -p "$site/screens"
for png in build/store/screens/*.png; do
  cwebp -quiet -q 82 "$png" -o "$site/screens/$(basename "${png%.png}").webp"
done
sips -s format jpeg -s formatOptions 88 build/store/og.png --out "$site/og.jpg" >/dev/null
cwebp -quiet -q 90 -resize 192 192 "$icon" -o "$site/icon.webp"
sips -s format png -z 180 180 "$icon" --out "$site/apple-touch-icon.png" >/dev/null
sips -s format png -z 32 32 "$icon" --out "$site/favicon-32.png" >/dev/null

echo "Store images in store/, website images in $site/"
