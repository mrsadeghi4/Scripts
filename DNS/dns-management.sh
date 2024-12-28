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
