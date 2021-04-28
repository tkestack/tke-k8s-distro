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

# List all releases under the /release directory
function util::dir::subdirs() {
  local dir="$1"
  local subdirs=($(cd $dir && ls -d */))

  local subdirnames=()
  for d in "${subdirs[@]}"; do
    subdirsnames+=($(basename $d))
  done

  echo $(util::array:sort "${subdirsnames[@]}")
}

# Sort array strings in reverse order
function util::array:sort() {
  local array=($@)
  readarray -t sorted < <(for a in "${array[@]}"; do echo "$a"; done | sort -r -t "." -k 2 -n)
  echo "${sorted[@]}"
}

# Concatenate array strings with separator
function util::array::join() {
  local sep=$1
  shift
  local array=($@)
  local len=${#array[@]}
  local last_index=$((len - 1))

  local str=""
  for ((i = 0; i < ${len}; i++)); do
    str="${str}${array[$i]}"
    if [[ $i -lt $last_index ]]; then
      str="${str}${sep} "
    fi
  done
  echo "${str}"
}

# Checker whether an array contains a string
function util::array::contains() {
  local search="$1"
  local element
  shift
  for element; do
    if [[ "${element}" == "${search}" ]]; then
      return 0
    fi
  done
  return 1
}

# Get the latest release
function util::latest_release() {
  local RELEASE_DIR="$1"
  local ALL_RELEASES=($(util::dir::subdirs "${RELEASE_DIR}"))
  echo "${ALL_RELEASES[0]}"
}

# Check wheter a release exists
function util::check_release() {
  local release="$1"
  local RELEASE_DIR="$2"
  local ALL_RELEASES=($(util::dir::subdirs "${RELEASE_DIR}"))

  if ! $(util::array::contains "${release}" "${ALL_RELEASES[@]}"); then
    echo "ERROR: ${release} is not supported. Available releases:" $(util::array::join "," "${ALL_RELEASES[@]}")
    return 1
  fi
}

# Download files with retry
function util::download_with_retry() {
  local URL=$1
  local LOCAL_FILE=$2
  local SHA256=$3
  local RETRY_COUNT=$4

  if [[ -f "${LOCAL_FILE}" && "${SHA256}" == $(sha256sum "${LOCAL_FILE}" | tr -s " " | cut -d " " -f 1) ]];then
    echo "${LOCAL_FILE} already downloaded, skip."
    return 0
  fi

  local DOWNLOAD_COUNT=0
  until [[ "${DOWNLOAD_COUNT}" -ge "${RETRY_COUNT}" ]]; do
    wget -c "${URL}" -O "${LOCAL_FILE}"
    if [[ "${SHA256}" == $(sha256sum "${LOCAL_FILE}" | tr -s " " | cut -d " " -f 1) ]]; then
      return 0
    fi 
    DOWNLOAD_COUNT=$((DOWNLOAD_COUNT+1))
  done
  echo "failed to download ${URL} after ${RETRY_COUNT} attempts."
  return 1
}

# Apply all patch under specified directory
function util::apply_patch() {
  local PATCH_DIR=$1

  local applied_file=".tke-applied-patches"

  local patches=($(ls "${PATCH_DIR}"))
  local applied_patches=($(cat "${applied_file}"))
  for p in "${patches[@]}"; do
    local patch_number=$(echo "${p}" | cut -d "-" -f 1)
    echo "applying patch ${p}..."
    if util::array::contains "${patch_number}" "${applied_patches[@]}"; then
      echo "already applied, skip"
    else
      patch -p1 < "${PATCH_DIR}/${p}"
      echo "${patch_number}" >> "${applied_file}"
    fi
    echo 
  done

}
