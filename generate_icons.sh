#!/bin/bash

# Wasurenai App Icon Generator
# SVGファイルからiOS用のアプリアイコンPNGを生成します

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ICON_DIR="$SCRIPT_DIR/Wasurenai/Assets.xcassets/AppIcon.appiconset"

# ipsコマンド（macOS標準）またはrsvg-convertを使用
# rsvg-convertがない場合: brew install librsvg

echo "🎨 Wasurenai App Icon Generator"
echo "================================"

# SVGファイルの存在確認
if [ ! -f "$ICON_DIR/AppIcon.svg" ]; then
    echo "❌ AppIcon.svg が見つかりません"
    exit 1
fi

# rsvg-convertの確認
if ! command -v rsvg-convert &> /dev/null; then
    echo "⚠️  rsvg-convert がインストールされていません"
    echo "   以下のコマンドでインストールしてください:"
    echo "   brew install librsvg"
    echo ""
    echo "または、以下のオンラインツールでSVGをPNGに変換してください:"
    echo "   https://cloudconvert.com/svg-to-png"
    echo ""
    echo "SVGファイルの場所:"
    echo "   $ICON_DIR/AppIcon.svg"
    echo "   $ICON_DIR/AppIcon-Dark.svg"
    echo ""
    echo "サイズ: 1024x1024 で出力し、以下のファイル名で保存:"
    echo "   - AppIcon.png (通常版)"
    echo "   - AppIcon-Dark.png (ダークモード版)"
    exit 1
fi

echo "📦 アイコンを生成中..."

# 通常アイコン
rsvg-convert -w 1024 -h 1024 "$ICON_DIR/AppIcon.svg" -o "$ICON_DIR/AppIcon.png"
echo "✅ AppIcon.png 生成完了"

# ダークモードアイコン
rsvg-convert -w 1024 -h 1024 "$ICON_DIR/AppIcon-Dark.svg" -o "$ICON_DIR/AppIcon-Dark.png"
echo "✅ AppIcon-Dark.png 生成完了"

echo ""
echo "🎉 アイコン生成完了！"
echo "   Xcodeでプロジェクトを開き、アイコンを確認してください。"
