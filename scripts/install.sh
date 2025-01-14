#!/bin/sh -e

# Setup the environment first
SCRIPTS_DIR="$(cd "$(dirname "$0")"; pwd)"
. "$SCRIPTS_DIR/envsetup.sh"

__exit() {
	_error=$?
	echo "$1"
	exit $_error
}

__install_tool() {
	if [ ! -d "$1" ]; then
		echo "No such directory: $1"
		return 1
	fi
	if [ ! -f "$1/_install.sh" ]; then
		return 0
	fi
	if [ -f "$1/SKIP" ] ; then
		return 0
	fi
	unset -f  _install _build _download
	unset _target
	_SCRIPTDIR=$(realpath $1)
	TOOLNAME=$(basename $_SCRIPTDIR)
	echo "Installing $TOOLNAME..."
	. "$_SCRIPTDIR/_install.sh"
	if [ -z "$_target" ]; then
		echo "Unknown target program and/or version"
		return 1
	fi
	if __check_installed "$_target"; then
		# Just skip if it is already installed
		echo "Already installed"
		return 0
	fi
	_download || __exit "$TOOLNAME: download failed"
	_build    || __exit "$TOOLNAME: build failed"
	_install  || __exit "$TOOLNAME: install failed"
	__mark_installed "$_target"
	echo "Installing $TOOLNAME... done"
}

__install_tools() {
	#手动规定顺序
	__install_tool $SCRIPTS_DIR/linux
	__install_tool $SCRIPTS_DIR/meson
	__install_tool $SCRIPTS_DIR/cmake
	__install_tool $SCRIPTS_DIR/ninja
	__install_tool $SCRIPTS_DIR/gcc
	__install_tool $SCRIPTS_DIR/python
	__install_tool $SCRIPTS_DIR/go
	__install_tool $SCRIPTS_DIR/llvm
	__install_tool $SCRIPTS_DIR/capstone
	__install_tool $SCRIPTS_DIR/dwarves
	__install_tool $SCRIPTS_DIR/misc
	__install_tool $SCRIPTS_DIR/segfuzz
	__install_tool $SCRIPTS_DIR/qemu
	__install_tool $SCRIPTS_DIR/exp
	#for _PROJ in `find $SCRIPTS_DIR -mindepth 1 -maxdepth 1 -type d -exec test -e "{}/$1" \; -print`;
	#do
	#	__install_tool $_PROJ
	#done
}

# Install a speicified tool/toolchains
if [ -n "$1" ]; then
	TOOLPATH="$SCRIPTS_DIR/$1"
	__install_tool $TOOLPATH
	exit $?
fi

# Install tools/toolchains according to the specified order
__CEASE=${_CEASE:-4}
for o in $(seq 0 "$__CEASE");
do
	__install_tools "_$o"
done

if [ -z "$_CEASE" ]; then
	# And then install remainings
	__install_tools
fi
