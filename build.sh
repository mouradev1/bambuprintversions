#!/bin/bash
set -e

VERSION="${1:-1.0.0}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT/cliente"
ZIP_NAME="bambuprint-setup.zip"

echo "=== Bambu Print Build v${VERSION} ==="
echo ""

# 1. Build Vue UI
echo "[1/4] Building Vue UI..."
cd "$ROOT/ui"
npm run build

# 2. Build Go para Windows
echo "[2/4] Building Go for Windows (amd64)..."
cd "$ROOT"
GOOS=windows GOARCH=amd64 CGO_ENABLED=0 \
  go build -ldflags="-H=windowsgui -s -w" \
  -o "$OUT_DIR/bambuprint.exe" ./cmd/bambuprint/

# 3. Criar ZIP
echo "[3/4] Creating ZIP..."
cd "$OUT_DIR"
rm -f "$ZIP_NAME"
zip -9 "$ZIP_NAME" bambuprint.exe bambu.ico bambu.png

# 4. Limpar exe (só fica o zip)
echo "[4/4] Cleaning up..."
rm -f "$OUT_DIR/bambuprint.exe"

echo ""
echo "=== Build complete ==="
echo "  Version:  v${VERSION}"
echo "  Output:   $OUT_DIR/$ZIP_NAME"
echo "  Size:     $(du -h "$ZIP_NAME" | cut -f1)"
echo ""
echo "Next steps:"
echo "  cd cliente"
echo "  git add bambuprint-setup.zip && git commit -m 'v${VERSION}'"
echo "  git tag v${VERSION} && git push && git push --tags"
echo "  gh release create v${VERSION} bambuprint-setup.zip --title 'v${VERSION}'"
