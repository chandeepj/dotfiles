_inArray_() {
  # v1.0.0
  # Determine if a value is in an array.
  # Usage: if _inArray_ "VALUE" "${ARRAY[@]}"; then ...
  local value="$1"
  shift
  for arrayItem in "$@"; do
    [[ "${arrayItem}" == "${value}" ]] && return 0
  done
  return 1
}

_list_contains_item_() {
  # v1.0.0
  # Tests if an item exists in a list.  Returns 0 if yes, 1 if no
  # usage: _list_contains_item_ "$list" "$item"
  # referance: https://stackoverflow.com/questions/8063228/how-do-i-check-if-a-variable-exists-in-a-list-in-bash
  local list="$1"
  local item="$2"
  if [[ $list =~ (^|[[:space:]])"$item"($|[[:space:]]) ]] ; then
    # yes, list include item
    return 0
  else
    return 1
  fi
}

_join_() {
  # v1.0.0
  # joins items together with a user specified separator
  # Taken whole cloth from: http://stackoverflow.com/questions/1527049/bash-join-elements-of-an-array
  #
  # Usage:
  #   _join_ , a "b c" d #a,b c,d
  #   _join_ / var local tmp #var/local/tmp
  #   _join_ , "${foo[@]}" #a,b,c
  local IFS="${1}"
  shift
  echo "${*}"
}

_setdiff_() {
  # v1.0.0
  # Given strings containing space-delimited words A and B, "setdiff A B" will
  # return all words in A that do not exist in B. Arrays in bash are insane
  # (and not in a good way).
  #
  #   Usage: _setdiff_ "${array1[*]}" "${array2[*]}"
  #
  # From http://stackoverflow.com/a/1617303/142339
  local debug skip a b
  if [[ "$1" == 1 ]]; then
    debug=1
    shift
  fi
  if [[ "$1" ]]; then
    local setdiffA setdiffB setdiffC
    # shellcheck disable=SC2206
    setdiffA=($1)
    # shellcheck disable=SC2206
    setdiffB=($2)
  fi
  setdiffC=()
  for a in "${setdiffA[@]}"; do
    skip=
    for b in "${setdiffB[@]}"; do
      [[ "$a" == "$b" ]] && skip=1 && break
    done
    [[ "$skip" ]] || setdiffC=("${setdiffC[@]}" "$a")
  done
  [[ "$debug" ]] && for a in setdiffA setdiffB setdiffC; do
    echo "$a ($(eval echo "\${#$a[*]}")) $(eval echo "\${$a[*]}")" 1>&2
  done
  [[ "$1" ]] && echo "${setdiffC[@]}"
}
