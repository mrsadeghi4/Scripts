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


function serial_number {
  DMN=`echo $1 | awk -F. '{print $NF}'`
  RC=`echo $1 | rev | cut -d'.' -f2- | rev`
  # fetch existence serial number
  OLD_SN=`grep "serial" /var/named/$DMN.zone | cut -d';' -f 1| awk '{print $NF}'`
  ESN=`grep "serial" /var/named/$DMN.zone | cut -d';' -f 1| awk '{print $NF}' | cut -c 1-8`
  NM=`grep "; serial" /var/named/$DMN.zone | cut -d';' -f 1| awk '{print $NF}' | cut -c 9-10`
  SN=$(echo "`timedatectl|grep "Local time"|awk '{print $4}'|sed -e 's/-//g'`")
  NEW_SN=$(echo "`timedatectl|grep "Local time"|awk '{print $4}'|sed -e 's/-//g'`01")
  if [[ $ESN != $SN ]]; then
    sed -ie '/'$ESN'/ s//'$NEW_SN'/' /var/named/$DMN.zone
    echo "Serial Number $NEW_SN added."
  else
    NM=$(($NM+1))
    SN=$(echo "`timedatectl|grep "Local time"|awk '{print $4}'|sed -e 's/-//g'`$NM")
    sed -i 's/'$OLD_SN'/'$SN'/' /var/named/$DMN.zone
    echo "Serial Number $SN added."
  fi
}


function search_record {
  DMN=`echo $1 | awk -F. '{print $NF}'`
  RC=`echo $1 | rev | cut -d'.' -f2- | rev`
  # should remove last part of RC and check record in example.zone
  ERC=`grep -i -m 1 "^$RC[[:space:]]" /var/named/$DMN.zone | awk '{print $1}'`
  EIP=`grep -i -m 1 "^$RC[[:space:]]" /var/named/$DMN.zone | awk '{print $NF}'`
  if [[ -f /var/named/$DMN.zone ]]; then
    if [[ $ERC != $RC ]]; then
      return 1
    elif [[ $ERC != $RC ]] && [[ $EIP != $2 ]]; then
      #echo -e "\n${YELLOW}[INFO] Record not exist!${WHITE}\n"
      return 1
    elif [[ $ERC == $RC ]] && [[ $EIP != $2 ]]; then
      return 1
    elif [[ $ERC == $RC ]] && [[ $EIP == $2 ]]; then
      echo -e "\n${GREEN}[INFO] Record $1 with $2 exist! ${WHITE}\n"
      return 0
    fi
  else
    echo -e "\n${RED}[Error] Zone File not exist! ${WHITE}\n"
    return 1
  fi
}


function add_record {
  # check if it would be A record or other records are validate
  validate_input $2 $3
  if [[ $? -ne 0 ]]; then
    echo -e "\n${RED}[Error] IP address <$2> is not valid.${WHITE}\n"
  exit 1
  fi
  IFS='.' read -r -a fqdn_parts <<< $1
  #for i in "${!fqdn_parts[@]}" ; do
  #done
  DMN=`echo $1 | awk -F. '{print $NF}'`
  RC=`echo $1 | rev | cut -d'.' -f2- | rev`
  search_record $1 $2
  #grep -w "$RC      A $5" /var/named/$DMN.zone > /dev/null
  if [[ $? -eq 0 ]]; then
    #echo -e "\n${YELLOW}[WARN] DNS record <$1> exist.${WHITE}\n"
    return 1
  else
    # fetch existence serial number
    serial_number $1
    sed -i '/$ORIGIN '$DMN'\./a '$RC'			'$3'	'$2'' /var/named/$DMN.zone
    if [[ -f /var/named/$DMN.zone ]]; then
      echo -e "\n${GREEN}[INFO] DNS record <$1> added successfully.${WHITE}\n"
      exit 0
    else
      echo -e "\n${RED}[Error] Zone NOT exist.${WHITE}\n"
      exit 1
    fi
  fi
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


function search_domain {
    #CURRENT_PATTERN=""
    #IFS='.' read -r -a parts <<< "$1"
    DMN=`echo $1 | awk -F. '{print $NF}'`
    if [[ -f /var/named/$DMN.zone ]]; then
      #echo -e "\n${GREEN}[INFO] Zone <$DMN> exist.${WHITE}\n"
      return 0
    else
      #echo -e "\n${RED}[Error] Zone <$DMN> not exist.${WHITE}\n"
      return 1
    fi
}


function remove_record {
  DMN=`echo $1 | awk -F. '{print $NF}'`
  RC=`echo $1 | rev | cut -d'.' -f2- | rev`
  search_record $1 $2
  if [[ $? -eq 0 ]]; then
    sed -i "/^$RC[[:space:]]/d" /var/named/$DMN.zone
    serial_number $1
    echo -e "\n${GREEN}[INFO] Record <$1> successfully deleted.\n${WHITE}\n"
    exit 0
  else
    echo -e "\n${YELLOW}[INFO] Record not exist!${WHITE}\n"
    exit 1
  fi
}


while [[ $# -ne 0 ]]; do
  case $1 in
    -h)
      help
      exit 0
      ;;
    -t)
      if [[ $# -lt 5 ]]; then
        echo -e "\n${RED}[Error] Please enter command as help!${WHITE}\n"
        help
        exit 1
      else
        TYPE=$2
        shift 2
      fi
      ;;
    -a)
      RECORD=$2
      IP=$3
      add_record $RECORD $IP $TYPE
      if [[ $? -ne 0 ]]; then
        help
        exit 1
      fi
      shift 2
      ;;
    -r)
      remove_record $2 $3
      shift 2
      ;;
    -d)
      add_domain $2
      if [[ $? -ne 0 ]]; then
        help
        exit 1
      fi
      ;;
    -s)
      search_record $2 $3
      if [[ $? -eq 0 ]]; then
        echo -e "\n${GREEN}[INFO] Founded records are:\n<$2>\n${WHITE}\n"
        exit 0
      else
        echo -e "\n${YELLOW}[INFO] Record <$2> not exist!${WHITE}\n"
        help
        exit 1
      fi
      ;;
    -S)
      search_domain $2
      DMN=`echo $1 | awk -F. '{print $NF}'`
      if [[ $? -eq 0 ]]; then
        echo -e "\n${GREEN}[INFO] Zone <$DMN> exist.${WHITE}\n"
        exit 0
      else
        echo -e "\n${RED}[Error] Zone <$DMN> not exist.${WHITE}\n"
        help
        exit 1
      fi
      ;;
    *)
      break
      ;;
  esac
done
