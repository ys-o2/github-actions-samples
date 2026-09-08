#!/usr/bin/env bash

DAYS_BEFORE_STALE=30  # デフォルト値

# オプションのパース
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -d|--days) DAYS_BEFORE_STALE="${2}"; shift ;;
    -h|--help) echo "Usage: ${0} [-d|--days <days>]"; exit 0 ;;
    *) echo "Unknown parameter passed: ${1}"; exit 1 ;;
  esac
  shift
done

echo "Days before marking issues as stale: ${DAYS_BEFORE_STALE}"

# gh コマンドが存在するか確認
if ! command -v gh &> /dev/null; then
  echo "gh CLI could not be found. Please install it and try again."
  exit 1
fi

# GitHub CLIを認証（$GITHUB_TOKENが指定されている場合）
if [ -n "${GITHUB_TOKEN}" ]; then
  echo "Authenticating with GitHub CLI using provided token..."
  echo "${GITHUB_TOKEN}" | gh auth login --with-token
fi

echo "Starting stale issue closer..."

# issue の一覧を取得
STALE_ISSUES=$(gh issue list --state open --json number,updatedAt --jq ".[] | select(.updatedAt | fromdateiso8601 < (now - (${DAYS_BEFORE_STALE} * 86400))) | .number")

# issue 一覧を一つずつ処理
for ISSUE_NUMBER in ${STALE_ISSUES}; do
  echo "Closing stale issue #${ISSUE_NUMBER}"

  # close する issue にコメントを追加
  gh issue comment ${ISSUE_NUMBER} -b "This issue has been automatically closed due to inactivity."

  # issue を close する
  gh issue close ${ISSUE_NUMBER}
done
