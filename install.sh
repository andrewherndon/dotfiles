#!/usr/bin/env bash
# dotfiles installer — andrew herndon
# Usage: curl -fsSL andrew.by/setup | bash -s -- [-y|--yes]

set -euo pipefail

# ── colors ────────────────────────────────────────────────────────────────────
GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; CYAN=$'\033[0;36m'
BOLD=$'\033[1m'; DIM=$'\033[2m'; RESET=$'\033[0m'; RED=$'\033[0;31m'

# ── args ──────────────────────────────────────────────────────────────────────
YES_ALL=false
for arg in "$@"; do
  case "$arg" in -y|--yes) YES_ALL=true ;; esac
done

# ── platform ──────────────────────────────────────────────────────────────────
OS="$(uname -s)"
PLATFORM="unknown"

detect_platform() {
  case "$OS" in
    Darwin) PLATFORM="macos" ;;
    Linux)
      if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        case "${ID:-}" in
          amzn)          PLATFORM="amazon-linux" ;;
          ubuntu|debian) PLATFORM="debian" ;;
          *)             PLATFORM="linux" ;;
        esac
      else
        PLATFORM="linux"
      fi
      ;;
    *) printf "${RED}✗ Unsupported OS: %s${RESET}\n" "$OS" >&2; exit 1 ;;
  esac
}

# ── ui helpers ────────────────────────────────────────────────────────────────
step()    { printf "\n  ${BOLD}${CYAN}◆${RESET} ${BOLD}%s${RESET}\n" "$1"; }
info()    { printf "    ${DIM}→${RESET} %s\n" "$1"; }
ok()      { printf "    ${GREEN}✓${RESET} %s\n" "$1"; }
skipped() { printf "    ${DIM}○ %s — already present${RESET}\n" "$1"; }
warn()    { printf "    ${YELLOW}▲${RESET} %s\n" "$1"; }

ask() {
  # Returns 0 (yes) or 1 (no). $1=label, $2=default y|n
  $YES_ALL && return 0
  local default="${2:-y}"
  local hint
  [[ $default == y ]] \
    && hint="${BOLD}Y${RESET}${DIM}/n${RESET}" \
    || hint="${DIM}y/${RESET}${BOLD}N${RESET}"
  printf "  ${CYAN}?${RESET}  %-42s %b  ${DIM}›${RESET} " "$1" "$hint"
  local ans
  read -r ans </dev/tty 2>/dev/null || ans=""
  case "$ans" in
    y|Y|yes|YES|Yes) return 0 ;;
    n|N|no|NO|No)    return 1 ;;
    "")              [[ $default == y ]] && return 0 || return 1 ;;
    *)               [[ $default == y ]] && return 0 || return 1 ;;
  esac
}

brew_eval() {
  if   [[ -f /opt/homebrew/bin/brew ]];              then eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]];                 then eval "$(/usr/local/bin/brew shellenv)"
  elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
}

# ── header ────────────────────────────────────────────────────────────────────
detect_platform

printf "\n"
printf "  ${BOLD}◆ dotfiles${RESET}  ${DIM}andrew herndon${RESET}  ${DIM}[%s]${RESET}\n" "$PLATFORM"
printf "  ${DIM}────────────────────────────────────────────────${RESET}\n\n"

if ! $YES_ALL; then
  printf "  ${DIM}Select components to install. Enter accepts default [Y].${RESET}\n\n"
fi

# ── component selection ───────────────────────────────────────────────────────
do_brew=false;        ask "Homebrew         package manager"          y && do_brew=true        || true
do_nvim=false;        ask "Neovim           terminal editor"          y && do_nvim=true        || true
do_lazyvim=false;     ask "LazyVim          neovim config framework"  y && do_lazyvim=true     || true
do_nvim_config=false; ask "Neovim config    keymaps & plugins"        y && do_nvim_config=true || true
do_omz=false;         ask "Oh My Zsh        zsh framework"            y && do_omz=true         || true
do_zsh=false;         ask "Zsh config       .zshrc"                   y && do_zsh=true         || true

# ── clone dotfiles repo ───────────────────────────────────────────────────────
DOTFILES="$HOME/.dotfiles"
DOTFILES_REPO="https://github.com/andrewherndon/dotfiles"

# ── prerequisites (git + curl required before anything else) ──────────────────
if [[ "$PLATFORM" != "macos" ]]; then
  if ! command -v git &>/dev/null || ! command -v curl &>/dev/null; then
    step "Prerequisites"
    info "Installing git and curl…"
    if   command -v dnf     &>/dev/null; then sudo dnf install -y git curl
    elif command -v yum     &>/dev/null; then sudo yum install -y git curl
    elif command -v apt-get &>/dev/null; then sudo apt-get update -qq && sudo apt-get install -y git curl
    fi
    ok "git and curl ready"
  fi
fi

step "Dotfiles"
if [[ -d "$DOTFILES/.git" ]]; then
  info "Pulling latest → $DOTFILES"
  git -C "$DOTFILES" pull --ff-only 2>/dev/null || true
  ok "up to date"
else
  info "Cloning → $DOTFILES"
  git clone --depth 1 "$DOTFILES_REPO" "$DOTFILES"
  ok "cloned"
fi

