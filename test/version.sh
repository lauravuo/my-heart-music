#!/bin/bash

set -e

src=$1
if [ -z "$src" ]; then
  echo "Usage: $0 <src>"
  exit 1
fi

version=$(cat ./VERSION)

matchVersion() {
  res=$(curl -s "$src/version.txt")

  if [[ $res == "$version"* ]]; then
    return 0
  else
    return 1
  fi
}

NOW=${SECONDS}
printf "Wait until deployment is ready\n"
while ! matchVersion; do
  printf "."
  waitTime=$(($SECONDS - $NOW))
  if ((${waitTime} >= 60)); then
    printf "\nVersion mismatch: $res (found) - $version (expected)\n"
    exit 1
  fi
  sleep 1
done

printf "\nExpected version $version found.\n"
