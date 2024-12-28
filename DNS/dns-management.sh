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



