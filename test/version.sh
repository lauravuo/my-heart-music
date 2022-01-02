#!/bin/bash

set -e

src=$1
if [ -z "$src" ]; then
  echo "Usage: $0 <src>"
  exit 1
fi

res=$(curl -s "$src/version.txt")
version=$(cat ./VERSION)

if [[ $res == "$version"* ]]; then
  echo "Expected version $version found."
  exit 0
fi

echo "Version mismatch: $res (found) - $version (expected)"
exit 1
