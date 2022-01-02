#!/bin/bash

set -e

src=$1
if [ -z "$src" ]; then
  echo "Usage: $0 <src>"
  exit 1
fi

artist=$(cat tracks.json | jq --raw-output '.items[0] .artists[0] .name')
track=$(cat tracks.json | jq --raw-output '.items[0] .name')

find_str=">$artist: $track</a>"
echo "Finding $find_str"

if [[ $src == http* ]]; then
  res=$(curl -s "$src")
else
  res=$(cat "$src")
fi

echo "Result: $res"

res=$(echo $res | grep "$find_str")

if [ -z "$find_str" ]; then
  echo "Failed to find $find_str in $src"
  exit 1
fi
echo "Successfully found string $find_str in $src"
