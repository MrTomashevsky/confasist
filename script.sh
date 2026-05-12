#!/usr/bin/bash

_confasist_default() {
	pwd_val=$(pwd)
	CONFASIST_LIB="${pwd_val}/.bash_lib"

	cd _rpi5
	./rc.bash install
	./set_basic_packages.bash minimal_mode
	./defpkg.bash install
	./ros2.bash install

	cd RemoteAccess/ssh
	CONFASIST_LIB=${CONFASIST_LIB} ./ssh_server.bash enable
	CONFASIST_LIB=${CONFASIST_LIB} ./ssh_server.bash setup_usb_static_ip
	cd ../sway_wayvnc
	./wayvnc_setup.bash build_from_sources
	./wayvnc_setup.bash setup_config
	./wayvnc_setup.bash add_render_groups
	cd ../usb_gadget
	./usb_gadget_setup.bash install

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
