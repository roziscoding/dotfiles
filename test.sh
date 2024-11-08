#!/bin/sh

# Brewfile hash: 75d8dd219573c7bdbb9e98d98d6d08a6b22ba2344f07675ea6369dd2939329a9


  pacman -Sy --needed git base-devel && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si
  
    yay -Sy --noconfirm --needed kitty zsh curl vim
    curl -sS https://starship.rs/install.sh | sh
  
git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf" --branch v0.14.1
  . "$HOME/.asdf/asdf.sh"
  asdf plugin add ni https://github.com/CanRau/asdf-ni.git
  for plugin in $(cat /home/roziscoding/.tool-versions | sed s/' .*$'//); do
    asdf plugin-list | grep $plugin > /dev/null 2>&1
    if [ $? -ne 0 ]; then
     asdf plugin-add $plugin
    fi
  done
  asdf install
git clone https://github.com/alker0/chezmoi.vim ~/.vim/pack/plugins/opt/chezmoi.vim

