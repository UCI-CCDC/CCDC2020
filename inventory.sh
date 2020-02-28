#!/bin/bash

# https://github.com/UCI-CCDC/CCDC2020
# script raw is at https://git.io/uciccdc20
#UCI CCDC linux inventory script for os detection and to speed up general operations

#Written by UCI CCDC linux subteam
#UCI CCDC, 2020



# - (-h) help functionality to list flags
# - (-n) flag to run nmap script
# - (-u) flag to install updates
# - (- ) flag to harden system (flag not decided, -h already taken): maybe use -x?
# - (-i) flag to install updates, and then install packages that are useful and check for basic utilities (nmap, tmux, tshark )[curl, man, vim]
# - set it to run it's usual thing if no flags given


# are sql  password changes automatable? 
# set script to check for non-default cron jobs
    # also wouldn't be a bad idea to make the script automatically upload the audit to 0x0.st (have it start the file off with the machine's IP and hostname)
#is it possible to automate verifying permissions on important files?
#
#
#any flag other than updates & installs should exit immediately after being run to avoid re-running main script
#automate backups?

if [[ $EUID -ne 0 ]]; then
	printf 'Must be run as root, exiting!\n'
	exit 1
fi



updateOS() {
    osName=$(cat /etc/os-release | grep -w "NAME" | cut -d "=" -f 2)

    if [osName='Ubuntu' || osName='Debian' || osName='Raspbian']; then
        apt-get update 
    fi

    if [osName='CentOS' || osName='Scientific Linux' || osName='Oracle Linux' || osName='Red Hat Enterprise Linux']; then
        yum update
        #yum update preserves obsolete packages, which is better for us since we don't want stuff to break
    fi


}

installPackages() {
    printf "this function will be used to install important/essential packages on barebones systems"
    #curl,sudo,
}


#below should be 0,0, pls fix
ShouldUpdate=1
ShouldInstall=1


#this is for accepting flags to perform different operations
#if a flag is supposed to accept user input after being called (ex -f "hello"), it is followed by a : after getopts in the while statement
while getopts :huin: option
do
case "${option}"
in
h) 
    printf "\n UCI CCDC 2020 Linux Inventory Script\n"
    printf " -h     Prints this help menu\n"
    printf " -n     Runs Jacob's custom NMAP command\n"
    printf " -u     Installs updates based on system version\n"
    printf " -i     Installs updates AND useful packages\n"
    exit 1;;
u) 
    ShouldUpdate=true
    updateOS
    #this portion of the script will be built into the update function higher up in the script
    #this will allow both -u and -i to call the same update functionality
    #it will also rely on the OS name in order to determine what package manager to use to install updates

    #WE SHOULD MAKE THE UPDATE FUNCTIONALITY RUN AT THE END OF THE SCRIPT, INSTEAD OF THE BEGINNING
    ;;
i) 
    printf "update and install portion of script not yet implemented\n"
    ShouldUpdate=true
    ShouldInstall=true
    ;;

n) 
    printf "Running NMAP command, text and visual xml output created in current directory"
    nmap -p- -Anvv -T4 -oN nmapOut.txt -oX nmapOutVisual.xml $OPTARG/24
    exit 1;;

#both of these are error handling. The top one handles incorrect flags, the bottom one handles when no argument is passed for a flag that requires one
\?) echo "incorrect syntax, use -h for help"
    exit 1;;

:)  echo "invalid option: -$OPTARG requires an argument"
    exit 1;;
esac
done




'''
        _________ ______
    ___/   \     V      \
   /  ^    |\    |\      \
  /_O_/\  / /    | ‾‾‾\  |
 //     \ |‾‾‾\_ |     ‾‾
//      _\|    _\|

      zot zot, thots.
'''
#there's an error being thrown at this point in the script for ": no such file or directory"

printf "\n*** generating inv direcory and audit.txt in your root home directory\n"
mkdir $HOME/inv/
touch $HOME/inv/audit.txt 
adtfile="tee -a $HOME/inv/audit.txt"
cat /etc/hostname | $adtfile

#osOut has the prettyname for the OS, which includes the version. We can just grep that for the update script later
osOut=$(cat /etc/os-release | grep -w "PRETTY_NAME" | cut -d "=" -f 2)


printf "This machine's OS is "
#The super fucked formatting below this prints out prettyname, but in red text
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


#THIS IS CURRENTLY BROKEN
printf "\n***IP ADDRESSES***\n"
if  hash ip addr 2>/dev/null  ; then
ip addr | awk '
/^[0-9]+:/ {
  sub(/:/,"",$2); iface=$2 }
/^[[:space:]]*inet / {
  split($2, a, "/")
  print iface" : "a[1]
}' | $adtfile
fi




## /etc/sudoers
if [ -f /etc/sudoers ] ; then
    printf "Sudoers\n"
    sudo awk '!/#(.*)|^$/' /etc/sudoers | $adtfile
fi 

#this doesn't work
# ## Less Fancy /etc/shadow
# this string prints the current system time and date "\033[01;30m$(date)\033[0m: %s\n"
printf "Passwordless accounts: "
awk -F: '($2 == "") {print}' /etc/shadow # Prints accounts without passwords
echo;

printf "\n***USERS IN SUDO GROUP***\n"
grep -Po '^sudo.+:\K.*$' /etc/group | $adtfile

printf "\n***USERS IN ADMIN GROUP***\n"
grep -Po '^admin.+:\K.*$' /etc/group | $adtfile

printf "\n***USERS IN WHEEL GROUP***\n"
grep -Po '^wheel.+:\K.*$' /etc/group | $adtfile



#saves services to variable, prints them out to terminal in blue
printf '\n**services you should cry about***\n'
services=$(ps aux | grep 'Docker\|samba\|postfix\|dovecot\|smtp\|psql\|ssh\|clamav\|mysql\|bind9' | grep -v "grep")
echo -e "\e[34m$services\e[0m" | $adtfile


if [ "$ShouldUpdate" = true ] ; then
    updateOS
fi

if [ "$ShouldInstall" = true ] ; then
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

