#!/bin/bash

set -e

site_url=$1
if [ -z "$site_url" ]; then
  echo "Usage: $0 <site_url>"
  exit 1
fi

artist=$(cat tracks.json | jq --raw-output '.items[0] .artists[0] .name')
track=$(cat tracks.json | jq --raw-output '.items[0] .name')

find_str=">$artist: $track</a>"
echo "Finding $find_str"

res=$(curl -s "$site_url" | grep "$find_str")
if [ -z "$find_str" ]; then
  echo "Failed to find $find_str in $site_url"
  exit 1
fi

echo "Successfully found string $find_str in $site_url"
