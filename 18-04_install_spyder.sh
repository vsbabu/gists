# install pip3 and virtualenv
sudo apt-get install python3-pip
sudo pip3 install virtualenv

# get spyder into say /opt/apps/spyder
mkdir -p /opt/apps && cd /opt/apps
https://github.com/spyder-ide/spyder.git && cd spyder

# setup dependencies
virtualenv -p python3 venv
source venv/bin/activate

#pyqt5.10 has to be used because of https://github.com/spyder-ide/spyder/issues/6577 in 5.10.1
pip3 install pyqt5==5.10 qtconsole rope jedi pyflakes sphinx pygments pylint pycodestyle psutil nbconvert qtawesome pickleshare pyzmq qtpy chardet pandas numpydoc cloudpickle pandas numpy sympy scipy cython matplotlib

# start spyder script - assumes navigating to this directory first
cat <<EOF > /usr/local/bin/spyder
cd /opt/apps/spyder
source venv/bin/activate
python3 bootstrap.py 
EOF
chmod +x /usr/local/bin/spyder