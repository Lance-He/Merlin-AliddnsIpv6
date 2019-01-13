#!/bin/sh

eval `dbus export aliddnsipv6_`

if [ "$aliddnsipv6_enable" != "1" ]; then
	nvram set ddns_hostname_x=`nvram get ddns_hostname_old`
    echo "not enable"
    exit
fi

now=`date`

die () {
    echo $1
    dbus ram aliddnsipv6_last_act="$now: failed($1)"
}

[ "$aliddnsipv6_curl" = "" ] && aliddnsipv6_curl=":0000:0000:0000:0000"
[ "$aliddnsipv6_dns" = "" ] && aliddnsipv6_dns="223.5.5.5"
[ "$aliddnsipv6_ttl" = "" ] && aliddnsipv6_ttl="600"

Host_ipv6=${aliddnsipv6_curl}

Router_arIpAddress6=`ip addr show br0 | grep "inet6.*global" | awk '{print $2}' | awk -F"/" '{print $1}'|cut -d ':' -f 1,2,3,4`
len=$(echo ${Router_arIpAddress6} |wc -L)
Router_ipv6=${Router_arIpAddress6:0:${len}}
ipv6=${Router_ipv6}${Host_ipv6} || die "$ipv6"

#support @ record nslookup
if [ "$aliddnsipv6_name" = "@" ]
then
  current_ipv6=`nslookup $aliddnsipv6_domain $aliddnsipv6_dns 2>&1`
else
  current_ipv6=`nslookup $aliddnsipv6_name.$aliddnsipv6_domain $aliddnsipv6_dns 2>&1`
fi

if [ "$?" -eq "0" ]
then
    current_ipv6=`echo "$current_ipv6" | grep 'Address 1' | tail -n1 | awk '{print $NF}'`

    if [ "$ipv6" = "$current_ipv6" ]
    then
        echo "skipping"
        dbus set aliddnsipv6_last_act="$now: skipped($ipv6)"
	nvram set ddns_enable_x=1
#web ui show without @.
        if [ "$aliddnsipv6_name" = "@" ] ;then
          nvram set ddns_hostname_x="$aliddnsipv6_domain"
        else
          nvram set ddns_hostname_x="$aliddnsipv6_name"."$aliddnsipv6_domain"
	  ddns_custom_updated 1
          exit 0
	fi
    fi 
# fix when A record removed by manual dns is always update error
else
    unset aliddnsipv6_record_id
fi


timestamp=`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"`

urlencode() {
    # urlencode <string>
    out=""
    while read -n1 c
    do
        case $c in
            [a-zA-Z0-9._-]) out="$out$c" ;;
            *) out="$out`printf '%%%02X' "'$c"`" ;;
        esac
    done
    echo -n $out
}

enc() {
    echo -n "$1" | urlencode
}

send_request() {
    local args="AccessKeyId=$aliddnsipv6_ak&Action=$1&Format=json&$2&Version=2015-01-09"
    local hash=$(echo -n "GET&%2F&$(enc "$args")" | openssl dgst -sha1 -hmac "$aliddnsipv6_sk&" -binary | openssl base64)
    curl -s "http://alidns.aliyuncs.com/?$args&Signature=$(enc "$hash")"
}

get_recordid() {
    grep -Eo '"RecordId":"[0-9]+"' | cut -d':' -f2 | tr -d '"'
}

query_recordid() {
    send_request "DescribeSubDomainRecords" "SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&SubDomain=$aliddnsipv6_name1.$aliddnsipv6_domain&Timestamp=$timestamp"
}

update_record() {
    send_request "UpdateDomainRecord" "RR=$aliddnsipv6_name1&RecordId=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&TTL=$aliddnsipv6_ttl&Timestamp=$timestamp&Type=AAAA&Value=$(enc $ipv6)"
}

add_record() {
    send_request "AddDomainRecord&DomainName=$aliddnsipv6_domain" "RR=$aliddnsipv6_name1&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&TTL=$aliddnsipv6_ttl&Timestamp=$timestamp&Type=AAAA&Value=$(enc $ipv6)"
}

#add support */%2A and @/%40 record
case  $aliddnsipv6_name  in
      \*)
        aliddnsipv6_name1=%2A
        ;;
      \@)
        aliddnsipv6_name1=%40
        ;;
      *)
        aliddnsipv6_name1=$aliddnsipv6_name
        ;;
esac

if [ "$aliddnsipv6_record_id" = "" ]
then
    aliddnsipv6_record_id=`query_recordid | get_recordid`
fi
if [ "$aliddnsipv6_record_id" = "" ]
then
    aliddnsipv6_record_id=`add_record | get_recordid`
    echo "added record $aliddnsipv6_record_id"
else
    update_record $aliddnsipv6_record_id
    echo "updated record $aliddnsipv6_record_id"
fi

# save to file
if [ "$aliddnsipv6_record_id" = "" ]; then
    # failed
    dbus ram aliddnsipv6_last_act="$now: failed"
    nvram set ddns_hostname_x=`nvram get ddns_hostname_old`
else
    dbus ram aliddnsipv6_record_id=$aliddnsipv6_record_id
    dbus ram aliddnsipv6_last_act="$now: success($ipv6)"
    nvram set ddns_enable_x=1
#web ui show without @.
    if [ "$aliddnsipv6_name" = "@" ] ;then
        nvram set ddns_hostname_x="$aliddnsipv6_domain"
        ddns_custom_updated 1
    else
        nvram set ddns_hostname_x="$aliddnsipv6_name"."$aliddnsipv6_domain"
        ddns_custom_updated 1
    fi
fi
