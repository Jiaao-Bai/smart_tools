#!/bin/bash
# Linux 配置安装脚本
# 仅链接 nvim 配置，并将 zsh aliases 追加到 ~/.bashrc
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 安全链接：目标已是软链则覆盖，是真实目录/文件则先备份再链接
link_safe() {
  local src="$1"
  local dst="$2"
  if [ -L "$dst" ]; then
    ln -sfn "$src" "$dst" && echo "linked $dst"
  elif [ -e "$dst" ]; then
    local bak="${dst}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dst" "$bak"
    echo "backed up $dst → $bak"
    ln -sfn "$src" "$dst" && echo "linked $dst"
  else
    ln -sfn "$src" "$dst" && echo "linked $dst"
  fi
}

mkdir -p ~/.config

# --- nvim 配置 ---
link_safe "$DOTFILES/.config/nvim" ~/.config/nvim

# --- tmux 配置 ---
link_safe "$DOTFILES/.config/tmux" ~/.config/tmux

# --- zsh aliases → ~/.bashrc ---
MARKER="# >>> smart_dotfiles aliases >>>"
ALIASES_FILE="$DOTFILES/.zsh_aliases"

if grep -qF "$MARKER" ~/.bashrc 2>/dev/null; then
    echo "aliases already in ~/.bashrc, skipping"
else
    {
        echo ""
        echo "$MARKER"
        cat "$ALIASES_FILE"
        echo "# <<< smart_dotfiles aliases <<<"
    } >> ~/.bashrc
    echo "appended aliases to ~/.bashrc"
fi

# --- .zsh_env 交互式生成 ---
ZSH_ENV="$HOME/.zsh_env"
rm -f "$ZSH_ENV"

echo
read -p "Proxy IP [127.0.0.1]: " proxy_ip
proxy_ip=${proxy_ip:-127.0.0.1}
read -p "Proxy port [7897]: " proxy_port
proxy_port=${proxy_port:-7897}
read -p "ANTHROPIC_AUTH_TOKEN: " auth_token

sed -e "s#{{PROXY_IP}}#$proxy_ip#g" \
    -e "s#{{PROXY_PORT}}#$proxy_port#g" \
    -e "s#{{AUTH_TOKEN}}#$auth_token#g" \
    "$DOTFILES/.zsh_env" > "$ZSH_ENV"
echo "generated ~/.zsh_env"

if ! grep -q "source ~/.zsh_env" ~/.bashrc 2>/dev/null; then
  echo "source ~/.zsh_env" >> ~/.bashrc
  echo "added 'source ~/.zsh_env' to ~/.bashrc"
fi

echo
echo "done. run 'exec bash' or open a new terminal."
