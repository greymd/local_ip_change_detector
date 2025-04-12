#!/bin/bash
set -eu

# shellcheck disable=SC2155
readonly THIS_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
readonly CACHE_PATH="${THIS_DIR}/ip_cache.txt"

log () {
  local msg="$1"
  printf '%s\n' "$msg" >&2
}

get_local_ip () {
  local nic="$1"
  local ip_show=
  local ip_show_exit=
  if ! type ip > /dev/null 2>&1 ; then
    log "ip command not found"
    exit 1
  fi
  ip_show="$(ip addr show "$nic")"
  ip_show_exit="$?"
  if [[ "$ip_show_exit" -ne 0 ]]; then
    log "[ERROR] No IP address found for $nic"
    exit 1
  fi
  while read -r line; do
    if [[ "$line" =~ "inet " ]] ;then
      read -r _f1 f2 _f3 <<< "$line"
      echo "${f2%%/*}"
    fi
  done < <(printf '%s\n' "$ip_show")
}

read_cached_ip () {
  if [ -f "$CACHE_PATH" ]; then
    cat "$CACHE_PATH"
  fi
}

write_cached_ip () {
  local ip="$1"
  printf '%s\n' "$ip" > "$CACHE_PATH"
}

main () {
  local nic="$1"
  local local_ip=
  local cached_ip=
  local_ip="$(get_local_ip "$nic")"
  cached_ip="$(read_cached_ip)"
  if [[ -z "$cached_ip" ]]; then
    log "No cached IP, Creating new cache."
  fi
  if [[ "$local_ip" == "$cached_ip" ]]; then
    log "[NO CHANGE] Local IP has NOT changed: ${local_ip}"
    printf '%s\n' "${local_ip}"
    exit 0
  else
    write_cached_ip "$local_ip"
    log "[UPDATE] New Local IP is : ${local_ip}"
    printf '%s\n' "${local_ip}"
    exit 9
  fi
}

main ${1+"$@"}
