#!/bin/bash

# $1 = current branch's version
# $2 = incoming branch's version
# $3 = file to write the merge result

# Compare ignoring whitespace differences
if diff -w "$1" "$2" >/dev/null; then
  cp "$1" "$3"
  exit 0
else
  exit 1
fi
