#!/usr/bin/env bash
#
# This script will:
# 1. Git clone the latest kuttl test repo.
# 2. Oc login into the target remote OCP server (requires $OCP_SERVER and $OCP_PASS env vars)
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
TMPDIR="$(mktemp -d)" &> /dev/null
KUTTL_REPO="${KUTTL_REPO:-"https://gitlab.cee.redhat.com/gitops/operator-e2e.git"}"
REPO_DIR="${REPO_DIR:-"operator-e2e"}"
OCP_USER="${OCP_USER:-"kubeadmin"}"


## TRAP
trap_exit() {
  print_log "INFO: Exited with status ${1}"
  rm -rf "${TMPDIR}"
  oc logout || true
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
    [[ "${linecallfunc}" != "0" ]] && print_log "DEBUG: $(sed "${linecallfunc}!d" ${0})"
  fi
}

trap 'trap_exit ${?}' EXIT SIGINT SIGTERM
trap 'trap_err ${?} ${LINENO} ${BASH_LINENO} ${BASH_COMMAND} $(printf "::%s" ${FUNCNAME[@]:-})' ERR


## FUNCTIONS
clone_repo() {
  print_log "INFO: Cloning Kuttl repo: ${KUTTL_REPO}"
  git -c http.sslVerify=false clone "${KUTTL_REPO}" "${TMPDIR}/${REPO_DIR}" &> /dev/null || return 2
  print_log "INFO: Successfully cloned ${KUTTL_REPO}"
}

oc_login() {
  print_log "INFO: Loging into ${OCP_SERVER}"
  oc login --insecure-skip-tls-verify=true \
  --username="${OCP_USER}" \
  --password="${OCP_PASS}" \
  "${OCP_SERVER}" &> /dev/null || return 3
  print_log "Info: Successfully loged into OCP cluster"
}

run_tests() {
  pushd "${TMPDIR}/operator-e2e/gitops-operator" &> /dev/null
  #
  ## TODO:
  ### Run all E2E suite and save result
  ### (this is a single smoke test)
  kubectl kuttl test ./tests/parallel \
  --config ./tests/parallel/kuttl-test.yaml \
  --test 1-021_validate_rolebindings || return 4
  popd
}


## RUN
{ clone_repo; } || { print_log "ERROR: Unable to clone Kuttl repo"; exit 2; }
{ oc_login; } || { print_log "ERROR: Unable to login into OCP API"; exit 3; }
{ run_tests; } || { print_log "ERROR: Unable to run Kuttl tests"; exit 4; }