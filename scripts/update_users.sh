#!/bin/bash

# Note that this Bash script relies on the the following assumption to work correctly:
# For each input into this script as 'CLIENT', the underlying 'openvpn-install.sh' Bash script creates a certificate nameded 'CLIENT.ovpn'.
# _Excess client certificates_ are then defined as provsioned client certificates that have no corresponding entry in the input to this script.


# Set the nullglob option so that the array is empty if there are no matches; see also <https://stackoverflow.com/a/10981499> for details
shopt -s nullglob

# A pint for the person who can do this in one line using readily available Bash primitives!
function is_in_array {
  array=$2
  for i in ${array[@]}
  do
    if [[ "${i}" == "$1" ]]
    then
      return 0
    fi
  done
  return 1
}

# Input paramter checking and alerting if there are none (which is synonymous with revoking all client certificates)
if [[ "$#" -eq "0" ]]
then
  script_name=$(basename "$0")
  echo "Usage: ${script_name} <username1> ... <usernameN>"
  echo "Example: ${script_name} userOne"
  echo "Example: ${script_name} userOne userTwo"
  echo ""
	until [[ $REVOKE_ALL_CLIENT_CERTIFICATES =~ ^(Y|n)$ ]]; do
    read -p "You've supplied no username. This will REVOKE ALL CLIENT CERTIFICATES! Are you sure? [Y/n]" -n 1 -r REVOKE_ALL_CLIENT_CERTIFICATES
    echo ""
  done
  if [[ $REVOKE_ALL_CLIENT_CERTIFICATES =~ ^[Y]$ ]]
  then
    echo "Alright. REVOKING ALL CLIENT CERTIFICATES then..."
  else
    echo "Aborting."
    exit -1
  fi
fi

# Declare all additional parameters to be user names
USERNAMES="$@"


# Create a list of provisioned OVPN users from existing *.ovpn files
declare -a ovpn_users
for ovpn_filename in *.ovpn
do
  ovpn_users=("${ovpn_users[@]}" "${ovpn_filename%.*}")
done

# Revoke excess client certificates
for ovpn_user in ${ovpn_users[@]}
do
  if is_in_array "${ovpn_user}" "${USERNAMES}"
  then
    echo "Keeping certificate for user ${ovpn_user}."
  else
    echo "Revoking certificate for user ${ovpn_user}!"

    # Export the corresponding options and revoke the user certificate
    export MENU_OPTION="2"
    export CLIENT="${ovpn_user}"
    ./openvpn-install.sh
  fi
done


# Provision an OVPN file for each new user
for username in ${USERNAMES}
do
  # Skip all user names that already have a corresponding OVPN file
  ovpn_filename="${username}.ovpn"
  if [ -f "${ovpn_filename}" ]
  then
      echo "File '${ovpn_filename}' already exists. Skipping."
      continue
  fi

  # Export the corresponding options and add the user name
  export MENU_OPTION="1"
  export CLIENT="${username}"
  export PASS="1"
  ./openvpn-install.sh
done
