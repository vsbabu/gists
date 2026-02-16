#!/bin/bash

# Quick script to switch between dark and light themese for editors I use
# on LinuxMint.
TO_DARK=false
TO_MIXED=false
if [ $# -ge 1 ]; then
  shopt -s nocasematch
  if [ "$1" == "dark" ]; then
    TO_DARK=true
  fi
  if [ "$1" == "mixed" ]; then
    TO_MIXED=true
  fi
  shopt -u nocasematch
else
  current_hour=$(date +"%k")
  if [[ "$current_hour" -ge 19 ]] || [[ "$current_hour" -lt 7 ]]; then
    TO_DARK=true
  fi
fi
# Switch between Catppuccin Frappe and Latte flavours. Assumption is that these
# are already installed and the config files have one of it setup
#  wezterm, lazyvim, doom-emacs, vscode, btop, desktop
set -x
if $TO_DARK; then
  sed -i --follow-symlinks "s/latte/frappe/g" ~/.config/wezterm/sv_common.lua
  sed -i --follow-symlinks "s/latte/frappe/g" ~/.config/nvim/lua/plugins/colorscheme.lua
  sed -i --follow-symlinks "s/morning/habamax/g" ~/.config/nvim/light.nvim.lua
  sed -i --follow-symlinks "s/000000/e5e9f0/g" ~/.config/nvim/light.nvim.lua
  sed -i --follow-symlinks "s/eff1f5/2e3440/g" ~/.config/nvim/light.nvim.lua
  sed -i --follow-symlinks "s/latte/frappe/g" ~/.config/doom/config.el
  sed -i --follow-symlinks "s/latte/frappe/g" ~/.config/Code/User/settings.json
  sed -i --follow-symlinks "s/Latte/Frappé/g" ~/.config/Code/User/settings.json
  sed -i --follow-symlinks "s/Latte/Frappé/g" ~/.config/Antigravity/User/settings.json
  sed -i --follow-symlinks "s/latte/frappe/g" ~/.config/btop/btop.conf
  case "$XDG_SESSION_DESKTOP" in
  "KDE")
    lookandfeeltool -a org.kde.breezedark.desktop
    ;;
  "cinnamon")
    gsettings set org.cinnamon.theme name 'Mint-Y-Dark-NordzyGreen'
    gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark-NordzyGreen'
    gsettings set org.cinnamon.desktop.interface icon-theme 'Nordzy-green-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Mint-Y-Dark-NordzyGreen'
    gsettings set org.gnome.desktop.interface icon-theme 'Nordzy-green-dark'
    gsettings set org.cinnamon.desktop.background picture-uri "file://${HOME}/Pictures/wallpapers/ai/buddha_marble_nordic_dark.jpg"
    ;;
  *)
    echo "Unchanged for $XDG_SESSION_DESKTOP"
    ;;
  esac
else
  sed -i --follow-symlinks "s/frappe/latte/g" ~/.config/wezterm/sv_common.lua
  sed -i --follow-symlinks "s/frappe/latte/g" ~/.config/nvim/lua/plugins/colorscheme.lua
  sed -i --follow-symlinks "s/habamax/morning/g" ~/.config/nvim/light.nvim.lua
  sed -i --follow-symlinks "s/e5e9f0/000000/g" ~/.config/nvim/light.nvim.lua
  sed -i --follow-symlinks "s/2e3440/eff1f5/g" ~/.config/nvim/light.nvim.lua
  sed -i --follow-symlinks "s/frappe/latte/g" ~/.config/doom/config.el
  sed -i --follow-symlinks "s/frappe/latte/g" ~/.config/Code/User/settings.json
  sed -i --follow-symlinks "s/Frappé/Latte/g" ~/.config/Code/User/settings.json
  sed -i --follow-symlinks "s/Frappé/Latte/g" ~/.config/Antigravity/User/settings.json
  sed -i --follow-symlinks "s/frappe/latte/g" ~/.config/btop/btop.conf
  case "$XDG_SESSION_DESKTOP" in
  "KDE")
    lookandfeeltool -a org.kde.breeze.desktop
    ;;
  "cinnamon")
    gsettings set org.cinnamon.theme name 'Mint-Y-NordzyGreen'
    gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-NordzyGreen'
    gsettings set org.cinnamon.desktop.interface icon-theme 'Nordzy-green'
    gsettings set org.gnome.desktop.interface gtk-theme 'Mint-Y-NordzyGreen'
    gsettings set org.gnome.desktop.interface icon-theme 'Nordzy-green'
    gsettings set org.cinnamon.desktop.background picture-uri "file://${HOME}/Pictures/wallpapers/ai/buddha_marble_nordic.jpg"
    ;;
  *)
    echo "Unchanged for $XDG_SESSION_DESKTOP"
    ;;
  esac
fi
if $TO_MIXED; then
  case "$XDG_SESSION_DESKTOP" in
  "KDE")
    lookandfeeltool -a org.kde.breeze.desktop
    ;;
  "cinnamon")
    gsettings set org.cinnamon.theme name 'Mint-Y-Dark-NordzyGreen'
    gsettings set org.cinnamon.desktop.interface icon-theme 'Nordzy-green-dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Nordzy-green-dark'
    ;;
  *)
    echo "Unchanged for $XDG_SESSION_DESKTOP"
    ;;
  esac
fi
set +x
