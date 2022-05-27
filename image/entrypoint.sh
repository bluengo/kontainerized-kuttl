#!/usr/bin/env bash
#
# This script will:
# 1. Git clone the latest kuttl test repo.
# 2. Oc login into the target remote OCP server.
# 3. Run E2E tests from the Kuttl suite repo.
set -Eeo pipefail

print_log() {
  local timestamp="$(date --utc '+%Y-%m-%d %H:%M:%S UTC')"
  echo -e "${timestamp} - ${@}"
}

## VARIABLES
if [[ -z "${OCP_SERVER}" ]] || [[ -z "${OCP_PASS}" ]]; then
  print_log "Missing environment variable: OCP_SERVER and/or OCP_PASS"
  exit 1
fi
TMPDIR="$(mktemp -d)"
KUTTL_REPO="${KUTTL_REPO:-'https://gitlab.cee.redhat.com/gitops/operator-e2e/'}"
OCP_USER="${OCP_USER:-'kubeadmin'}"

## TRAP
trap_exit() {
  print_log "INFO: Exited with status ${1}"
  rm -rf "${TMPDIR}"
}

trap_err() {
  local exitstat="${1}"       # $?
  local line="${2}"           # $LINENO
  local linecallfunc="${3}"   # $BASH_LINENO
  local command="${4}"        # $BASH_COMMAND
  local funcstack="${5}"      # $FUNCNAME

  print_log "ERROR: '${command}' failed at line ${line} - exited with status: ${exitstat}"

  if [[ "${funcstack}" != "::" ]]; then
    if [[ "${linecallfunc}" != "" ]]; then
      local called="Called at line ${linecallfunc}"
    fi
    print_log "DEBUG: Error in ${funcstack}. ${called}"
    print_log "DEBUG: \e[1;31m $(sed "${linecallfunc}!d" ${0})\e[0m"
  fi
}

trap 'trap_exit ${?}' EXIT SIGINT SIGTERM
trap 'trap_err ${?} ${LINENO} ${BASH_LINENO} ${BASH_COMMAND} $(printf "::%s" ${FUNCNAME[@]:-})' ERR

## FUNCTIONS
clone_repo() {
  git clone "${KUTTL_REPO}" "${TMPDIR}"
}

oc_login() {
  oc login --insecure-skip-tls-verify=true \
  --username="${OCP_USER}" \
  --password="${OCP_PASS}" \
  "${OCP_SERVER}"
}

run_tests() {
  pushd "${TMPDIR}/operator-e2e/gitops-operator"
  kubectl kuttl test ./tests/sequential --config ./tests/sequential/kuttl-test.yaml --test 1-001_validate_kam_service
  popd
}


## RUN
clone_repo
#oc_login
#run_tests