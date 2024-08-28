# Create  repo
mkdir repo
cd repo
git init --bare
# Clone
cd ..
mkdir wd1 #working directory
cd wd1
git clone ../repo .
# Add a file into master
vi hello.py
git add hello.py
git commit -m "Initial version"
git push
# Make remote RC01
git config --global push.default current
git checkout -b RC01
# Make code change in RC01, test and push
vi hello.py
git add hello.py
git commit -m "RC01 version"
git push
# Merge RC01 to master
git checkout master
git pull origin master
git merge RC01
git push origin master
# Make remote RC02
git checkout -b RC02
# Make code change and push
vi hello.py
git add hello.py
git commit -m "RC02 version"
git push
# Make HF01 remote
git checkout master
git checkout -b HF01
# Make code change and push to HF01
vi hello.py
git add hello.py
git commit -m "HF01 version"
git push
# Merge HF01 to master
git checkout master
git pull origin master
git merge HF01
git push origin master
# Merge RC02 to master 
git checkout master
git pull origin master
git merge RC02
# fix conflicts and merge
git config --global merge.tool meld
git mergetool
rm -f *.orig
git add .
git commit -m "Merged"
git push origin master

git log --graph --oneline --all
# and it looks like below
# *   961e7a0 Merged RC
# |\  
# | * a3da22d RC02 version
# * | 85f8613 HF01 version
# |/  
# * 0846374 RC01
# * d1beac6 Initial version

# now let us work on a longer release during with two HFs have to be
# deployed
git checkout -b RC03
vi util.py
git add util.py
git commit -m "New util.py added"
git push
# oh oh, new HF needed. We will skip HF02 and jump to HF03!
git checkout master
git checkout -b HF03
vi hello.py
git add hello.py
git commit -m "HF03 Fixed"
git push
# now HF03 is getting tested, we found an even more critical and simpler fix in 
# production, ie master. Fix that now!
git checkout master
git checkout -b HF04
vi hello.py
git add hello.py
git commit -m "HF04 Fixed"
git push
# HF04 is deployed in prod, so let us merge it to master
git checkout master
git pull origin master
git merge HF04
git push origin master
# now HF03 is also tested, let us merge that to master
# and deploy
git checkout master
git pull origin master
git merge HF04 # this will conflict. So merge tool.
git mergetool
rm -f *.orig
git add hello.py
git  commit -m "Merged HF03"
git push origin master

git log --graph --oneline --all
# And you get this below
# *   0d5cea5 Merged HF03
# |\  
# | * 8f6cdf5 HF03 fixed
# * | e847d0b HF04 fixed
# |/  
# | * 5334b0f New util.py added
# |/  
# *   961e7a0 Merged RC
# |\  
# | * a3da22d RC02 version
# * | 85f8613 HF01 version
# |/  
# * 0846374 RC01
#* d1beac6 Initial version

# Now, RC03 is to be tested. Need to deploy; so merge it to master.
git checkout master
git pull origin master
git merge RC03
git push origin master

# And you get this below.
git log --graph --oneline --all
# *   e1e384d Merge branch 'RC03'
# |\  
# | * 5334b0f New util.py added
# * |   0d5cea5 Merged HF03
# |\ \  
# | * | 8f6cdf5 HF03 fixed
# | |/  
# * | e847d0b HF04 fixed
# |/  
# *   961e7a0 Merged RC
# |\  
# | * a3da22d RC02 version
# * | 85f8613 HF01 version
# |/  
# * 0846374 RC01
# * d1beac6 Initial version


# Now, tag the current release as Release_03
git checkout master
git tag Release_03 master
git push origin Release_03