#!/usr/bin/env bash

width=80
YN="(Yes|${BRIGHT}No${NORMAL}) >> "

BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLO=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)

echo_Right() {
    text=${1}
    echo
    tput cuu1
    tput cuf "$((${width} -1))"
    tput cub ${#text}
    echo "${text}"
}
echo_OK() {
    tput setaf 2 0 0
    echo_Right "[ OK ]"
    tput sgr0
}
echo_Done() {
    tput setaf 2 0 0
    echo_Right "[ Done ]"
    tput sgr0
}
echo_NotNeeded() {
    tput  setaf 3 0 0
    echo_Right "[ Not Needed ]"
    tput sgr0
}
echo_Skipped() {
    tput setaf 3 0 0
    echo_Right "[ Skipped ]"
    tput sgr0
}
echo_Failed() {
    tput setaf 1 0 0
    echo_Right "[ Failed ]"
    tput sgr0
}

antwoord() {
    read -p "${1}" antwoord
        if [[ ${antwoord} == [yY] || ${antwoord} == [yY][Ee][Ss] ]]; then
	    echo "yes"
	else
	    echo "no"
	fi
}
get_User() {
    if ! [[ $(id -u) = 0 ]]; then
	echo -e "\n ${RED}[ Error ]${Normal} This script must be run as root.\n"
	exit 1
    fi
}
get_OperatingSystem() {
    os=$(uname -s)
    kernel=$(uname -r)
    architecture=$(uname -m)
}
get_Distribution() {
    if [[ -f /etc/os-release ]]; then
	. /etc/os-release
	distribution=$NAME
	version=$VERSION_ID
    else
	echo -e "\nError: I need /etc/os-release to figure what distribution this is."
	exit 1
    fi
    echo -e "\nSeems to be:"
    echo -e " ${os} ${distribution} ${version} ${kernel} ${architecture}\n"
}
HostName_query() {
    SetHostname="$(antwoord "Do you want to set hostname? ${YN}")"
    if [[ "${SetHostname}" = "yse" ]]; then
	read -p "Hostname: " gethostname
    fi
}
HostName_set() {
	echo -n -e "Setting Hostname to: ${gethostname}\r"
	if [[ "${SetHostname}" = "yes" ]]; then
		 hostnamectl set-hostname ${gethostname}
		 echo_Done
	fi
}
GoogleChrome_query() {
	InstallGoogleChrome="$(antwoord "Do you want to get Google Chrome installed? ${YN}")"
}
GoogleChrome_install() {
	echo -n -e "Installing Repository: google-chrome\r"
	if [[ "${InstallGoogleChrome}" = "yes" ]]; then
		 # cp ${cdir}/etc/apt.repos.d/google-chrome.repo /etc/apt.repos.d
		 apt install -y google-chrome-stable1
	else
		 echo_Skipped
	fi
}
VmTools_query() {
		  InstallVmTools="$(antwoord "Do you want to get VMWare-Tools installed? "${YN})"
}
VmTools_install() {
	 echo -n -e "Installing Repository: open-vm-tools-desktop\r"
	 if [[ "${InstallVmTools}" = "yes" ]]; then
	 	  apt install open-vm-tools-desktop
	 else
		  echo_Skipped
	 fi
}
SshRootLogin_query() {
	DisableSshRoot="$(antwoord "Disable SSH login for root user? "${YN})"
}
SshRootLogin_disable() {
	echo -n -e "Disabling SSH login for root user.\r"
	if [[ "$DisableSshRoot}" = "yes" ]]; then
		 grep "^PermitRootLogin" /etc/ssh/sshd_config > /dev/null 2>&1
		 retVal=$?
		 if [[ "${retVal}" -ne 0 ]]; then
		     echo -e "\nPermitRootLogin no" >> /etc/ssh/sshd_config
			  echo_Done
		 else
			  sed -i "s/^PermitRootLogin\ yes/PermitRootLogin\ no/" /etc/ssh/sshd_config >>${logfile} 2>&1
			  retVal=$?
			  if [[ "${retVal}" -ne 0 ]]; then
				   echo_Failed
			  else
				   echo_Done
			  fi
		 fi
	else
		 echo_Skipped
	fi
}
do_Restart_query() {
	 Restart="$(antwoord "Don't forget to reboot the system. Reboot now? ${YN}")"
}
do_Restart() {
	 echo -n -e "Rebooting in 1 minute.\r"
	 if [[ "${Restart}" = "yes" ]]; then
	 	  reboot
	 else
		  echo_Skipped
	 fi
}
install_Ubuntu_21_10() {
	 echo "Installing Repository: ssh-server"
	 apt install openssh-server
	 echo "Installing Repository: git"
	 apt install git
	 echo "Installing Repository: exa"
	 apt install exa
	 echo "Installing Repository: vim"
	 apt install vim
}


get_User
get_OperatingSystem
get_Distribution
if [[ "${os}" = "Linux" ]];then
	 case ${distribution} in
		  "Ubuntu" )
			   GoogleChrome_query
				HostName_query
				SshRootLogin_query

				GoogleChrome_install
				HostName_set
				SshRootLogin_disable
				install_Ubuntu_21_10
				;;
	  esac
else
	  echo -e "Error: Unsupported operatingsystem"
	  exit 1
fi

echo_title "I'm done."
echo -e "\n\n"
do_Restart_query
do_Restart
exit 0
