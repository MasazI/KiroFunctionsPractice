#!/usr/bin/env bash
# 所要時間の試算ツール（tools/MonthlyEstimate.java）を実行して確かめる。
# Kiro が tools/ の Java ファイルを保存すると、Hook の依頼で Kiro が実行する。手で実行してもよい。
set -euo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
prog="$ROOT_DIR/tools/MonthlyEstimate.java"

if [ ! -f "$prog" ]; then
  echo "NG：tools/MonthlyEstimate.java がありません" >&2
  exit 1
fi
if ! command -v java >/dev/null 2>&1; then
  echo "NG：java が見つかりません（JDK 11 以上が必要です）" >&2
  exit 1
fi

echo "== サンプルの引数で実行：1000000 1000 120 20"
if ! java "$prog" 1000000 1000 120 20; then
  echo "NG：サンプルの引数で実行に失敗しました" >&2
  exit 1
fi

echo "== 不正な引数で実行：10 0 1 1（失敗すれば正しい）"
if java "$prog" 10 0 1 1 >/dev/null 2>&1; then
  echo "NG：不正な引数（1チャンクの件数が 0）でも成功しています" >&2
  exit 1
fi

echo "試算ツールの確認に合格しました"
