#!/bin/bash
# Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
