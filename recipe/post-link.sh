#!/bin/bash

set -eu

# Returns 0 if current user is in the sudoers file
# and sudo-ing does not require a password.
can_sudo_without_password () {
sudo -ln | \grep -q '(ALL) NOPASSWD: ALL'
}

# Return X in macOS version 10.X.Y
get_macos_version () {
sw_vers -productVersion | sed -e 's/10.\([0-9][0-9]\)\.[0-9]/\1/'
}

# Returns 0 if macOS version is Mojave or Catalina
on_mojave_or_catalina () {
macos_version=$(get_macos_version)
if [ $macos_version  == '14' ] || [ $macos_version == '15' ] ; then
  return 0
else
  return 1
fi
}

# macOS specificities: codesign the GDB executable
if [[ $(uname) == "Darwin" ]]; then
  # On CI, sign the executable (for the tests)
  if can_sudo_without_password; then
    $PREFIX/bin/macos-codesign-gdb.sh
  else
    # Create the message shown at the end of installation
    cat <<-EOF > $PREFIX/.messages.txt
	
	
	Codesigning GDB
	---------------
	Due to macOS security restrictions, the GDB executable 
	needs to be codesigned to be able to control other processes.

	The codesigning process requires the Command Line Tools
	(or a full Xcode installation). 
	To install the Command Line Tools, run
	
	  xcode-select --install
	
	The codesigning process also requires administrative permissions
	(your user must be able to run \`sudo\`).

	To codesign GDB, simply run the included script:

	  macos-codesign-gdb.sh

	and enter your password. 

	Make sure this environment, "$(basename $PREFIX)", is activated
	so that "macos-codesign-gdb.sh" is found in your \$PATH.

	For more information, see: https://sourceware.org/gdb/wiki/PermissionsDarwin
	EOF
    # Tell users how to avoid being prompted for their password each time they run their executable
    cat <<-EOF >> $PREFIX/.messages.txt
	
	Avoiding being prompted for a password
	--------------------------------------
	On recent macOS versions, you will be prompted for an administrator username and password
	the first time you \`run\` an executable in GDB in each login session.

	To instead be prompted for your own password,
	you can add your user to the '_developer' group:

	  sudo dscl . merge /Groups/_developer GroupMembership $USER
	
	To avoid being prompted for any password, run:

	  sudo DevToolsSecurity -enable

	On older systems you might also need:

	  sudo security authorizationdb write system.privilege.taskport allow

	EOF
    # If on Mojave or Catalina, warn users about the "Unknown signal" error
    if on_mojave_or_catalina; then
    cat <<-EOF >> $PREFIX/.messages.txt
	Intermittent GDB error on Mojave and later
	------------------------------------------
	We've detected you are running macOS Mojave or later. GDB has a known intermittent bug on
	recent macOS versions, see: https://sourceware.org/bugzilla/show_bug.cgi?id=24069

	If you receive the following error when running your executable in GDB:
	
	  During startup program terminated with signal ?, Unknown signal
	
	or if GDB hangs, simply kill it and try to \`run\` your executable again, it should work eventually.
	EOF
    fi
    # Tell the user how to show this message again
    cat <<-EOF >> $PREFIX/.messages.txt
	
	Showing this message again
	--------------------------
	Once GDB is codesigned, this message will disappear.
	To show this message again, run
	
	  macos-show-caveats.sh
	EOF
    # Copy the message file since we might need to show it in the activate script
    # and conda deletes it after displaying it
    cp $PREFIX/.messages.txt $PREFIX/etc/gdb/.messages.txt
  fi
fi
