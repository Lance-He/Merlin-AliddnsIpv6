#!/bin/sh

cp -r /tmp/aliddnsipv6/res/* /koolshare/res
cp -r /tmp/aliddnsipv6/scripts/* /koolshare/scripts
cp -r /tmp/aliddnsipv6/webs/* /koolshare/webs

chmod a+x /koolshare/webs/Module_aliddnsipv6.asp
chmod a+x /koolshare/res/icon-aliddnsipv6.png
chmod a+x /koolshare/scripts/aliddnsipv6_*

# add icon into softerware center
dbus set softcenter_module_aliddnsipv6_install=1
dbus set softcenter_module_aliddnsipv6_version=0.4
dbus set softcenter_module_aliddnsipv6_description="自动更新设备的IPv6地址到阿里云"
