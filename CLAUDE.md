# CLAUDE.md

AI 助手工作指南。

## 仓库结构

```
├── .config/nvim/
│   ├── init.lua                    # 入口，require 各模块
│   ├── lazy-lock.json              # 插件版本锁文件
│   ├── lua/config/
│   │   ├── options.lua             # vim 选项
│   │   ├── keymaps.lua             # 所有快捷键（唯一定义处）
│   │   └── lazy.lua                # 插件声明 + 内联配置
│   ├── lua/plugin_config/          # 各插件独立配置文件
│   └── lua/lsp_client_config/      # LSP server 配置
├── .config/ghostty/
│   └── config                      # Ghostty 终端配置
├── .zsh_aliases                    # shell 别名
├── .zsh_env                        # 环境变量模板（proxy、Claude/DeepSeek 配置）
├── .ctags.d/cuda.ctags             # universal-ctags CUDA 语言映射
├── install.sh                      # macOS 安装脚本（symlink + 交互式 .zsh_env 生成）
├── install_linux.sh                # Linux 安装脚本
├── dockerfile/
│   └── Dockerfile_pytorch_nvim_claude  # NVIDIA PyTorch + nvim + Claude Code
└── README.md
```

## Neovim 配置

### 插件管理

使用 lazy.nvim。插件声明在 `lua/config/lazy.lua`，部分插件的简单配置直接内联在声明里（如 blink.cmp），复杂配置单独放在 `lua/plugin_config/`。

### 主要插件

- **UI**: vscode.nvim（配色）、nvim-tree（文件树）、bufferline（标签栏）、lualine（状态栏）
- **导航**: telescope.nvim（模糊搜索，底层用 ripgrep）
- **编辑**: Comment.nvim、nvim-treesitter（高亮/缩进/折叠）
- **补全**: blink.cmp（来源：LSP + 路径 + buffer）
- **LSP**: mason.nvim（工具安装器）、nvim-lspconfig

### LSP 配置

使用 Neovim 0.11+ 原生 API（`vim.lsp.config()` + `vim.lsp.enable()`）。

当前配置的 LSP server：
- `lua/lsp_client_config/luals.lua` — lua-language-server，仅用于 `.lua` 文件

C++/CUDA 项目不使用 LSP，改用 ctags + telescope 方案（见下）。

### C++/CUDA 项目导航

使用 universal-ctags + telescope 替代 clangd：
- `<C-]>` — telescope tags，跳转到光标下符号的定义（ctags 索引）
- `<leader>*` — telescope grep_string，全文搜索光标下单词（ripgrep）

使用前需在项目根目录执行 `ctags -R .` 生成索引文件。

### 快捷键规则

**所有快捷键必须定义在 `lua/config/keymaps.lua`**，plugin config 文件不得自行定义快捷键。

Neovim 0.11+ 在 `LspAttach` 时自动设置 buffer-local LSP 快捷键（`gd`、`grr` 等），优先级高于 keymaps.lua 中的全局映射。C++/CUDA 文件无 LSP 附加，走全局映射（ctags/rg）。

### VS Code 支持

检测 `vim.g.vscode` 后加载 `lua/config/keymaps_vscode.lua`，仅启用最小化快捷键。

## shell 配置

### .zsh_aliases

别名定义在 `.zsh_aliases`（由 `.zshrc` source）：
- Git: `gs` `ga` `gc` `gp` `gpl` `gd` `gl` `gb` `gco` `gr`
- Docker: `dps` `dex` `drm` `dimg`
- ls: `ll` `la` `l`
- Editor: `v`（nvim）
- macOS 专属: `icloud`（仅 Darwin 生效）
- Linux 专属: Ghostty TERM 修正（`xterm-ghostty` → `xterm-256color`）

### .zsh_env

环境变量模板，包含 proxy 设置和 Claude/DeepSeek 配置。文件中使用 `{{PROXY_IP}}`、`{{PROXY_PORT}}`、`{{AUTH_TOKEN}}` 占位符。

`install.sh` / `install_linux.sh` 在安装时交互式询问这三个值，通过 `sed` 替换占位符后生成 `~/.zsh_env`（非 symlink，重新 install 会重建）。`~/.zshrc` / `~/.bashrc` 中追加 `source ~/.zsh_env`。

静态配置（如 `ANTHROPIC_MODEL`、`CLAUDE_CODE_EFFORT_LEVEL` 等）直接编辑 repo 中的 `.zsh_env`，`git pull` 后重新 `./install.sh` 即可生效。

## Docker 镜像

Dockerfile 构建：
- 构建时 `git clone` smart_dotfiles（公开仓库）到 `/root/smart_dotfiles`，不依赖物理机本地文件
- 配置以**软链**方式生效（`~/.config/nvim` 等指向 clone 出来的 repo）
- 插件在构建时通过 `nvim --headless "+Lazy! install/restore"` 安装，版本由 `lazy-lock.json` 锁定
- 可选 `--build-arg DOTFILES_REPO=... DOTFILES_REF=<分支/tag>` 覆盖来源
- 可选代理支持：`--build-arg PROXY_IP=baijiaao-mac-mini.local --build-arg PROXY_PORT=7897`

### 容器内更新 dotfiles（无需重新构建镜像）

dotfiles 改动后，进容器执行：

```
cd ~/smart_dotfiles && git pull
```

纯配置/快捷键改动因软链即时生效。若 `lazy-lock.json` 有变（增删插件/改版本）：

```
nvim --headless "+Lazy! restore" +qa
```

`.zsh_env` 是构建时注入 token/proxy 的真实文件（非软链），如需更新可 `git pull` 后重跑
Dockerfile 中的 `sed` 替换逻辑。

## 注意事项

- 配置文件中有中文注释，保持现有风格
- 更新插件需修改 `lazy-lock.json`
- `.zsh_env` 中的 openclaw 路径使用 `$HOME` 变量，不同机器通用
