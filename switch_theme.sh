#!/bin/bash

# Quick script to switch between dark and light themese for editors I use
# on LinuxMint.
TO_DARK=false
if [ $# -ge 1 ]; then
  shopt -s nocasematch
  if [ "$1" != "light" ]; then
    TO_DARK=true
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
if $TO_DARK; then
  sed -i --follow-symlinks "s/latte/frappe/g" ~/.config/wezterm/sv_common.lua
  sed -i --follow-symlinks "s/latte/frappe/g" ~/.config/nvim/lua/plugins/colorscheme.lua
  sed -i --follow-symlinks "s/morning/habamax/g" ~/.config/nvim/light.nvim.lua
  sed -i --follow-symlinks "s/000000/e5e9f0/g" ~/.config/nvim/light.nvim.lua
  sed -i --follow-symlinks "s/eff1f5/2e3440/g" ~/.config/nvim/light.nvim.lua
  sed -i --follow-symlinks "s/latte/frappe/g" ~/.config/doom/config.el
  sed -i --follow-symlinks "s/latte/frappe/g" ~/.config/Code/User/settings.json
  sed -i --follow-symlinks "s/Latte/Frappé/g" ~/.config/Code/User/settings.json
  sed -i --follow-symlinks "s/latte/frappe/g" ~/.config/btop/btop.conf
  if [[ "$XDG_SESSION_DESKTOP" == "KDE" ]]; then
    lookandfeeltool -a org.kde.breezedark.desktop
  else
    #TODO: fix with elif for cinnamon
    gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark-Aqua'
  fi
else
  sed -i --follow-symlinks "s/frappe/latte/g" ~/.config/wezterm/sv_common.lua
  sed -i --follow-symlinks "s/frappe/latte/g" ~/.config/nvim/lua/plugins/colorscheme.lua
  sed -i --follow-symlinks "s/habamax/morning/g" ~/.config/nvim/light.nvim.lua
  sed -i --follow-symlinks "s/e5e9f0/000000/g" ~/.config/nvim/light.nvim.lua
  sed -i --follow-symlinks "s/2e3440/eff1f5/g" ~/.config/nvim/light.nvim.lua
  sed -i --follow-symlinks "s/frappe/latte/g" ~/.config/doom/config.el
  sed -i --follow-symlinks "s/frappe/latte/g" ~/.config/Code/User/settings.json
  sed -i --follow-symlinks "s/Frappé/Latte/g" ~/.config/Code/User/settings.json
  sed -i --follow-symlinks "s/frappe/latte/g" ~/.config/btop/btop.conf
  if [[ "$XDG_SESSION_DESKTOP" == "KDE" ]]; then
    lookandfeeltool -a org.kde.breeze.desktop
  else
    #TODO: fix with elif for cinnamon
    gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Aqua'
  fi
fi
