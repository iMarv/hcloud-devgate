#!/bin/sh

# Install CLI tools
mkdir ~/tmp

## exa
wget -O ~/tmp/exa.zip 'https://github.com/ogham/exa/releases/download/v0.9.0/exa-linux-x86_64-0.9.0.zip'
unzip -d ~/tmp ~/tmp/exa.zip
sudo mv ~/tmp/exa-linux-x86_64 /usr/local/bin/exa

## bat
wget -O ~/tmp/bat.deb 'https://github.com/sharkdp/bat/releases/download/v0.12.1/bat_0.12.1_amd64.deb'
sudo dpkg -i ~/tmp/bat.deb

## Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc

rm -rf ~/tmp

# Configure workspace
git config --global core.editor "${git_editor}"
git config --global user.name "${git_user}"
git config --global user.email "${git_mail}"

# Symlink to volume
ln -s /mnt/HC_Volume_${volume_id}/ ~/projects
