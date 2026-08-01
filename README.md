# smart_dotfiles

Neovim / zsh / Ghostty 个人配置，面向 macOS 日常开发与 CUDA 容器环境。

> **核心收录准则：** 只收录能够帮助在 Linux 服务器或 macOS 主机上快速回放开发环境的配置、脚本与清单；不收录运行时状态、缓存、日志、会话历史或任何凭证。

## 内容

| 路径 | 用途 |
|---|---|
| `.config/nvim/` | Neovim 配置 |
| `.config/ghostty/` | Ghostty 终端配置 |
| `.zsh_aliases` | shell 别名 |
| `.zsh_env` | 环境变量模板（proxy、Claude/DeepSeek 配置） |
| `.ctags.d/` | universal-ctags 全局配置（CUDA 语言映射） |
| `install.sh` | macOS 安装脚本 |
| `install_linux.sh` | Linux 安装脚本 |
| `dockerfile/` | Linux 开发容器镜像 |

---

## macOS 新机器

**前置**：手动安装 [Ghostty](https://ghostty.org)、[Neovim](https://github.com/neovim/neovim/releases)、[universal-ctags](https://formulae.brew.sh/formula/universal-ctags)。

```bash
git clone https://github.com/Jiaao-Bai/smart_dotfiles.git
cd smart_dotfiles
./install.sh
```

`install.sh` 会：
- symlink 链接 `nvim` / `ctags` / `zsh_aliases` 到 `~/.config` 和 `~` 下
- 交互式生成 `~/.zsh_env`（输入 proxy IP/端口 和 ANTHROPIC_AUTH_TOKEN）
- 幂等追加 `source` 行到 `~/.zshrc`，不覆盖现有内容
- 已有目录/文件先备份再链接，不会丢失数据

重新执行 `./install.sh` 会删除旧的 `~/.zsh_env` 并重新交互生成，其他链接不受影响。

打开 nvim，执行：

```
:Lazy sync
```

---

## Linux 新机器

```bash
git clone https://github.com/Jiaao-Bai/smart_dotfiles.git
cd smart_dotfiles
./install_linux.sh
```

仅链接 nvim 配置，将 zsh aliases 追加到 `~/.bashrc`，并交互式生成 `~/.zsh_env`。

---

## Docker 镜像（Linux 开发环境）

完全自包含构建，不依赖宿主机 nvim 状态。

```bash
# 不带代理
docker build --platform=linux/amd64 --network host \
  -f dockerfile/Dockerfile_pytorch_nvim_claude .

# 带代理
docker build --platform=linux/amd64 --network host \
  --build-arg PROXY_IP=baijiaao-mac-mini.local \
  --build-arg PROXY_PORT=7897 \
  -f dockerfile/Dockerfile_pytorch_nvim_claude .
```

局域网内的 Linux 主机通过 Mac mini 的 mDNS 名称访问代理，避免把 DHCP 地址写死进构建命令。

插件在镜像构建时通过 `nvim --headless "+Lazy! sync"` 安装，版本由 `lazy-lock.json` 锁定。

### GPU 服务器 Ollama

Mac mini 是配置事实源；启动脚本通过 SSH stdin 执行，不要求 GPU 服务器安装 Docker Compose，也不修改其 dotfiles 工作副本：

```bash
ssh gpu 'bash -s' < dockerfile/run_ollama_gpu.sh
```

脚本默认使用 `baijiaao-mac-mini.local:7897`，模型持久化在 `/mnt/storage01/ollama`，容器删除不会删除模型。

---

## ctags 索引（C++/CUDA 项目）

在每个 C++/CUDA 项目根目录执行一次：

```bash
ctags -R .
echo "tags" >> .gitignore
```

之后用 `<C-]>` 跳转定义，`<leader>*` 全文搜索引用。符号变化后重新执行即可。
