#!/bin/bash

# Configurações do GitHub
GITHUB_EMAIL=""
GITHUB_NAME=""

# Verificar se as variáveis estão definidas
if [ -z "$GITHUB_EMAIL" ] || [ -z "$GITHUB_NAME" ]; then
    echo "Erro: GITHUB_EMAIL e GITHUB_NAME devem ser definidos no início do script"
    exit 1
fi

echo "Iniciando configuração do ambiente de desenvolvimento..."

# Configurar SSH KEY and Github
echo "Configurando SSH key para GitHub..."
ssh-keygen -t rsa -b 4096 -C "$GITHUB_EMAIL" -f ~/.ssh/id_rsa -N ""
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
echo "Chave SSH gerada. Copie a chave pública abaixo e cole no GitHub:"
cat ~/.ssh/id_rsa.pub
echo ""
read -p "Pressione Enter após adicionar a chave no GitHub..."

git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_NAME"

# Instalar o ZSH
echo "Instalando ZSH..."
sudo apt update
sudo apt install -y zsh

# Instalar o Oh My Zsh
echo "Instalando Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Instalar o Zsh Syntax Highlighting
echo "Instalando Zsh Syntax Highlighting..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Instalar o Zsh Autosuggestions
echo "Instalando Zsh Autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Adicionar plugins no .zshrc
echo "Configurando plugins no .zshrc..."
sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc

# Instalar o Zsh Autocomplete e o Powerlevel10k
echo "Instalando Zsh Autocomplete..."
git clone https://github.com/zsh-users/zsh-autocomplete ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete

echo "Instalando Powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Adicionar o tema powerlevel10k no .zshrc
echo "Configurando tema Powerlevel10k..."
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# Instalar o Go
echo "Instalando Go..."
wget https://dl.google.com/go/go1.24.5.linux-amd64.tar.gz
sudo tar -xvf go1.24.5.linux-amd64.tar.gz   
sudo mv go /usr/local
rm go1.24.5.linux-amd64.tar.gz

# Adicionar Go ao PATH
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc

# Add ASDF to zsh configuration
echo "Configurando ASDF..."
echo 'export ASDF_DATA_DIR=$HOME/.asdf' >> ~/.zshrc
echo 'export PATH="$ASDF_DATA_DIR/shims:$PATH"' >> ~/.zshrc

# Install ASDF
echo "Instalando ASDF..."
export PATH=$PATH:/usr/local/go/bin
go install github.com/asdf-vm/asdf/cmd/asdf@v0.18.0

# Adicionar ASDF ao PATH para a sessão atual
export ASDF_DATA_DIR=$HOME/.asdf
export PATH="$ASDF_DATA_DIR/shims:$PATH"

# Install Node.js via ASDF
echo "Instalando Node.js via ASDF..."
asdf plugin add nodejs
asdf install nodejs 22.11.0
asdf global nodejs 22.11.0

# Install Yarn
echo "Instalando Yarn..."
npm install -g yarn

# Install GCP (Google Cloud SDK)
echo "Instalando Google Cloud SDK..."
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get update && sudo apt-get install -y google-cloud-cli

echo "Configuração concluída!"
echo "Para aplicar as mudanças, execute: source ~/.zshrc"
echo "Ou reinicie o terminal."