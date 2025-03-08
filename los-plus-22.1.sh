#!/bin/bash

rm -rf .repo/local_manifests/

# ROM source repo
repo init --depth=1 -u https://github.com/LineageOS/android.git -b lineage-22.1 --git-lfs
echo "================="
echo "Repo init success"
echo "================="
echo ""

# Clone local_manifests repository
git clone --single-branch -b lineage-plus-22.1 https://github.com/aepranata/atiga_manifests.git .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"
echo ""

# Sync the repositories
/opt/crave/resync.sh
echo "============================"
echo ""

# Fetch KernelSU
cd kernel/xiaomi/rosy
git submodule init
git submodule update --recursive
echo "==================="
echo "Fetch KernelSU done"
echo "==================="
echo ""

# Build
rm -rf out/error*
rm -rf out/target/product/rosy/lineage*.zip*
export b_date=$(date +%Y%m%d)
export s_file="out/target/product/rosy/lineage-22.1-$b_date-UNOFFICIAL-rosy.zip"
source build/envsetup.sh
export BUILD_USERNAME=aepranata
export BUILD_HOSTNAME=a3-machine
brunch rosy

if [ ! -f $(echo $s_file) ]; then
    curl -F document=@"out/error.log" "https://api.telegram.org/bot5478001056:AAFXt9jrRlb54Ttx_OtGaZ7NqNCWci_bw4o/sendDocument?chat_id=-1002452293728" >> /dev/null
    exit
fi

f_name="${s_file##*/}"
up_link=$(curl -# -F "name=$f_name" -F "file=@$s_file" -u :61cc8d61-25e3-4681-9472-aed928805267 https://pixeldrain.com/api/file)
dl_link=$(echo $up_link | grep -Po '(?<="id":")[^"]*' | sed 's/^/https:\/\/pixeldrain.com\/u\//')
i_msg="📱 Filename: ${f_name}
📦 Download: ${dl_link}"
curl -F document=@"out/target/product/rosy/rosy.json" "https://api.telegram.org/bot5478001056:AAFXt9jrRlb54Ttx_OtGaZ7NqNCWci_bw4o/sendDocument?chat_id=-1002452293728" -F caption="$i_msg" >> /dev/null
echo ""
