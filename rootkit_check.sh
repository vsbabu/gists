sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove -y && sudo apt clean
sudo apt install chkrootkit rkhunter -y && sudo rkhunter --update

sudo chkrootkit
sudo rkhunter --check