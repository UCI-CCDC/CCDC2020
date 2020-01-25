#!/bin/bash

# https://github.com/UCI-CCDC/CCDC2020
#UCI CCDC linux inventory script for os detection and to speed up general operations

#Written by UCI CCDC linux subteam
#UCI CCDC, 2020


printf "\n*** generating audit.txt in your home directory\n"
touch ~/audit.txt 
adtfile="tee -a $HOME/audit.txt"



#prettyos is the name displayed to user, name is the name for use later in package manager
prettyOS='cat /etc/os-release | grep -w "PRETTY_NAME" | cut -d "=" -f 2'
osOut='cat /etc/os-release | grep -w "NAME" | cut -d "=" -f 2 '
echo $osOut | $adtfile



##PKG finder/helper
#printf "\n***PKG Finder***\n"
#pkgloop=1
#pkgOut="pkgmgr:"
#printf lmao get fucked idk why this would be needed
#printf "${osOut}" >> ~/auditfile.txt

#printf "I'mma be doing a bunch of shit now lmao"

#if ! [ -x "$(command -v git)" ]; 
#then 
#	printf 'lmao git not installed' >>&2
#	printf finding packer
#else
#	


printf "\n***IP ADDRESSES***\n"
if  hash ip addr 2>/dev/null  ; then
ip addr | awk '
/^[0-9]+:/ {
  sub(/:/,"",$2); iface=$2 }
/^[[:space:]]*inet / {
  split($2, a, "/")
  print iface" : "a[1] }' | $adtfile
fi



printf "\n***USERS IN SUDO GROUP***\n"
grep -Po '^sudo.+:\K.*$' /etc/group | $adtfile
#echo "$sudogroup"
printf "\n***USERS IN ADMIN GROUP***\n"
grep -Po '^admin.+:\K.*$' /etc/group | $adtfile

#echo "$admingroup"
printf "\n***USERS IN WHEEL GROUP***\n"
grep -Po '^wheel.+:\K.*$' /etc/group | $adtfile

#echo "$wheel"
if hash netstat 2>/dev/null ; then 
    netstat -punta > /dev/null 2>/dev/null 
    if $? == 0; then    
    netstat -punta | grep 22 | $adtfile 
    else 

        printf "\n netstat -punta failed trying netstat -lsof\n"

        { netstat -lsof  | $adtfile ;} > /dev/null 2>/dev/null; 
    fi
fi


printf '**services you should cry about***\n'
ps aux | grep 'Docker\|samba\|postfix\|dovecot\|smtp\|psql\|ssh\|clamav\|mysql'


## NOTE WORKING O NTHIS FOR NOW, IDK IF THERE IS ALWAYS A .BASH_PROFILE IN ~
echo 'NOTE THIS MIGHT NOT WORK'
 # shellcheck disable=SC2016
printf '*** Making Bash profile log time/date using at $HOME/.bash_profile ***'
 # shellcheck disable=SC2183
if printf 'export HISTTIMEFORMAT="%d/%m/%y %T"' >> ~/.bash_profile >/dev/null 2>/dev/null == 0 ; then 
    # shellcheck source=/dev/null
      source ~/.bash_profile
    
else 
    echo something went wrong with making bash profile track time! 
fi

#curl -
#pull the external audit.sh script
