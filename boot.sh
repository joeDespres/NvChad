# bin/bash

# install nvim 
curl -LO https://github.com/neovim/neovim/releases/download/v0.9.5/nvim.appimage
chmod u+x nvim.appimage
sudo mv nvim.appimage /usr/local/bin/nvim

# lua styling
curl -LO https://github.com/JohnnyMorganz/StyLua/releases/download/v0.20.0/stylua-linux.zip
unzip stylua-linux.zip
chmod +x stylua
sudo mv stylua /usr/local/bin/

# bottom 
curl -LO https://github.com/ClementTsang/bottom/releases/download/0.9.4/bottom_0.9.4_amd64.deb
sudo dpkg -i bottom_0.9.4_amd64.deb

# ripgrep
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
sudo dpkg -i ripgrep_13.0.0_amd64.deb

sudo apt-get install fuse -y
sudo apt install clang -y
sudo apt install python3.8-venv -y
sudo apt install nodejs -y
apt-get install -y npm

git clone git@github.com:joeDespres/NvChad.git ~/.config/nvim --depth 100
# cleanup
rm stylua-linux.zip ripgrep_13.0.0_amd64.deb bottom_0.9.4_amd64.deb
