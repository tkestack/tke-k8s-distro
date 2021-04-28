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

function k8s::download_and_make() {
  local DEST_DIR=$1
  local VERSION=$2
  local K8S_SHA256=$3
  local TKE_K8S_VERSION=$4
  local TKE_COMMIT=$5
  local TARGET_BIN_DIR=$6
  local PATCH_DIR=$7

  local RETRY_COUNT=3

  (
    cd "${DEST_DIR}"
    
    local K8S_SRC_TGZ="https://github.com/kubernetes/kubernetes/archive/refs/tags/v${VERSION}.tar.gz"
    local LOCAL_FILE="../v${VERSION}.tar.gz"
    util::download_with_retry "${K8S_SRC_TGZ}" "${LOCAL_FILE}" "${K8S_SHA256}" "${RETRY_COUNT}" 

    # Extract k8s src only when not yet
    if [[ ! -f ".tke-applied-patches" ]]; then
      tar xf "${LOCAL_FILE}" --strip-components=1
    else
      tar xf "${LOCAL_FILE}" --strip-components=1 kubernetes-${VERSION}/hack/lib/version.sh
    fi

    # Update version information
    sed -i "s|tag: v${VERSION}|tag: ${TKE_K8S_VERSION}|g" hack/lib/version.sh
    sed -i "s|KUBE_GIT_COMMIT='[0-9a-z]\+'|KUBE_GIT_COMMIT='${TKE_COMMIT}'|g" hack/lib/version.sh
    sed -i "s|KUBE_GIT_TREE_STATE=\"archive\"|KUBE_GIT_TREE_STATE=\"clean\"|g" hack/lib/version.sh

    echo "begin to apply tke patches..."
    echo
    util::apply_patch "${PATCH_DIR}"
    echo
    echo "all patches applied."
    echo

    KUBE_BUILD_PLATFORMS="linux/amd64" make kube-apiserver kube-controller-manager kube-scheduler kube-proxy kubelet kubectl kubeadm
    cp _output/bin/kube* "${TARGET_BIN_DIR}"
  )

}
