#!/bin/bash
# This script updates a -stamp file based on whether a submodule has changed.

SUBMODULE_DIR=$1
[[ -z "${SUBMODULE_DIR}" ]] && exit 1

STAMP_NAME=$2
[[ -z "${STAMP_NAME}" ]] && exit 2

rev_parse=$(cd "${SUBMODULE_DIR}" && git rev-parse HEAD)
dirty=$(cd "${SUBMODULE_DIR}" && git status --porcelain)

new_stamp_content=$(printf "${rev_parse}\n${dirty}")
old_stamp_content=""
[[ -f "${STAMP_NAME}" ]] && old_stamp_content=$(cat "${STAMP_NAME}")

if [[ "${new_stamp_content}" != "${old_stamp_content}" ]]; then
  echo "Updating stamp file"
  echo "${new_stamp_content}" > "${STAMP_NAME}"
fi
