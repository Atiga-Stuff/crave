#!/bin/bash

rm -rf .repo/local_manifests/

# ROM source repo
repo init --depth=1 -u https://github.com/LineageOS/android.git -b lineage-19.1 --git-lfs
echo "================="
echo "Repo init success"
echo "================="
echo ""

# Clone local_manifests repository
git clone --single-branch -b lineage-19.1 https://github.com/aepranata/atiga_samsung_manifests.git .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"
echo ""

# Sync the repositories
/opt/crave/resync.sh
echo "============================"
echo ""

# Fetch KernelSU
cd kernel/samsung/universal7904
git submodule init
git submodule update --recursive
cd -
echo "==================="
echo "Fetch KernelSU done"
echo "==================="
echo ""

# Build
rm -rf out/error*
rm -rf out/target/product/m20lte/lineage*.zip*
export b_date=$(date +%Y%m%d)
export s_file="out/target/product/m20lte/lineage-19.1-$b_date-UNOFFICIAL-rosy.zip"
source build/envsetup.sh
#export TARGET_INCLUDE_KSU=true
#export USE_ATIGA_STUFF=true
export BUILD_USERNAME=aepranata
export BUILD_HOSTNAME=a3-machine
brunch m20lte userdebug

if [ ! -f $(echo $s_file) ]; then
    curl -F document=@"out/error.log" "https://api.telegram.org/bot5478001056:AAFXt9jrRlb54Ttx_OtGaZ7NqNCWci_bw4o/sendDocument?chat_id=-1002452293728" >> /dev/null
    exit
fi

f_name="${s_file##*/}"
up_link=$(curl -# -F "name=$f_name" -F "file=@$s_file" -u :6e409695-e05a-4800-b3ba-afec61568a42 https://pixeldrain.com/api/file)
dl_link=$(echo $up_link | grep -Po '(?<="id":")[^"]*' | sed 's/^/https:\/\/pixeldrain.com\/u\//')
i_msg="📱 Filename: ${f_name}
📦 Download: ${dl_link}"
#curl -F document=@"out/target/product/rosy/rosy.json" "https://api.telegram.org/bot5478001056:AAFXt9jrRlb54Ttx_OtGaZ7NqNCWci_bw4o/sendDocument?chat_id=-1002452293728" -F caption="$i_msg" >> /dev/null
echo ""
