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

K8S_BINARIES=(kube-apiserver kube-controller-manager kube-scheduler kube-proxy kubelet kubectl)


mkdir -p _tmp
for binary in "${K8S_BINARIES[@]}";do
  echo "buiding image ${binary}:${TKE_K8S_VERSION} ..."
  echo
  sed "s|K8S_BINARY|${binary}|g" "${ROOT_DIR}/build/docker/Dockerfile" > _tmp/Dockerfile
  docker build -t "${binary}:${TKE_K8S_VERSION}" -f _tmp/Dockerfile "${ROOT_DIR}/_output/${RELEASE}"
  echo "**********************************************"
done

rm -rf _tmp
