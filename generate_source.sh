#!/bin/bash -e

. version.sh

incoming_mirror="http://incoming.debian.org/debian-buildd"

if [ -d ./ignore ] ; then
	rm -rf ./ignore || true
fi

if [ -d ${package_name}_${package_version} ] ; then
    	echo ""
    	read -p "[WARNING]: Package already existing. Do you want to replace it? [Y/n] " reply
		reply=${reply:-y}
		if [[ $reply =~ ^[Yy]$ ]] ; then
			mkdir -p ./ignore
			git clone ${git_repo} ignore/${package_name}_${package_version}/
			if [ -f ./ignore/${package_name}_${package_version}/.git/config ] ; then
				cd ./ignore/${package_name}_${package_version}/
				git checkout ${git_branch}
				git submodule update --init --recursive
				rm -rf modules/PX4NuttX/misc/buildroot/toolchain/gcc/3.3.6/900-sx12-20101109.patch || true
				cd ../../
				rm -rf ${package_name}_${package_version} || true
				mv ./ignore/${package_name}_${package_version} . 
				rm -rf ./ignore/
				echo "All done successfully."
			fi	
	    fi
fi







