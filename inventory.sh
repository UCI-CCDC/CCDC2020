#!/bin/bash

########################################################
# https://github.com/UCI-CCDC/CCDC2020
# script raw is at https://git.io/uciccdc20
# to install: wget https://git.io/uciccdc20 -O inv.sh && chmod +x inv.sh
#UCI CCDC linux inventory script for os detection and to speed up general operations

#Written by UCI CCDC linux subteam
#UCI CCDC, 2020
########################################################

# Features to add -----------------------------
# are sql  password changes automatable? 
# set script to check for non-default cron jobs
    # automatically upload the audit to 0x0.st? kinda a security risk (have it start the file off with the machine's IP and hostname)
#is it possible to automate verifying permissions on important files?
#
#automate backups?

# TODO -----------------------------------------
# add installPackages functionality
# Add system hardening under -x flag
# fix the minor errors that are output to console when run:
    # the "no such file or directory" after the anteater
    # mkdir returns an error when the /root/inv directory has already been created. Should we remove/redirect that?
# Test on other systems
    #Raspbian
    # Debian
    #CentOS
    #Scientific Linux
    # Oracle Linux
    # RHEL
# Move alpine functionality to different part of script?

if [[ $EUID -ne 0 ]]; then
	printf 'Must be run as root, exiting!\n'
	exit 1
fi



updateOS() {
    
    # tempName=$(cat /etc/os-release | grep -w "NAME" | cut -d "=" -f 2)
    # osName=${tempName//\"}      #removes double quotes from os name so that it'll actually fucking work with the if statement
    # printf "Updating System Now OS detected: $osName\n"

    # if [ "$osName" = "Ubuntu" ] || [ "$osName" = "Debian" ] || [ "$osName" = "Raspbian" ]; then
    #     printf "Updating system using apt-get\n"
    #     apt-get update 
    # fi

    # if [ "$osName" = "CentOS" ] || [ "$osName" = "Scientific Linux" ] || [ "$osName" = "Oracle Linux" ] || [ "$osName" = "Red Hat Enterprise Linux" ]; then
    #     printf "Updating system using yum\n"
    #     yum update
        
    # fi

    ## Install & update utilities
    if [ $(which apt-get) ]; then # Debian based
        apt-get update -y -q
    elif [ $(which yum) ]; then
        yum update
    elif [ $(which pacman) ]; then 
        pacman -Syy
        pacman -Su
    elif [ $(which apk) ]; then # Alpine
        apk update
        apk upgrade
    fi

}

installPackages() {
    printf "this function will be used to install important/essential packages on barebones systems"
    #curl, sudo, nmap, tmux, tshark, man, vim, hostname
}


harden() { 
    printf "We are now doing system hardening\n"

    wget https://raw.githubusercontent.com/UCI-CCDC/CCDC2020/jacob/harden.sh -O harden.sh && bash harden.sh
    #I'm lazy af, this calls the hardening script and runs it. Hope it works
}


#below should both be false
ShouldUpdate=false
ShouldInstall=false

# this fucker is the flag statement
while getopts :huixnm: option
do
case "${option}" in
h) 
    printf "\n UCI CCDC 2020 Linux Inventory Script\n"
    prinf "Note: all options other than the update functions will result in the main script not being run."

    printf "    ==============Options==============\n"
    printf " -h     Prints this help menu\n"
    printf " -n     Runs Jacob's custom NMAP command\n"
    printf " -m     Runs custom NMAP command, but IP subnet must be passed as an argument (ex: -m 192.168.1.0)\n"
    printf " -x     Hardens System (not yet implemented)\n"
    printf " -u     Installs updates based on system version\n"
    printf " -i     Installs updates AND useful packages\n"
    exit 1;;
u) 
    ShouldUpdate=true
    ;;
i) 
    ShouldUpdate=true
    ShouldInstall=true
    ;;

x)
    harden          #calls hardening function above
    exit 1;;

n) 
    printf "Running NMAP command, text and visual xml output created in current directory"
    nmap -p- -Anvv -T4 -oN nmapOut.txt -oX nmapOutVisual.xml $(hostname -I | awk '{print $1}')/24
    exit 1;;

m) 
    printf "Running NMAP command with user specificed subnet, text and visual xml output created in current directory"
    nmap -p- -Anvv -T4 -oN nmapOut.txt -oX nmapOutVisual.xml $OPTARG/24
    exit 1;;

