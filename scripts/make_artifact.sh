#!/bin/bash
set -e

ARTIFACT_NAME="Rust_Offline_Universal"
OUT_DIR="$HOME/storage/shared/Archives"
STAGING_DIR="rust_staging"

mkdir -p "$OUT_DIR" "$STAGING_DIR"

echo "[*] initializing Staging Area..."
cp rust_kit.py "$STAGING_DIR/"
cp rsb.py "$STAGING_DIR/"
chmod +x "$STAGING_DIR"/*.py

echo "[*] Running Multi-OS Sync (This may take time)..."
cd "$STAGING_DIR"
python3 rust_kit.py sync_all
cd ..

echo "[*] Generating Signing Key..."

cat > gen-key-script <<EOF
%echo Generating a basic OpenPGP key
Key-Type: RSA
Key-Length: 2048
Subkey-Type: RSA
Subkey-Length: 2048
Name-Real: Offline Rust Kit
Name-Email: offline@suckless.local
Expire-Date: 0
%no-protection
%commit
%echo done
EOF
gpg --batch --generate-key gen-key-script
rm gen-key-script

echo "[*] Compressing Payload..."
tar -cJf payload.tar.xz "$STAGING_DIR"

echo "[*] Signing Payload..."
gpg --armor --detach-sign --output payload.tar.xz.asc payload.tar.xz

echo "[*] Creating Self-Extracting Installer..."

cat > install_stub.sh <<'EOF'

echo "=== Universal Offline Rust Installer ==="
echo "[*] Verifying Integrity..."


SKIP=$(awk '/^__PAYLOAD_BELOW__/ {print NR + 1; exit 0; }' $0)
tail -n +$SKIP $0 > payload.tar.xz


if command -v gpg >/dev/null; then
    
    echo "[!] GPG found, but skipping ring check in this stub."
else
    echo "[!] GPG not found. Skipping verification."
fi

echo "[*] Extracting..."
tar -xf payload.tar.xz
cd rust_staging

echo "[*] Starting Deployment..."
python3 rust_kit.py deploy

echo "[+] Done. You can now use 'python3 rsb.py' to build your projects."
exit 0
__PAYLOAD_BELOW__
EOF


cat install_stub.sh payload.tar.xz > "$OUT_DIR/$ARTIFACT_NAME.run"
chmod +x "$OUT_DIR/$ARTIFACT_NAME.run"


rm -rf "$STAGING_DIR" payload.tar.xz payload.tar.xz.asc install_stub.sh

echo "[SUCCESS] Artifact created: $OUT_DIR/$ARTIFACT_NAME.run"
