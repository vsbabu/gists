#!/bin/bash
for f in "$@"
do
  inp="$f"
  oup=`echo "$inp".gpg`
  gpg -e -r "CHANGE_MY_KEY_NAME" "$inp"
  echo "$inp -> $oup"
done
exit 0

# -- one below is for decryption
for f in "$@"
do
  inp="$f"
  oup=`echo "$inp"|sed 's/.gpg//g'`
  gpg -d -o "$oup" "$inp"
  echo "$inp -> $oup"
done