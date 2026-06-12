#!/bin/sh
cd /build/openwrt
 
echo "=== Fixing fakeroot ==="
printf '#!/bin/sh\nexec "$@"\n' > staging_dir/host/bin/fakeroot
printf '#!/bin/sh\nexit 0\n' > staging_dir/host/bin/faked
chmod +x staging_dir/host/bin/fakeroot staging_dir/host/bin/faked
 
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
 
echo "=== All host packages ready. Starting full build ==="
make -j1 2>&1 | tee /build/build_log.txt
