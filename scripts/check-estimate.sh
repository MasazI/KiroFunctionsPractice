#!/usr/bin/env bash
# 所要時間の試算ツール（tools/MonthlyEstimate.java）の受け入れテスト。
# 期待値は docs/requirements/monthly-estimate.md の要件と出力の形から決めている。
# ツールより先に置いてあるので、ツールを作る前に実行すると失敗する。
# Kiro が tools/ の Java ファイルを保存すると、Hook の依頼で Kiro が実行する。手で実行してもよい。
set -uo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
prog="$ROOT_DIR/tools/MonthlyEstimate.java"
failures=0
# 端末の文字コードの設定によらず、日本語の出力を UTF-8 で比べる
JAVA=(java -Dfile.encoding=UTF-8 -Dstdout.encoding=UTF-8 -Dstderr.encoding=UTF-8)

if [ ! -f "${prog}" ]; then
  echo "NG：tools/MonthlyEstimate.java がありません（まだ作られていません）" >&2
  exit 1
fi
if ! command -v java >/dev/null 2>&1; then
  echo "NG：java が見つかりません（JDK 11 以上が必要です）" >&2
  exit 1
fi

# 正しい引数：終了コード0で、期待する行がすべて出ること
# 使い方：expect_ok "<説明>" "<引数>" "<期待する行の一部>" ...
expect_ok() {
  local name="$1" args="$2"
  shift 2
  local out
  # shellcheck disable=SC2086
  if ! out=$("${JAVA[@]}" "${prog}" ${args} 2>&1); then
    echo "NG：${name}（java tools/MonthlyEstimate.java ${args} が0以外で終了しました）" >&2
    failures=$((failures + 1))
    return
  fi
  local expected
  for expected in "$@"; do
    if ! printf '%s\n' "${out}" | grep -F -q -- "${expected}"; then
      echo "NG：${name}（「${expected}」が出ていません）" >&2
      echo "    出力：" >&2
      printf '%s\n' "${out}" | sed 's/^/      /' >&2
      failures=$((failures + 1))
      return
    fi
  done
  echo "OK：${name}"
}

# 正しくない引数：0以外で終了すること
expect_fail() {
  local name="$1" args="$2"
  # shellcheck disable=SC2086
  if "${JAVA[@]}" "${prog}" ${args} >/dev/null 2>&1; then
    echo "NG：${name}（java tools/MonthlyEstimate.java ${args} が成功してしまいました）" >&2
    failures=$((failures + 1))
    return
  fi
  echo "OK：${name}"
}

# 1000000件 ÷ 1000件 ＝ 1000チャンク、1000 ÷ 20 ＝ 50回、50回 × 120秒 ＝ 6000秒 ＝ 1時間40分
expect_ok "サンプルの引数" "1000000 1000 120 20" \
  "チャンクの数：1000" \
  "全体の処理時間：1時間40分00秒（期限 4時間）→ 収まる" \
  "1チャンクの処理時間：0時間02分00秒（標準の Lambda の上限 15分）→ 収まる" \
  "注意：キューでの待ち、起動、再実行の時間は含みません。"

# 切り上げ：1001件 ÷ 1000件 → 2チャンク、2 ÷ 1 → 2回、2回 × 60秒 ＝ 2分
expect_ok "チャンクの数の切り上げ" "1001 1000 60 1" \
  "チャンクの数：2" \
  "全体の処理時間：0時間02分00秒（期限 4時間）→ 収まる"

# 切り上げ：3チャンク ÷ 同時に2 → 2回、2回 × 60秒 ＝ 2分
expect_ok "回数の切り上げ" "3 1 60 2" \
  "チャンクの数：3" \
  "全体の処理時間：0時間02分00秒（期限 4時間）→ 収まる"

# 境界：ちょうど4時間は収まる。1チャンク4時間は Lambda の上限を超える。終了コードは0
expect_ok "ちょうど4時間" "1 1 14400 1" \
  "全体の処理時間：4時間00分00秒（期限 4時間）→ 収まる" \
  "1チャンクの処理時間：4時間00分00秒（標準の Lambda の上限 15分）→ 収まらない"

# 境界：4時間を1秒でも超えたら収まらない
expect_ok "4時間を1秒超える" "1 1 14401 1" \
  "全体の処理時間：4時間00分01秒（期限 4時間）→ 収まらない"

# 境界：ちょうど15分は収まり、901秒は収まらない
expect_ok "1チャンクちょうど15分" "1 1 900 1" \
  "1チャンクの処理時間：0時間15分00秒（標準の Lambda の上限 15分）→ 収まる"
expect_ok "1チャンク15分を1秒超える" "1 1 901 1" \
  "1チャンクの処理時間：0時間15分01秒（標準の Lambda の上限 15分）→ 収まらない"

expect_fail "1チャンクの件数が0" "10 0 1 1"
expect_fail "整数でない値" "abc 1 1 1"
expect_fail "引数が3つ" "10 1 1"

if [ "${failures}" -ne 0 ]; then
  echo "試算ツールのテストに失敗しました（${failures} 件）" >&2
  exit 1
fi
echo "試算ツールのテストに合格しました"
