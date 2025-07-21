#!/data/data/com.termux/files/usr/bin/bash

echo "[*] Checking for stuck apt processes..."
APT_PID=$(lsof /data/data/com.termux/files/usr/var/lib/dpkg/lock-frontend 2>/dev/null | awk 'NR==2 {print $2}')

if [ -n "$APT_PID" ]; then
    echo "[!] Killing stuck apt process (PID: $APT_PID)..."
    kill -9 "$APT_PID" && sleep 1
fi

echo "[*] Removing lock files..."
rm -rf /data/data/com.termux/files/usr/var/lib/dpkg/lock-frontend
rm -rf /data/data/com.termux/files/usr/var/lib/dpkg/lock

echo "[*] Fixing dpkg (if needed)..."
dpkg --configure -a

echo "[*] Updating Termux..."
pkg update -y && pkg upgrade -y

echo "[*] Installing required packages..."
pkg install -y zsh git fastfetch curl
pkg install ncurses-utils
pkg install iproute2
pkg install ruby
gem install lolcat

echo "[*] Cloning zsh plugins..."
mkdir -p ~/.zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting

echo "[*] Creating .zshrc..."
cat > ~/.zshrc << 'EOF'
#Show system info
echo
fastfetch
echo
setopt autocd
# Load zsh plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Enable up/down arrow key history navigation
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# Clean and simple prompt with custom name
PROMPT=$'%F{green}→R.K.M%f:%F{blue}%~%f$ '

# Aliases
alias update="pkg update && pkg upgrade"
alias cls="clear"

EOF

echo "[*] Disabling Termux default message..."
touch ~/.hushlogin   # <--- This line was added here

echo "[*] Setting zsh as the default shell..."
if ! grep -q "zsh" ~/.bashrc; then
    echo 'exec zsh -l' >> ~/.bashrc
    echo 'PS1="→\[\e[32m\]R.K.M\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ " ' >> ~/.bashrc
fi

echo "[✔] Installation complete! Restart Termux or run 'zsh' to use your new custom shell."