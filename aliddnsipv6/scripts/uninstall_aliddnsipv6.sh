#!/bin/sh

rm /koolshare/res/icon-aliddnsipv6.png > /dev/null 2>&1
rm /koolshare/webs/Module_aliddnsipv6.asp > /dev/null 2>&1
rm /koolshare/scripts/aliddnsipv6_config.sh > /dev/null 2>&1
rm /koolshare/scripts/aliddnsipv6_update.sh > /dev/null 2>&1
rm /koolshare/scripts/uninstall_aliddnsipv6.sh > /dev/null 2>&1

dbus remove __delay__aliddnsipv6_timer
dbus remove softcenter_module_aliddnsipv6_install
dbus remove softcenter_module_aliddnsipv6_version
dbus remove softcenter_module_aliddnsipv6_description
cru d aliddnsipv6
sed -i '/aliddnsipv6_update.sh/d' /jffs/scripts/wan-start
#dbus remove __event__onwanstart_aliddnsipv6
#dbus remove __delay__aliddnsipv6_timer
nvram set ddns_hostname_x=`nvram get ddns_hostname_old`