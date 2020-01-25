#!/bin/bash

printf "\n*** generating audit.txt in your home directory\n"
touch ~/audit.txt 
adtfile="tee -a $HOME/audit.txt"

#prettyos is the name displayed to user, name is the name for use later in package manager
cat /etc/os-release | grep -w "PRETTY_NAME" | cut -d "=" -f 2
cat /etc/os-release | grep -w "NAME" | cut -d "=" -f 2 | $adtfile 
echo $osOut | $adtfile
printf "\n** catproc version **\n"
if test   -f  /proc/version  ; then 
    #foo=$(cat /proc/version)
    #echo "$foo" >> ~/audit.txt
    # shellcheck disable=SC2002
    cat /proc/version | $adtfile
fi
#OS picker for first audit
printf "\n***OS PICK***\n"
osloop=1
osOut="OS:"

while [ $osloop == 1 ] ; do
	printf "\n***CHOOSE ONE***\n1) Ubuntu\n2) Fedora\n3) Alpine\n4) SunOS\n5) CentOS\n7) Archbtw\n8)lmao none git rekt\n"
	read -r choice
	os=""
	case "$choice" in
		1) os="Ubuntu" ;;
		2) os="Fedora" ;;
		3) os="Alpine" ;;
		4) os="SunOS" ;;
		5) os="CentOS" ;;
		7) os="Archbtw" ;;
		8) printf "\n***USER INPUT PLEASE***\n"
			read -r os ;;
		*) printf "invalid input read -r plz"

	esac
	if [ "$os" != "" ] ; then
		printf "%s is the os? [y/N]" "$os"
		read -r endloop
		if [ "${endloop}" == "y" ] || [ "${endloop}" == "Y" ] ; then
		osloop=0
		osOut="${osOut} ${os}"
        echo "$osOut" | $adtfile
		fi
	fi
done
if [ "$os" == "Alpine" ] ; then
    alpinelp=1
    while [ "$alpinelp" == 1 ] ; do
        printf "Alpine? lol k, do you want to install some basic stuff? [y/N/? for list]"
        read -r alpinechoice
            case "$alpinechoice" in 
            Y|y) apk update && apk upgrade && apk install bash vim curl man man-pages mdocml-apropos bash-doc bash-completion util-linux pciutils usbutils coreutils binutils findutils 
            alpinelp=0;;
            N|n) alpinelp=0;; 
            ?) printf "bash vim curl man man-pages mdocml-apropos bash-doc bash-completion util-linux pciutils usbutils coreutils binutils findutils" ;;
            *) printf "invalid choice" 
        esac
    done
fi
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
#	#do we need to clone a specific something? can't we just clone alias to a something
#	#grep for stuff in logs
#	#login passwd change search for unique files
#	#find all users
#	#find all grups
#	#find and parse through groups 
#	#1000+ 1500+ 
#	#non default user accounts 
#	#non default groups
#	# idk ask morgan or david or something 
#	#### perhaps just ask person to enter things, like ""guess the package manager""""
#	#git clone script front for os syntax change/shtuff 
#	#clone should install (nvim make alias, alias nvim to vim, change colors lmao)
#	#run alias shtuff, set up anything that needs to be set up
#	#make as lightweight as possible
#	#pull all users and all groups
#	#hopefully prompt user for PW change stuff
#	#timer maybe?
#	#ansible timer/color change/notifications
#	#LAMP for that OS 
#	#set up basic stuff lime email, secure what needs to be secure
#	#create file watcher
#	#create SSH watcher
#	#keygen SSL
#	#ask to close ports
#	#ps aux n stuff
#	#maybe term split? just need to up productivity
#	#cpu/other usage
#	#ldap maybe
#	#gen names for other ip's for that comp
#	#fuckin jenkins
#fi

printf "\n***IP ADDRESSES***\n"
if  hash ip addr 2>/dev/null  ; then
ip addr | awk '
/^[0-9]+:/ {
  sub(/:/,"",$2); iface=$2 }
/^[[:space:]]*inet / {
  split($2, a, "/")
  print iface" : "a[1] }' | $adtfile
fi

printf "***LIST OF NORMAL USERS***\n"
dog=$(grep "^UID_MIN" /etc/login.defs)
cat=$(grep "^UID_MAX" /etc/login.defs)
awk -F':' -v min="${dog#UID_MIN}" -v max="${cat#UID_MAX}" '{if($3 >>= min && $3 <=max) print $1}' /etc/passwd | $adtfile



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
        printf "\nnetstat -punta failed trying netstat -lsof\n"
        { netstat -lsof  | $adtfile ;} > /dev/null 2>/dev/null; 
    fi
fi
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
