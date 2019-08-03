#!/bin/bash
#
# Owner: Ali Jabir
# Email: syedalijabir@gmail.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Color codes
ERROR='\033[1;31m'
GREEN='\033[0;32m'
TORQ='\033[0;96m'
HEAD='\033[44m'
INFO='\033[0;33m'
NORM='\033[0m'

function log() {
  echo -e "[$(basename $0)] $@"
}

function check_amount() {
  if [[ -z ${1} ]] || [[ ! $1 =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    log "${ERROR}Invalid currency [${1}].${NORM}"
    exit 1
  fi
}

function check_currency() {
  if [[ -z ${1} ]] || [[ ! $1 =~ ^[A-Z]{3}$ ]]; then
    log "${ERROR}Invalid currency [${1}].${NORM}"
    exit 1
  fi
}

# Usage function for the script
function usage () {
  cat << DELIM__
usage: $(basename $0) [options] [parameter]
Options:
  -a, --amount          Amount to convert e.g. 500
                        Default 1000
  -f, --from            Source currency e.g. EUR
                        Required.
  -t, --to              Target currency e.g. GBP
                        Required.
  -h, --help            Display help menu
DELIM__
}

# read the options
TEMP=$(getopt -o f:t:a:h --long from:,to:,amount:,help -n 'get_rate.sh' -- "$@")
if [[ $? -ne 0 ]]; then
  usage
  exit 1
fi
eval set -- "$TEMP"

# extract options
while true ; do
  case "$1" in
    -a|--amount) AMOUNT=$2;   check_amount ${AMOUNT};     shift 2 ;;
    -f|--from)   SRC_CURR=$2; check_currency ${SRC_CURR}; shift 2 ;;
    -h|--help)   usage ; exit 1 ;;
    -t|--to)     TRG_CURR=$2; check_currency ${TRG_CURR}; shift 2 ;;
    --) shift ; break ;;
    *) usage ; exit 1 ;;
  esac
done

AMOUNT=${AMOUNT:-1000}
SRC_CURR=${SRC_CURR:-}
TRG_CURR=${TRG_CURR:-}

if [[ -z ${SRC_CURR} ]] || [[ -z ${TRG_CURR} ]]; then
  usage
  exit 1
fi

CONFIG=~/.tw/config
API_ENDPOINT="https://api.transferwise.com"

if [[ -r ${CONFIG} ]]; then
  source ${CONFIG}
else
  log "${ERROR}Config file [${CONFIG}] not found. ${NORM}"
  exit 1
fi

if [[ -z ${API_TOKEN} ]]; then
  log "${ERROR}API token not defined in ${CONFIG}. ${NORM}"
  exit 1
fi

PROFILE_ID=$(curl -s -X GET ${API_ENDPOINT}/v1/profiles \
     -H "Authorization: Bearer ${API_TOKEN}" | jq .[0].id)

# RATE=$(curl -s -X GET "${API_ENDPOINT}/v1/rates?source=${SRC_CURR}&target=${TRG_CURR}" \
#      -H "Authorization: Bearer ${API_TOKEN}"| jq .[0].rate)
# log "${INFO}Rate: ${RATE}${NORM}"

RESP=$(curl -s -X GET "${API_ENDPOINT}/v1/quotes?source=${SRC_CURR}&target=${TRG_CURR}&rateType=FIXED&sourceAmount=${AMOUNT}" \
     -H "Authorization: Bearer ${API_TOKEN}" | jq)
# echo "${RESP}"

HAS_ERR=$(echo "${RESP}" | jq 'has("errors")')
if [[ ${HAS_ERR} == "true" ]]; then
  log "${ERROR}$(echo ${RESP} | jq .errors[0].message | tr -d \")${NORM}"
  exit 1
fi

printf "%5s\t%s\n" $(echo -e "${INFO}${SRC_CURR}${NORM}") $(echo ${RESP} | jq .sourceAmount)
printf "%5s\t%s\n" $(echo -e "${INFO}${TRG_CURR}${NORM}") $(echo ${RESP} | jq .targetAmount)
printf "%5s\t%s\n" $(echo -e "${INFO}Rate${NORM}") $(echo ${RESP} | jq .rate)
printf "%5s\t%s\n" $(echo -e "${INFO}Fee${NORM}") $(echo ${RESP} | jq .fee)
exit 0
