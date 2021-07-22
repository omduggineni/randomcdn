#!/bin/bash
PATTERN="\./files/*"

# Get list and count of files. Confirm with user if we should proceed
files=$(find ./files -not -path '*/\.*' -maxdepth 1 -type f | egrep -i "$PATTERN")
count=$(echo "$files" | wc -l | sed 's/^ *//') # The `sed` at the end removes whitespace from wc output
echo "Found $count files that match the pattern $PATTERN"
read -rp "Rename all? <Y/n> " prompt
if [[ $prompt == "n" || $prompt == "N" || $prompt == "NO" || $prompt == "no" ]]
then
  exit 0
fi
echo ""

# For every file, compute a SHA-256 hash and rename
IFS=$'\n' #make newlines the only iteration separator
for f in $files
do
  hash=$(shasum -a 256 "$f" | sed "s/ .*//g")
  ext=$(echo "$f" | sed 's/^.*\.//')
  # If you've already run this script on some of these files, we shouldn't duplicate them.
  if [[ $f == *"$hash"* ]]
  then
    echo "Skipping file. Name already contains the hash of its contents: $f"
    continue
  fi

  newName="$hash.$ext"

  # If a file with this name already exists, increment a number until it does not.
  # This is a likely duplicate, and the whole reason for running this script
  i=0
  while [ -f "$newName" ]; do
    let i=i+1
    newName="$hash ($i).$ext"
  done

  echo "./files/$newName   <-   $f"
  mv "$f" "./files/$newName"

done
