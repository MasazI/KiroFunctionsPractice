#!/usr/bin/env bash
# ADR の形式を確かめる。内容が正しいかどうかは確かめない（中身は人が確かめる）。
# 使い方：./scripts/validate-adr.sh docs/decisions/0001-monthly-processing.md
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
facts_heading='## Verified facts and sources（確認した事実と出典）'

# 1. 見出しがそろっていて、どの見出しの下にも本文があるか（コメントだけは本文に数えない）
while IFS= read -r heading; do
  if ! grep -Fqx -- "$heading" "$adr"; then
    echo "NG：見出しがありません：$heading" >&2
    failed=1
    continue
  fi
  body=$(awk -v h="$heading" '
    $0 == h { in_section = 1; next }
    in_section && /^## / { exit }
    in_section { print }
  ' "$adr" | sed -e 's/<!--.*-->//g' | tr -d '[:space:]')
  if [ -z "$body" ]; then
    echo "NG：見出しの下が空です：$heading" >&2
    failed=1
  fi
done <<'LIST'
## Context（背景）
## Options considered（比較した選択肢）
## Verified facts and sources（確認した事実と出典）
## Project-specific inference（このプロジェクトへの推論）
## Decision（判断）
## Unknowns and validation（未確認の事項と技術検証）
## Revisit conditions（見直す条件）
LIST

# 2. テンプレートの書きかけが残っていないか
if grep -nE 'NNNN|YYYY-MM-DD|（決めたことの題名）|TBD|TODO' "$adr" >&2; then
  echo "NG：テンプレートの書きかけが残っています（上の行）" >&2
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
  echo "ADR の形式チェックに失敗しました：$1" >&2
  exit 1
fi

echo "ADR の形式チェックに合格しました：$1"
