#!/bin/sh
# Install age with full Sigsum transparency log verification
# Works on Linux, FreeBSD, Alpine, and macOS

# Determine OS and architecture using uname
os=$(uname -s | tr '[:upper:]' '[:lower:]')
arch=$(uname -m)

# Normalize OS name for age's naming convention
case "$os" in
    linux)   os="linux" ;;
    darwin)  os="darwin" ;;
    freebsd) os="freebsd" ;;
    *)
        echo "Unsupported operating system: $os"
        exit 1
        ;;
esac

# Normalize architecture name
# Handle both x86_64 and ARM variants
case "$arch" in
    x86_64|amd64)   arch="amd64" ;;
    aarch64|arm64)  arch="arm64" ;;
    armv7l)         arch="arm" ;;
    i686|i386)      arch="386" ;;
    *)
        echo "Unsupported architecture: $arch"
        exit 1
        ;;
esac

target="${os}/${arch}"
base_url="https://dl.filippo.io/age"
install_dir="/usr/local/bin"

echo "=== Detected platform: ${target} ==="

echo "=== Downloading latest age ==="
# Use -J to use server-suggested filename, which includes the version number
# Capture the actual filename to determine version
archive=$(curl -JLO --write-out '%{filename_effective}' \
    "${base_url}/latest?for=${target}")
proof_file="${archive}.proof"

curl -JLO "${base_url}/latest?for=${target}&proof"

# Extract version from filename for display
version=$(echo "$archive" | sed 's/age-\(v[0-9.]*\)-.*/\1/')
echo "=== Downloaded age ${version} ==="

echo "=== Setting up Sigsum verification ==="
# Public keys from https://github.com/FiloSottile/age/blob/main/SIGSUM.md
# Verify these against the canonical source before running this script
cat << 'EOF' > age-sigsum-key.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM1WpnEswJLPzvXJDiswowy48U+G+G1kmgwUE2eaRHZG
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAz2WM5CyPLqiNjk7CLl4roDXwKhQ0QExXLebukZEZFS
EOF

echo "=== Installing sigsum-verify ==="
go install sigsum.org/sigsum-go/cmd/sigsum-verify@latest
sigsum_verify="$(go env GOPATH)/bin/sigsum-verify"

echo "=== Verifying Sigsum proof ==="
"$sigsum_verify" \
    -k age-sigsum-key.pub \
    -P sigsum-generic-2025-1 \
    "$proof_file" < "$archive" || {
    echo "=== Sigsum verification FAILED - aborting ==="
    rm -f "$archive" "$proof_file" age-sigsum-key.pub
    exit 1
}

echo "=== Sigsum verification PASSED ==="
echo "=== Installing age binaries ==="
tar xzf "$archive"

# Alpine uses doas, everything else uses sudo.
command -v doas
if [ $? = 0 ]; then
	doas cp age/age* "$install_dir/"
else
	sudo cp age/age* "$install_dir/"
fi

echo "=== Cleanup ==="
rm -rf age/ "$archive" "$proof_file" age-sigsum-key.pub

echo "=== age installed successfully ==="
age --version  && echo "Yay! You've successfully installed age."