# ── homebrew ──────────────────────────────────────────────────────────────────
if $do_brew; then
  step "Homebrew"
  brew_eval
  if command -v brew &>/dev/null; then
    skipped "brew $(brew --version | head -1)"
  else
    case "$PLATFORM" in
      amazon-linux|linux|debian)
        info "Installing build dependencies…"
        if command -v dnf &>/dev/null; then
          sudo dnf groupinstall -y "Development Tools" 2>/dev/null || true
          sudo dnf install -y curl file git procps-ng 2>/dev/null || true
        elif command -v yum &>/dev/null; then
          sudo yum groupinstall -y "Development Tools" 2>/dev/null || true
          sudo yum install -y curl file git 2>/dev/null || true
        elif command -v apt-get &>/dev/null; then
          sudo apt-get update -qq
          sudo apt-get install -y build-essential curl file git
        fi
        ;;
    esac
    info "Installing Homebrew…"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew_eval
    ok "brew installed"
  fi
fi

# ── neovim ────────────────────────────────────────────────────────────────────
if $do_nvim; then
  step "Neovim"
  brew_eval
  if command -v nvim &>/dev/null; then
    skipped "nvim $(nvim --version | head -1)"
  else
    if command -v brew &>/dev/null; then
      info "brew install neovim…"
      brew install neovim
    else
      # fallback: prebuilt binary from GitHub releases
      info "Homebrew not available — downloading neovim binary…"
      NVIM_VER="v0.10.4"
      case "$OS" in
        Darwin) NVIM_ASSET="nvim-macos-$(uname -m).tar.gz" ;;
        Linux)  NVIM_ASSET="nvim-linux-x86_64.tar.gz" ;;
      esac
      curl -fsSL "https://github.com/neovim/neovim/releases/download/${NVIM_VER}/${NVIM_ASSET}" -o /tmp/nvim.tar.gz
      sudo tar -C /usr/local -xzf /tmp/nvim.tar.gz --strip-components=1
      rm /tmp/nvim.tar.gz
    fi
    ok "neovim installed"
  fi
fi

# ── lazyvim ───────────────────────────────────────────────────────────────────
if $do_lazyvim; then
  step "LazyVim"
  NVIM_CFG="$HOME/.config/nvim"
  if [[ -d "$NVIM_CFG" ]]; then
    skipped "$NVIM_CFG"
  else
    brew_eval
    # LazyVim recommends ripgrep + fd
    if command -v brew &>/dev/null; then
      brew list ripgrep &>/dev/null || brew install ripgrep
      brew list fd      &>/dev/null || brew install fd
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y ripgrep fd-find 2>/dev/null || true
    elif command -v yum &>/dev/null; then
      sudo yum install -y ripgrep 2>/dev/null || true
    fi
    info "Cloning LazyVim starter → $NVIM_CFG"
    git clone https://github.com/LazyVim/starter "$NVIM_CFG"
    rm -rf "$NVIM_CFG/.git"
    ok "LazyVim installed"
  fi
fi

# ── custom nvim config (keymaps + plugins) ────────────────────────────────────
if $do_nvim_config; then
  step "Neovim config"
  NVIM_CFG="$HOME/.config/nvim"
  SRC="$DOTFILES/nvim"
  if [[ ! -d "$NVIM_CFG" ]]; then
    warn "~/.config/nvim not found — install LazyVim first"
  else
    # Copy the entire nvim/ tree from dotfiles on top of the LazyVim clone
    cp -r "$SRC/." "$NVIM_CFG/"
    ok "keymaps + plugins copied → ~/.config/nvim"
  fi
fi

# ── oh my zsh ─────────────────────────────────────────────────────────────────
if $do_omz; then
  step "Oh My Zsh"
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    skipped "~/.oh-my-zsh"
  else
    if ! command -v zsh &>/dev/null; then
      info "zsh not found — installing…"
      if   command -v brew    &>/dev/null; then brew install zsh
      elif command -v dnf     &>/dev/null; then sudo dnf install -y zsh
      elif command -v yum     &>/dev/null; then sudo yum install -y zsh
      elif command -v apt-get &>/dev/null; then sudo apt-get install -y zsh
      else warn "Cannot auto-install zsh — install manually then re-run"
      fi
    fi
    info "Installing Oh My Zsh…"
    RUNZSH=no CHSH=no sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
      "" --unattended
    ok "Oh My Zsh installed"
  fi
fi

# ── zsh config ────────────────────────────────────────────────────────────────
if $do_zsh; then
  step "Zsh config"
  SRC="$DOTFILES/.zshrc"
  DST="$HOME/.zshrc"

  if [[ -L "$DST" && "$(readlink "$DST")" == "$SRC" ]]; then
    skipped "~/.zshrc already symlinked to dotfiles"
  else
    if [[ -f "$DST" && ! -L "$DST" ]]; then
      info "Backing up existing ~/.zshrc → ~/.zshrc.bak"
      mv "$DST" "$DST.bak"
    fi
    ln -sf "$SRC" "$DST"
    ok "~/.zshrc → $SRC"
  fi
fi

# ── done ──────────────────────────────────────────────────────────────────────
printf "\n  ${DIM}────────────────────────────────────────────────${RESET}\n"
printf "  ${GREEN}${BOLD}◆ done!${RESET}  restart your shell to apply changes.\n\n"
