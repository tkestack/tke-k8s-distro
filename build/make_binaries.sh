#!/usr/bin/env bash
# Tencent is pleased to support the open source community by making TKEStack
# available.
#
# Copyright (C) 2012-2019 Tencent. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use
# this file except in compliance with the License. You may obtain a copy of the
# License at
#
# https://opensource.org/licenses/Apache-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OF ANY KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations under the License.

set -o errexit
set -o pipefail

ROOT_DIR=$(dirname "${BASH_SOURCE[0]}")/..
source "${ROOT_DIR}/build/lib/util.sh"
source "${ROOT_DIR}/build/lib/k8s.sh"

RELEASE_DIR="${ROOT_DIR}/releases"
RELEASE=$1

# Check whether release exists
if [[ ! -z "${RELEASE}" ]]; then
  util::check_release "${RELEASE}" "${RELEASE_DIR}"
else
  RELEASE=$(util::latest_release "${RELEASE_DIR}")
fi

# Get BASE_K8S_VERSION,TKE_VERSION,TKE_COMMIT from VERSION file
source "${ROOT_DIR}/releases/${RELEASE}/VERSION"
TKE_K8S_VERSION="v${BASE_K8S_VERSION}-${TKE_VERSION}"

PATCH_DIR="$(realpath ${ROOT_DIR}/releases/${RELEASE}/patches)"

# Prepare temporary directories
OUTPUT_DIR="${ROOT_DIR}/_output/${RELEASE}"
TMP_SRC_DIR="${ROOT_DIR}/_src/${RELEASE}"
rm -rf "${OUTPUT_DIR}" && mkdir -p "${OUTPUT_DIR}"
mkdir -p "${TMP_SRC_DIR}"

# Download k8s source code, apply patch and make the binaries
echo "begin to build binaries for tke ${TKE_K8S_VERSION}..."
k8s::download_and_make "${TMP_SRC_DIR}" "${BASE_K8S_VERSION}" "${BASE_K8S_SHA256}" "${TKE_K8S_VERSION}" "${TKE_COMMIT}" "$(realpath ${OUTPUT_DIR})" "${PATCH_DIR}"

BINARIES=($(ls ${OUTPUT_DIR}))
echo
echo "binaries ready at ${OUTPUT_DIR}: $(util::array::join "," ${BINARIES[@]})"
echo

