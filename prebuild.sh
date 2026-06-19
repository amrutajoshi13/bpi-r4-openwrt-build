#!/bin/sh
cd /build/openwrt
 
echo "=== Killing any stuck faked processes ==="
killall -9 faked 2>/dev/null
sleep 2
 
# --------------------------------------------------------
# Step 0A — Restore custom feeds.conf.default
# --------------------------------------------------------
if [ -f "/build/feeds.conf.default.custom" ]; then
    echo "=== Restoring custom feeds.conf.default ==="
    cp /build/feeds.conf.default.custom feeds.conf.default
    echo "=== feeds.conf.default restored ==="
else
    echo "=== No custom feeds.conf found, using default ==="
fi
 
# --------------------------------------------------------
# Step 0B — Copy relysyspackages into build tree
# --------------------------------------------------------
if [ -d "/build/relysyspackages" ]; then
    echo "=== Copying relysyspackages ==="
    cp -r /build/relysyspackages package/
    echo "=== relysyspackages copied ==="
    ls package/relysyspackages/
else
    echo "=== No relysyspackages found, skipping ==="
fi
 
# --------------------------------------------------------
# Step 0C — Update and install all feeds
# --------------------------------------------------------
echo "=== Updating all feeds ==="
./scripts/feeds update -a
./scripts/feeds install -a
 
# --------------------------------------------------------
# Step 0D — Restore build config
# --------------------------------------------------------
if [ -f "/build/bpi-r4-custom.config" ]; then
    echo "=== Restoring build config ==="
    cp /build/bpi-r4-custom.config .config
    make defconfig
fi
 
# --------------------------------------------------------
# Step 1 — Build toolchain
# --------------------------------------------------------
echo "=== Building toolchain ==="
make toolchain/compile -j1 || exit 1
echo "=== Toolchain OK ==="
 
# --------------------------------------------------------
# Step 2 — Fix fakeroot deadlock
# --------------------------------------------------------
echo "=== Fixing fakeroot ==="
printf '#!/bin/sh\nexec "$@"\n' > staging_dir/host/bin/fakeroot
printf '#!/bin/sh\nexit 0\n' > staging_dir/host/bin/faked
chmod +x staging_dir/host/bin/fakeroot
chmod +x staging_dir/host/bin/faked
 
# --------------------------------------------------------
# Step 3 — Pre-build cmake host packages
# --------------------------------------------------------
echo "=== Pre-building host packages ==="
rm -rf build_dir/hostpkg/json-c*
rm -rf build_dir/hostpkg/libubox*
rm -rf build_dir/hostpkg/opkg*
rm -f staging_dir/host/stamp/.json-c*
rm -f staging_dir/host/stamp/.libubox*
rm -f staging_dir/hostpkg/stamp/.opkg*
 
make package/libs/libjson-c/host/compile -j1 || exit 1
echo "=== libjson-c OK ==="
make package/libs/libubox/host/compile -j1 || exit 1
echo "=== libubox OK ==="
make package/system/opkg/host/compile -j1 || exit 1
echo "=== opkg OK ==="
 
# Re-apply fakeroot fix
killall -9 faked 2>/dev/null
printf '#!/bin/sh\nexec "$@"\n' > staging_dir/host/bin/fakeroot
printf '#!/bin/sh\nexit 0\n' > staging_dir/host/bin/faked
chmod +x staging_dir/host/bin/fakeroot
chmod +x staging_dir/host/bin/faked
 
# --------------------------------------------------------
# Step 4 — Full build
# --------------------------------------------------------
echo "=== Starting full build ==="
make -j1 2>&1 | tee /build/build_log.txt
