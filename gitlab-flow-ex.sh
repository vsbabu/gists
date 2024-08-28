#!/usr/bin/env bash
# This assumes it is being run inside tmux
# Demo is at https://youtu.be/Kc7wJkg1mlI
NOTETHIS() {
  #tmux send-keys -t .1 C-z 'clear && git log --graph  --decorate --date=relative --oneline --all' Enter
  set +x
  tmux send-keys -t .2 'R'
  #tmux send-keys -t .1 C-z 'clear && git viz' Enter
  tmux send-keys -t .0 C-z "clear && toilet -f wideterm $@ --gay" Enter
  echo ">>> $@"
  sleep 1
  set -x
}

rm -fR repo work
mkdir repo &&  cd repo
git --bare init
cd ..
git clone repo/ work
cd work
tmux send-keys -t .2 C-z 'cd work' Enter
tmux send-keys -t .0 C-z 'PS1=%' Enter

echo "*.tmp" > .gitignore
set -x
git add .gitignore
git commit -m "Init"
git push

tmux send-keys -t .2 C-z 'tig' Enter
#hide the Author and Date cols in tig
tmux send-keys -t .2 'AAAADDDD' Enter
tmux send-keys -t .0 C-z 'clear' Enter

NOTETHIS "Initialized master. Create preprod"

git checkout -b preprod
git push origin preprod
git branch --set-upstream-to=origin/preprod preprod
NOTETHIS "All set with preprod. Create release"

git checkout -b release
git push origin release
git branch --set-upstream-to=origin/release release
NOTETHIS "All set with release. Switch to master"

git checkout master
git pull

echo "# This is for first commit" > dummy.txt
git add dummy.txt
git commit -m "first commit"
git push
NOTETHIS "Add first commit"

git checkout master
git pull
git checkout -b feature/f01
echo "# f01 feature" >> dummy.txt
git add dummy.txt
git commit -m "f01 feature"
git push origin feature/f01
NOTETHIS "Added feature/f01"


git checkout master
git pull
git checkout -b feature/f02
echo "# f02 feature" >> dummy.txt
git add dummy.txt
git commit -m "f02 feature"
git push origin feature/f02
NOTETHIS "Added feature/f02"

git checkout master
git pull
git checkout -b feature/f03
echo "# f03 feature" >> dummy.txt
git add dummy.txt
git commit -m "f03 feature"
git push origin feature/f03
NOTETHIS "Added feature/f02"

# now give f01 and f02 to QA
git checkout master
git pull
git checkout preprod
git pull

git merge origin/feature/f01
git merge origin/feature/f02
# this will cause conflict; edit dummy.txt to remove all that
grep '^# ' dummy.txt > x; mv x dummy.txt

git add dummy.txt
git commit -m "QA drop"
git push origin preprod
NOTETHIS "QA drop in preprod"
 
git pull
echo "# bug fix qa01" >> dummy.txt 
git add dummy.txt
git commit -m "bug fix 01 on qa" dummy.txt
git push
NOTETHIS "Added fix to qa drop"

#now release this
git checkout release
git pull
git merge origin/preprod
git push
git tag  v1.0
git push origin v1.0
NOTETHIS "QA is now in to release v1.0"

# merge qa into master
git checkout master
git pull
git merge origin/preprod
git push
NOTETHIS "Merged preprod with fix to master"

#now let us give f03 to QA - let us first add f03 to master
git checkout master
git pull
git merge origin/feature/f03
# merge conflict - fix it
grep '^# ' dummy.txt > x; mv x dummy.txt
git commit -a -m "f03 ready for QA"
git push
NOTETHIS "f03 given to preprod"

git checkout preprod
git pull
git merge origin/master
git push

echo "# bug fix 02" >> dummy.txt
git add dummy.txt
git commit -m "bug fix 02"
git push
NOTETHIS "a fix on preprod"

# release it
git checkout release
git pull
git merge origin/preprod
git tag v2.0
git push origin v2.0
git push
NOTETHIS "Released that as v2.0"

git checkout master
git pull
git merge origin/preprod
git push
NOTETHIS "Preprod merged to master"

## hot fix needed in production
# get the release branch to hfpreprod; build there and merge to master
git checkout release
git pull
### git push  #why is this now ahead? TODO
git checkout -b release_hf01
echo "# Production HF01" >> dummy.txt
git add dummy.txt 
git commit -m "HF 01"
git push origin release_hf01
git branch --set-upstream-to=origin/release_hf01 release_hf01
git push

git checkout release
git pull
git merge release_hf01
git commit -m "Merged hf01"
git tag v2.1
git push origin v2.1
git push
NOTETHIS "Added HF on release v2.1"

git checkout preprod
git pull
git merge release_hf01
git commit -m "Merged hf01"
git push
NOTETHIS "Get HF into preprod"

git checkout master
git pull            #here I am one commit ahead - how
git merge release_hf01
git commit -m "Merged hf01"
git push
NOTETHIS "Got HF into master too"

git branch -d release_hf01
git push origin --delete release_hf01
NOTETHIS "Deleted HF01 branch"