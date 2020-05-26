#!/bin/bash

set -eu

# Returns 0 if current user is in the sudoers file
# and sudo-ing does not require a password.
can_sudo_without_password () {
sudo -ln | \grep -q '(ALL) NOPASSWD: ALL'
}

# macOS specificities: codesign the GDB executable
if [[ $(uname) == "Darwin" ]]; then
  # On CI, sign the executable (for the tests)
  if can_sudo_without_password; then
    $PREFIX/bin/macos-codesign-gdb.sh
  else
    # Create the message shown at the end of installation
    cat <<-EOF > $PREFIX/.messages.txt
	
	
	Due to macOS security restrictions, the GDB executable 
	needs to be codesigned to be able to control other processes.

	The codesigning process requires the Command Line Tools
	(or a full XCode installation). 
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
    # Copy the message file since we might need to show it in the activate script
    # and conda deletes it after displaying it
    cp $PREFIX/.messages.txt $PREFIX/etc/gdb/.messages.txt
  fi
fi
