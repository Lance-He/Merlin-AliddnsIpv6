#!/bin/sh

if [ "`dbus get aliddnsipv6_enable`" = "1" ]; then
    cru a aliddnsipv6 "*/`dbus get aliddnsipv6_interval` * * * * sh /koolshare/scripts/aliddnsipv6_update.sh"
    sed -i '/aliddnsipv6_update.sh/d' /jffs/scripts/wan-start
    sleep 2
    echo sh /koolshare/scripts/aliddnsipv6_update.sh>>/jffs/scripts/wan-start
    echo cru a aliddnsipv6 \"*/`dbus get aliddnsipv6_interval` * * * * sh /koolshare/scripts/aliddnsipv6_update.sh\">>/jffs/scripts/wan-start
    #dbus set __event__onwanstart_aliddns="sh /koolshare/scripts/aliddnsipv6_update.sh"
    #dbus delay aliddnsipv6_timer `dbus get aliddnsipv6_interval` /koolshare/scripts/aliddnsipv6_update.sh
    # run once after submit
	sleep 2
	sh /koolshare/scripts/aliddnsipv6_update.sh
else
    cru d aliddnsipv6
    sed -i '/aliddnsipv6_update.sh/d' /jffs/scripts/wan-start
    #dbus remove __event__onwanstart_aliddns
    #dbus remove __delay__aliddnsipv6_timer
    nvram set ddns_hostname_x=`nvram get ddns_hostname_old`
fi
