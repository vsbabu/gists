#!/bin/bash
cd ~/code
for d in `find  . -type d -name '.git' -exec dirname {} \;`;
do
  cd $d && pwd
  git fetch --all && git pull && git gc
  cd -
done
fi