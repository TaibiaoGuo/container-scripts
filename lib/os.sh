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

lib::os::id() {
  	# Every system that we officially support has /etc/os-release
  	if [ -r /etc/os-release ]; then
  		. /etc/os-release && echo "$ID"
  	fi
  	# Returning an empty string here should be alright since the
  	# case statements don't act unless you provide an actual value
  	echo
}

lib::os::version_id() {
    	# Every system that we officially support has /etc/os-release
    	if [ -r /etc/os-release ]; then
    		. /etc/os-release && echo "$VERSION_ID"
    	fi
    	# Returning an empty string here should be alright since the
    	# case statements don't act unless you provide an actual value
    	echo
}

lib::os::is_support() {
  source hack/script/lib/command-check.sh
  os_id=$( lib::os::id )
  case ${os_id} in

		ubuntu)
			if lib::command::command_exists lsb_release; then
				dist_version="$(lsb_release --codename | cut -f2)"
			fi
			if [ -z "$dist_version" ] && [ -r /etc/lsb-release ]; then
				dist_version="$(. /etc/lsb-release && echo "$DISTRIB_CODENAME")"
			fi
		;;

		debian|raspbian)
			dist_version="$(sed 's/\/.*//' /etc/debian_version | sed 's/\..*//')"
			case "$dist_version" in
				11)
					dist_version="bullseye"
				;;
				10)
					dist_version="buster"
				;;
				9)
					dist_version="stretch"
				;;
				8)
					dist_version="jessie"
				;;
			esac
		;;

		centos|rhel|sles)
			if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
				dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
			fi
		;;

		*)
			if lib::command::command_exists lsb_release; then
				dist_version="$(lsb_release --release | cut -f2)"
			fi
			if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
				dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
			fi
		;;
	esac

		# Print deprecation warnings for distro versions that recently reached EOL,
  	# but may still be commonly used (especially LTS versions).
  	case "$os_id.$dist_version" in
  		debian.stretch|debian.jessie)
  			lib::os::deprecation_notice "$os_id" "$dist_version"
  			;;
  		raspbian.stretch|raspbian.jessie)
  			lib::os::deprecation_notice "$os_id" "$dist_version"
  			;;
  		ubuntu.xenial|ubuntu.trusty)
  			lib::os::deprecation_notice "$os_id" "$dist_version"
  			;;
  		fedora.*)
  			if [ "$dist_version" -lt 33 ]; then
  				lib::os::deprecation_notice "$os_id" "$dist_version"
  			fi
  			;;
  	esac
}

# lib::os::deprecation_notice 如果操作系统版本将来不再支持，会调用该命令向用户发起弃用提醒
lib::os::deprecation_notice() {
  	local distro=$1
  	local distro_version=$2
  	echo
  	printf "\033[91;1mDEPRECATION WARNING\033[0m\n"
  	printf "    This Linux distribution (\033[1m%s %s\033[0m) reached end-of-life and is no longer supported by this script.\n" "$distro" "$distro_version"
  	echo   "    No updates or security fixes will be released for this distribution, and users are recommended"
  	echo   "    to upgrade to a currently maintained version of $distro."
  	echo
  	printf   "Press \033[1mCtrl+C\033[0m now to abort this script, or wait for the installation to continue."
  	echo
  	sleep 10
}