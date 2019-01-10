#!/bin/sh

cp -r /tmp/aliddnsipv6/res/* /koolshare/res
cp -r /tmp/aliddnsipv6/scripts/* /koolshare/scripts
cp -r /tmp/aliddnsipv6/webs/* /koolshare/webs

chmod 644 /koolshare/webs/Module_aliddnsipv6.asp
chmod 666 /koolshare/res/icon-aliddnsipv6.png
chmod 755 /koolshare/scripts/aliddnsipv6_*

# add icon into softerware center
dbus set softcenter_module_aliddnsipv6_install=1
dbus set softcenter_module_aliddnsipv6_version=0.0.2
dbus set softcenter_module_aliddnsipv6_description="阿里云解析自动更新IPv6"
