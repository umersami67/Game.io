#!/usr/bin/env bash
set -e

GODOT_VERSION="4.3"
GODOT_TAG="${GODOT_VERSION}-stable"

GODOT_ZIP="Godot_v${GODOT_TAG}_linux.x86_64.zip"
GODOT_BIN="Godot_v${GODOT_TAG}_linux.x86_64"
TEMPLATES="Godot_v${GODOT_TAG}_export_templates.tpz"

DOWNLOAD_BASE="https://github.com/godotengine/godot/releases/download/${GODOT_TAG}"

echo "=== Preparing THE TENANT Web build ==="

rm -rf web
mkdir -p web
mkdir -p .godot-render

echo "=== Downloading Godot ${GODOT_VERSION} ==="

curl -fL \
  "${DOWNLOAD_BASE}/${GODOT_ZIP}" \
  -o "/tmp/${GODOT_ZIP}"

unzip -q "/tmp/${GODOT_ZIP}" -d .godot-render

chmod +x ".godot-render/${GODOT_BIN}"

echo "=== Downloading Godot export templates ==="

curl -fL \
  "${DOWNLOAD_BASE}/${TEMPLATES}" \
  -o "/tmp/${TEMPLATES}"

rm -rf /tmp/godot_export_templates
mkdir -p /tmp/godot_export_templates

unzip -q "/tmp/${TEMPLATES}" -d /tmp/godot_export_templates

TEMPLATE_DIR="$HOME/.local/share/godot/export_templates/${GODOT_VERSION}.stable"

mkdir -p "$TEMPLATE_DIR"

cp -R /tmp/godot_export_templates/templates/. "$TEMPLATE_DIR/"

echo "=== Importing project ==="

".godot-render/${GODOT_BIN}" \
  --headless \
  --editor \
  --path . \
  --quit

echo "=== Exporting Web version ==="

".godot-render/${GODOT_BIN}" \
  --headless \
  --path . \
  --export-release "Web" \
  web/index.html

echo "=== Checking export ==="

if [ ! -f "web/index.html" ]; then
    echo "ERROR: web/index.html was not generated."
    exit 1
fi

echo "================================="
echo "THE TENANT Web export successful"
echo "================================="

ls -lah web
