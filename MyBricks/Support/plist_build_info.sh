#!/bin/sh

info_plist="${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/Info.plist"

buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$info_plist")
buildNumber=$(($buildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$info_plist"

build_time=`date "+%Y-%m-%d %H:%M:%S %Z"`
/usr/libexec/PlistBuddy -c "Add :BuildDate string '${build_time}'" "${info_plist}"
/usr/libexec/PlistBuddy -c "Set :BuildDate '${build_time}'" "${info_plist}"

git_version=$(git log -1 --format="%hq")
git_branch=$(git symbolic-ref --short -q HEAD)
git_tag=$(git describe --tags --exact-match 2>/dev/null)
git_branch_or_tag="${git_branch:-${git_tag}}"

/usr/libexec/PlistBuddy -c "Add :GitBranch string '${git_branch_or_tag}'" "${info_plist}"
/usr/libexec/PlistBuddy -c "Set :GitBranch '${git_branch_or_tag}'" "${info_plist}"
/usr/libexec/PlistBuddy -c "Add :GitVersion string '${git_version}'" "${info_plist}"
/usr/libexec/PlistBuddy -c "Set :GitVersion '${git_version}'" "${info_plist}"
