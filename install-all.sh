#!/usr/bin/env bash

# Copyright 2022 TaibiaoGuo.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

installList=("docker" "kubectl" "minikube" "kind" "kustomize" "test")

# 引入依赖
source hack/script/lib/command-check.sh

system::install_all() {
for var in "${installList[@]}";do
  if !  lib::command::check "$var";then
    system::install "$var"
  fi
done
}

system::install() {
  local do_flag=false
  for i in "${installList[@]}";do
    if [ "$i" == "$1" ] ;then
      source hack/script/system/install-"$1".sh
      do_install
      do_flag=true
      fi
  done
  if [ $do_flag == false ];then
    echo "install script for $1 not found"
    exit 1
    fi
}