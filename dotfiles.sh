#!/bin/bash
#cp -r ~/.config/alacritty ~/dotfiles
#cp -r ~/.config/hypr ~/dotfiles
#cp -r ~/.config/i3 ~/dotfiles
cp -r ~/.config/nvim ~/dotfiles
#cp -r ~/.config/polybar ~/dotfiles
#cp -r ~/.config/tofi ~/dotfiles
#cp -r ~/.config/waybar ~/dotfiles
#cp -r ~/.config/dunst ~/dotfiles
cp -r ~/.zshrc ~/dotfiles
#cp -r ~/.config/compfy ~/dotfiles
cp -r ~/.config/rofi ~/dotfiles
cp -r ~/.tmux.conf ~/dotfiles

cd ~/dotfiles
git add --all
git commit
git push
