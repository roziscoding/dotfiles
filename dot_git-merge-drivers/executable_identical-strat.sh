#!/bin/bash
set -e

OPERATION="$1"
BRANCH="$2"

if [ -z "$OPERATION" ] || [ -z "$BRANCH" ]; then
  echo "Usage: git identical <merge|rebase> <branch>"
  exit 1
fi

if [ "$OPERATION" != "merge" ] && [ "$OPERATION" != "rebase" ]; then
  echo "Unknown operation: $OPERATION (expected 'merge' or 'rebase')"
  exit 1
fi

# Save original .gitattributes if it exists
if [ -f .gitattributes ]; then
  cp .gitattributes .gitattributes.backup
fi

# Write temp .gitattributes without staging
echo "* merge=identical" >.gitattributes

# Perform the requested operation
if [ "$OPERATION" = "merge" ]; then
  git merge "$BRANCH"
else
  git rebase "$BRANCH"
fi

# Restore the original .gitattributes
if [ -f .gitattributes.backup ]; then
  mv .gitattributes.backup .gitattributes
else
  rm -f .gitattributes
fi

echo "✅ $OPERATION finished successfully. Temporary .gitattributes cleaned up."
