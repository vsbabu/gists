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
  sed -i --follow-symlinks "s/delek/habamax/g" ~/.config/nvim/light.nvim.lua
  sed -i --follow-symlinks "s/latte/frappe/g" ~/.config/doom/config.el
  sed -i --follow-symlinks "s/latte/frappe/g" ~/.config/Code/User/settings.json
  sed -i --follow-symlinks "s/Latte/Frappé/g" ~/.config/Code/User/settings.json
  sed -i --follow-symlinks "s/latte/frappe/g" ~/.config/btop/btop.conf
  gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark-Aqua'
else
  sed -i --follow-symlinks "s/frappe/latte/g" ~/.config/wezterm/sv_common.lua
  sed -i --follow-symlinks "s/frappe/latte/g" ~/.config/nvim/lua/plugins/colorscheme.lua
  sed -i --follow-symlinks "s/habamax/habamax/g" ~/.config/nvim/light.nvim.lua
  sed -i --follow-symlinks "s/frappe/latte/g" ~/.config/doom/config.el
  sed -i --follow-symlinks "s/frappe/latte/g" ~/.config/Code/User/settings.json
  sed -i --follow-symlinks "s/Frappé/Latte/g" ~/.config/Code/User/settings.json
  sed -i --follow-symlinks "s/frappe/latte/g" ~/.config/btop/btop.conf
  gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Aqua'
fi
