#!/usr/bin/env bash
# 在 macOS 上一键出未签名 ipa（TrollStore 可直接安装）
# 用法：bash ios/build_ipa.sh
set -euo pipefail

cd "$(dirname "$0")/OnlineKefu"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "缺少 xcodegen，先执行： brew install xcodegen"
  exit 1
fi

xcodegen generate

xcodebuild \
  -project OnlineKefu.xcodeproj \
  -scheme OnlineKefu \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  DEVELOPMENT_TEAM="" \
  build

APP="build/Build/Products/Release-iphoneos/OnlineKefu.app"
[ -d "$APP" ] || { echo "构建产物不存在：$APP"; exit 1; }

OUT="../artifacts/ipa"
mkdir -p "$OUT" && rm -rf "$OUT/Payload"
cp -R "$APP" "$OUT/Payload"
( cd "$OUT" && rm -f 在线客服.ipa && zip -qry 在线客服.ipa Payload )

echo "✅ 已生成：$(cd "$OUT" && pwd)/在线客服.ipa"
echo "   用 TrollStore 打开这个文件即可安装（未签名，无需证书）"
