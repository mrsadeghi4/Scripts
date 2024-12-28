#!/usr/bin/bash

GREEN='\033[92m'
RED='\033[91m'
WHITE='\033[97m'
YELLOW='\033[1;93m'
IP=''
RECORD=''
DOMAIN=''
TYPE=''

readonly GREEN
readonly RED
readonly WHITE
readonly YELLOW


function help {
    echo -e "
Usage: $0 [OPTIONS] <command>
        -h: Show this help output
        -a: Add new record
        -t: record-type(A, AAAA, CNAME, MX, SPF, DKIM, ...)
        -r: remove record
        -d: Add new domain
        -s: Search record
        -S: Search domain\n
Examples:\n
        $0 -t <record-type> -r foo.example.com 10.20.30.40
        $0 -r example.com 2.2.2.2
        $0 -d example.com\n
    "
}


if [[ $# -eq 0 ]]; then
  help
  exit 0
fi


function validate_input {
  local IP=$1
  local STAT=1
  if [[ $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ && $2 == "A" ]]; then
    OIFS=$IFS
    IFS='.'
    IP=($IP)
    IFS=$OIFS
    [[ ${IP[0]} -le 255 && ${IP[1]} -le 255
    && ${IP[2]} -le 255 && ${IP[3]} -le 255 ]]
      STAT=$?
    fi
    return $STAT
}


function add_domain {
  DMN=`echo $1 | awk -F. '{print $NF}'`
  ZONE=$(cat << EOF
zone "$DMN" IN {
  type master;
  file "$DMN.zone";
  allow-update { none; };
  allow-query  { any; };
};
EOF
)
  escaped_zone=$(echo $ZONE | sed ':a;N;$!ba;s/\n/\\n/g')
  grep -w ".$DMN" /etc/named.conf
  if [[ $? -ne 0  ]]; then
    sed -i  "/rfc1912/i $escaped_zone" /etc/named.conf
  fi
  if [[ -f /var/named/$DMN.zone ]]; then
    echo -e "\n${RED}[Error] Zone file <$DMN> exist.${WHITE}\n"
    exit 1
  else
    cp -ap /var/named/named.empty /var/named/$DMN.zone
    HN=`hostname`
    SN=$(echo "`timedatectl|grep "Local time"|awk '{print $4}'|sed -e 's/-//g'`01")
    sed -i -e '0,/3H/ s//1D/' -e '0,/\@/ s//'$DMN'./' -e 's/\@/'$HN'/1' -e 's/rname.invalid/root.'$DMN'/' \
        -e '0,/0/ s//'$SN'/' -e 's/127.0.0.1/'$2'/' -e '/AAA/d' /var/named/$DMN.zone
    echo "\$ORIGIN $DMN." >> /var/named/$DMN.zone
    echo -e "\n${GREEN}[INFO] Zone file <$DMN> successfully created. ${WHITE}\n"
    
    exit 0
  fi
}
