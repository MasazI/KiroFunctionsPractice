#!/usr/bin/env bash
# ADR の形式を確かめる。内容が正しいかどうかは確かめない（中身は人が git diff で確かめる）。
# 使い方：./scripts/validate-adr.sh docs/decisions/0002-monthly-processing.md
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "使い方：$0 <ADR のパス>" >&2
  exit 2
fi

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
case "$1" in
  /*) adr="$1" ;;
  *) adr="$ROOT_DIR/$1" ;;
esac

if [ ! -f "$adr" ]; then
  echo "NG：ADR が見つかりません：$1" >&2
  exit 1
fi

failed=0

# 1. 見出しがそろっているか
facts_heading='## Verified facts and sources（確認した事実と出典）'
while IFS= read -r heading; do
  if ! grep -Fqx -- "$heading" "$adr"; then
    echo "NG：見出しがありません：$heading" >&2
    failed=1
  fi
done <<'EOF'
## Context（背景）
## Options considered（比較した選択肢）
## Verified facts and sources（確認した事実と出典）
## Project-specific inference（このプロジェクトへの推論）
## Decision（判断）
## Unknowns and validation（未確認の事項と技術検証）
## Revisit conditions（見直す条件）
EOF

# 2. 書きかけが残っていないか
if grep -nE 'ここに記入|TBD|TODO' "$adr" >&2; then
  echo "NG：書きかけが残っています（上の行）" >&2
  failed=1
fi

# 3. 確認した事実に出典の URL があるか
if ! awk -v h="$facts_heading" '
  $0 == h { in_section = 1; next }
  in_section && /^## / { in_section = 0 }
  in_section && /https:\/\// { found = 1 }
  END { exit found ? 0 : 1 }
' "$adr"; then
  echo "NG：「確認した事実と出典」に出典の URL がありません" >&2
  failed=1
fi

if [ "$failed" -ne 0 ]; then
  echo "ADR の検証に失敗しました：$1" >&2
  exit 1
fi

echo "ADR の検証に合格しました：$1"
