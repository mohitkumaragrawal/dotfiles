#!/bin/bash

rm ~/.bashrc ~/.tmux.conf ~/.vimrc
ln -s $(pwd)/.bashrc ~/.bashrc
ln -s $(pwd)/.tmux.conf ~/.tmux.conf
ln -s $(pwd)/.vimrc ~/.vimrc

rm -rf ~/.config/awesome
ln -s $(pwd)/.config/awesome ~/.config/awesome

rm -rf ~/.config/htop
ln -s $(pwd)/.config/htop ~/.config/htop

rm -rf ~/.config/i3
ln -s $(pwd)/.config/i3 ~/.config/i3

rm -rf ~/.config/i3status
ln -s $(pwd)/.config/i3status ~/.config/i3status

rm -rf ~/.config/kitty
ln -s $(pwd)/.config/kitty ~/.config/kitty

rm -rf ~/.config/nvim
ln -s $(pwd)/.config/nvim ~/.config/nvim

rm -rf ~/.config/picom
ln -s $(pwd)/.config/picom ~/.config/picom

rm -rf ~/.config/rofi
ln -s $(pwd)/.config/rofi ~/.config/rofi

rm -rf ~/.config/yazi
ln -s $(pwd)/.config/yazi ~/.config/yazi
