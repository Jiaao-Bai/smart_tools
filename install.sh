#!/bin/bash
# macOS 配置安装脚本
# 用 symlink 链接配置文件，git pull 即可同步更新
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

# ~/.config/* — 每个子目录单独 symlink，不整体替换 ~/.config
for dir in "$DOTFILES"/.config/*/; do
  name=$(basename "$dir")
  link_safe "$dir" ~/.config/"$name"
done

# ctags 语言映射
link_safe "$DOTFILES/.ctags.d" ~/.ctags.d

# zsh aliases
link_safe "$DOTFILES/.zsh_aliases" ~/.zsh_aliases
if ! grep -q "source ~/.zsh_aliases" ~/.zshrc 2>/dev/null; then
  echo "source ~/.zsh_aliases" >> ~/.zshrc
  echo "added 'source ~/.zsh_aliases' to ~/.zshrc"
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

if ! grep -q "source ~/.zsh_env" ~/.zshrc 2>/dev/null; then
  echo "source ~/.zsh_env" >> ~/.zshrc
  echo "added 'source ~/.zsh_env' to ~/.zshrc"
fi

echo
echo "done. restart your shell to apply zsh changes."