#both of these are error handling. The top one handles incorrect flags, the bottom one handles when no argument is passed for a flag that requires one
\?) echo "incorrect syntax, use -h for help"
    exit 1;;

:)  echo "invalid option: -$OPTARG requires an argument"
    exit 1;;
esac
done



echo "
'''
        _________ ______
    ___/   \     V      \\
   /  ^    |\    |\      \\
  /_O_/\  / /    | ‾‾‾\  |
 //     \ |‾‾‾\_ |     ‾‾
//      _\|    _\|

      zot zot, thots.
'''"
#there's an error being thrown at this point in the script for ": no such file or directory"

printf "\n*** generating inv direcory and audit.txt in your root home directory\n"
mkdir $HOME/inv/        #NEED TO ADD HANDLING FOR WHEN DIRECTORY ALREADY EXISTS?
touch $HOME/inv/audit.txt 
adtfile="tee -a $HOME/inv/audit.txt"

echo -e "\n\e[92mThe hostname is: $(hostname)\e[0m" | $adtfile

#osOut has the prettyname for the OS, which includes the version. We can just grep that for the update script later
osOut=$(cat /etc/os-release | grep -w "PRETTY_NAME" | cut -d "=" -f 2)

printf "This machine's OS is "
echo -e "\e[31m$osOut\e[0m" | $adtfile


#alpine linux will not be at regionals
if  grep -i "alpine" /etc/os-release ; then
    alpinelp=1
    while [ "$alpinelp" == 1 ] ; do
        printf "Alpine? lol k, do you want to install some basic stuff? [y/N/? for list]"
        read -r alpinechoice
            case "$alpinechoice" in 
            Y|y) apk update && apk upgrade && apk add bash vim curl man man-pages mdocml-apropos bash-doc bash-completion util-linux pciutils usbutils coreutils binutils findutils 
            alpinelp=0;;
            N|n) alpinelp=0;; 
            w) printf "bash vim curl man man-pages mdocml-apropos bash-doc bash-completion util-linux pciutils usbutils coreutils binutils findutils";;
            *) printf "invalid choice" 
        esac
    done
fi

echo -e "\n\e[95m***IP ADDRESSES***\e[0m"
echo "Most recent IP: $(hostname -I | awk '{print $1}')"
echo "All IP Addresses: $(hostname -I)" | $adtfile

## /etc/sudoers
if [ -f /etc/sudoers ] ; then
    printf "\nSudoers\n"
    sudo awk '!/#(.*)|^$/' /etc/sudoers | $adtfile
fi 


# ## Less Fancy /etc/shadow
printf "Passwordless accounts: "
awk -F: '($2 == "") {print}' /etc/shadow # Prints accounts without passwords
echo;

echo -e "\n\e[93m***USERS IN SUDO GROUP***\e[0m\n"
grep -Po '^sudo.+:\K.*$' /etc/group | $adtfile

printf "\n\e[93m***USERS IN ADMIN GROUP***\e[0m\n"
grep -Po '^admin.+:\K.*$' /etc/group | $adtfile

printf "\n\e[93m***USERS IN WHEEL GROUP***\e[0m\n"
grep -Po '^wheel.+:\K.*$' /etc/group | $adtfile



#saves services to variable, prints them out to terminal in blue
printf '\n**services you should cry about***\n'
services=$(ps aux | grep 'Docker\|samba\|postfix\|dovecot\|smtp\|psql\|ssh\|clamav\|mysql\|bind9' | grep -v "grep")
echo -e "\e[34m"
echo $services | $adtfile
echo -e "\e[0m" #formatting so audit file is less fucked with the color markers


if [ "$ShouldUpdate" = "true" ]; then
    updateOS
fi

if [ "$ShouldInstall" = "true" ]; then
    installPackages
fi




## NOTE WORKING O NTHIS FOR NOW, IDK IF THERE IS ALWAYS A .BASH_PROFILE IN ~
# echo 'NOTE THIS MIGHT NOT WORK'
#  # shellcheck disable=SC2016
# printf '*** Making Bash profile log time/date using at $HOME/.bash_profile ***'
#  # shellcheck disable=SC2183
# if printf 'export HISTTIMEFORMAT="%d/%m/%y %T"' >> ~/.bash_profile >/dev/null 2>/dev/null == 0 ; then 
#     # shellcheck source=/dev/null
#       source ~/.bash_profile
    
# else 
#     echo something went wrong with making bash profile track time! 
# fi


# this string prints the current system time and date "\033[01;30m$(date)\033[0m: %s\n"