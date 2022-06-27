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

# 引入依赖
source hack/script/system/install-all.sh

case $1 in
	all)
    system::install_all
	;;
	docker|kind|kubectl|kustomize|minikube)
		system::install "$1"
	;;
	test)
		system::install "$1"
	;;
	*)
		echo "请输入需要安装的软件名称"
	;;
esac