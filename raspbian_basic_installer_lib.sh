#!/usr/bin/bash

_confasist_default() {
	pwd_val=$(pwd)
	CONFASIST_LIB="${pwd_val}/.bash_lib"

	cd _rpi5
	./rc.bash install
	./set_basic_packages.bash minimal_mode
	CONFASIST_LIB=${CONFASIST_LIB} ./defpkg.bash install
#	CONFASIST_LIB=${CONFASIST_LIB} ./ros2.bash install

	cd RemoteAccess/ssh
	CONFASIST_LIB=${CONFASIST_LIB} ./ssh_server.bash enable
	CONFASIST_LIB=${CONFASIST_LIB} ./ssh_server.bash setup_usb_static_ip
	cd ../sway_wayvnc
	CONFASIST_LIB=${CONFASIST_LIB} ./wayvnc_setup.bash install
#	CONFASIST_LIB=${CONFASIST_LIB} ./wayvnc_setup.bash build_from_sources
#	CONFASIST_LIB=${CONFASIST_LIB} ./wayvnc_setup.bash setup_config
#	CONFASIST_LIB=${CONFASIST_LIB} ./wayvnc_setup.bash add_render_groups
	cd ../usb_gadget
	CONFASIST_LIB=${CONFASIST_LIB} ./usb_gadget_setup.bash install

	cd "$pwd_val"

	cd GraphicalEnvironments/sway/
	CONFASIST_LIB=${CONFASIST_LIB} ./sway_light.bash install
	cd "$pwd_val"

}

_confasist_wayvnc() {
	pwd_val=$(pwd)
	CONFASIST_LIB="${pwd_val}/.bash_lib"

#	source .bash_lib/is_root.bash
#	is_root

	cd _rpi/RemoteAccess/sway_wayvnc
	./wayvnc_tmux_start start
	cd "$pwd_val"

}
