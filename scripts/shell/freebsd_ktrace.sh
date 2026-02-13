#!/bin/sh

if [ -z "$1" ]; then
  echo "Usage: $0 <program> [args...]"
  exit 1
fi

ktrace -d -i "$@"
wait $!












kdump | grep -E '^[0-9]+:.*call' | awk '
{
    sys_call = $3
    args = substr($0, index($0, $4))
    printf "%-25s %s\n", sys_call, args
}
'
