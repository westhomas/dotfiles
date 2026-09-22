#!/usr/bin/env bash
# Personal environment setup inside a Docker Sandbox (sbx).
#
# Called by the Texoma repo's scripts/sbx/sbx-bootstrap.sh when SBX_PERSONAL_DIR points at this
# dotfiles repo:
#
#   SBX_PERSONAL_DIR=$HOME/code/dotfiles make sbx-up
#
# The repo bootstrap handles everything Texoma needs (supabase CLI, git, Claude config). This file
# is purely "make the sandbox feel like my machine": chezmoi, mise toolchain, zsh + prompt.
# It runs INSIDE the sandbox, with this repo mounted read-only at its host path.
#
# Failures here are warnings on the repo side — a broken personal setup never costs a working
# sandbox. Idempotent: re-run any time.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIER="${SBX_TIER:-minimal}"

# The 13 tools worth having immediately. `full` installs everything in the mise config, minus two
# that mise cannot install in this image: npm:git-split-diffs (mise's npm backend aborts asking for
# input) and azure-cli (pipx/uv build failure; the host `az` covers it).
MINIMAL_TOOLS=(ripgrep fd fzf bat lsd zoxide starship github-cli node jj lazygit uv chezmoi)
FULL_EXCLUDE=("npm:git-split-diffs" "azure-cli")

# Installed with plain `npm -g` below instead. Only mise's npm BACKEND is broken here; npm itself
# installs these fine, and without git-split-diffs the gitconfig pager falls back to `cat`, so
# `git vlog` / `git show` lose side-by-side diffs in every sandbox.
NPM_GLOBAL_TOOLS=(git-split-diffs diff-so-fancy)

log()  { printf '\033[1;35m[personal]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[personal warn]\033[0m %s\n' "$*"; }

export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
# python@3.10.11 has no GitHub artifact attestations for linux/arm64, and mise's npm backend
# prompts for confirmation it can never receive under `sbx exec`.
export MISE_YES=1
export MISE_PYTHON_GITHUB_ATTESTATIONS=false

# ---------------------------------------------------------------- mise
if ! command -v mise >/dev/null 2>&1; then
  log "installing mise"
  curl -fsSL https://mise.run | sh >/tmp/sbx-mise-install.log 2>&1 \
    || { warn "mise install failed (see /tmp/sbx-mise-install.log)"; exit 1; }
fi

# ---------------------------------------------------------------- chezmoi
# This repo is mounted READ-ONLY, and chezmoi wants to write in its source dir: `chezmoi init` runs
# git there and dies with "/Users/<you>/code/dotfiles/.git: Permission denied". The old code only
# noticed if init had never succeeded, so a sandbox would sit on a config generated from an OLD
# .chezmoi.toml.tmpl, print "config file template has changed, run chezmoi init" on every call, and
# silently apply NOTHING -- `chezmoi diff ~/.zshrc` reported "not managed". Dotfiles edits then
# never reached a sandbox at all, which is a lie that costs an afternoon to spot.
#
# So: mirror the mount into a writable copy and point chezmoi at that. .git is excluded, both
# because the history is not wanted and because without it chezmoi makes no git calls in the source
# at all. --delete so a file removed upstream disappears here too.
SRC_RW="$HOME/.local/share/chezmoi-source"
# Bail out if the mount is missing. The directory still EXISTS when unmounted (the sandbox creates
# the path), so a -d test passes on an empty dir -- and `rsync --delete` from an empty source then
# wipes a previously good mirror down to the excluded .git, after which chezmoi manages nothing and
# silently keeps whatever ~/.gitconfig the first bootstrap wrote. Forever.
if [ -z "$(ls -A "$DOTFILES_DIR" 2>/dev/null | grep -v '^\.git$' || true)" ]; then
  warn "$DOTFILES_DIR is empty — dotfiles not mounted into this sandbox."
  warn "keeping the existing chezmoi mirror; recreate the sandbox with that mount to get updates."
  SKIP_MIRROR=1
fi
if [ "${SKIP_MIRROR:-0}" = 1 ]; then
  SRC_RW="$SRC_RW"
elif mkdir -p "$SRC_RW" && rsync -a --delete --exclude '.git' "$DOTFILES_DIR"/ "$SRC_RW"/; then
  log "dotfiles source mirrored to $SRC_RW (the mount is read-only)"
else
  warn "could not mirror $DOTFILES_DIR — falling back to the read-only mount; chezmoi init may fail"
  SRC_RW="$DOTFILES_DIR"
fi

# Run init EVERY time, not just once. It regenerates the config from .chezmoi.toml.tmpl, so it is
# the only thing that picks up a changed template -- and it is cheap and idempotent. `remote` is
# decided at INIT time from the environment and baked into the generated config, so container=docker
# has to be set for THIS call; exporting it later does nothing. The sandbox has no /.dockerenv and
# no CODESPACES/SSH_CONNECTION, so without it chezmoi applies the Mac variant.
log "chezmoi init (container=docker -> remote=true)"
container=docker mise exec chezmoi -- chezmoi init --source "$SRC_RW" \
  || warn "chezmoi init failed — apply below may use a stale config"

# --exclude scripts: run_onchange_after_install_packages.sh runs a whole-config `mise install`,
#   which fails in-container and would abort the apply. Tool installs are handled below instead.
# --force: chezmoi manages .gitconfig, which the repo bootstrap edits (SSH->HTTPS rewrite). Without
#   --force a re-run stops to ask about the change and there is no TTY under `sbx exec`.
log "chezmoi apply"
mise exec chezmoi -- chezmoi apply --force --exclude scripts --source "$SRC_RW" \
  || warn "chezmoi apply failed — the shell config in here may be stale"

# Loud, because a silent no-op apply is exactly the failure this block exists to prevent.
if ! mise exec chezmoi -- chezmoi managed --source "$SRC_RW" 2>/dev/null | grep -q '^\.zshrc$'; then
  warn "chezmoi still does not manage ~/.zshrc — dotfiles changes are NOT reaching this sandbox"
fi

# ---------------------------------------------------------------- toolchain
mise trust "$HOME/.config/mise/config.toml" >/dev/null 2>&1 || true
if [ "$TIER" = "full" ]; then
  log "installing full tier (minus: ${FULL_EXCLUDE[*]})"
  mapfile -t ALL < <(mise ls --json 2>/dev/null | python3 -c 'import json,sys
for name in json.load(sys.stdin): print(name)' 2>/dev/null || true)
  WANTED=()
  for t in "${ALL[@]}"; do
    skip=0
    for x in "${FULL_EXCLUDE[@]}"; do [ "$t" = "$x" ] && skip=1; done
    [ "$skip" = 0 ] && WANTED+=("$t")
  done
  [ "${#WANTED[@]}" -gt 0 ] && { mise install "${WANTED[@]}" || warn "some tools failed"; }
else
  log "installing minimal tier (${#MINIMAL_TOOLS[@]} tools)"
  mise install "${MINIMAL_TOOLS[@]}" || warn "some tools failed"
fi
mise reshim >/dev/null 2>&1 || true

# The diff helpers the gitconfig pager wants. diff-so-fancy comes from the Brewfile on the host,
# which does not apply in a Linux sandbox, so npm is the only route for both.
if command -v npm >/dev/null 2>&1; then
  MISSING_NPM=()
  for t in "${NPM_GLOBAL_TOOLS[@]}"; do
    command -v "$t" >/dev/null 2>&1 || MISSING_NPM+=("$t")
  done
  if [ "${#MISSING_NPM[@]}" -gt 0 ]; then
    log "npm -g: ${MISSING_NPM[*]}"
    npm i -g "${MISSING_NPM[@]}" >/tmp/sbx-npm-global.log 2>&1 \
      || warn "npm global install failed (see /tmp/sbx-npm-global.log); diffs fall back to plain"
  fi
else
  warn "no npm — git-split-diffs unavailable, diffs fall back to plain output"
fi

# ---------------------------------------------------------------- shell
# The base image is bash-only and mise has no zsh, but .zshrc/.p10k.zsh assume zsh + oh-my-zsh +
# powerlevel10k. KEEP_ZSHRC=yes is essential: the installer would otherwise replace chezmoi's .zshrc.
if ! command -v zsh >/dev/null 2>&1; then
  log "installing zsh"
  sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq  >/tmp/sbx-apt.log 2>&1 \
    && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq zsh >>/tmp/sbx-apt.log 2>&1 \
    || warn "zsh install failed (see /tmp/sbx-apt.log)"
fi
if command -v zsh >/dev/null 2>&1; then
  [ "$(getent passwd "$(id -u)" | cut -d: -f7)" = "$(command -v zsh)" ] \
    || sudo chsh -s "$(command -v zsh)" "$(id -un)" >/dev/null 2>&1 || warn "chsh failed"

  if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    log "installing oh-my-zsh"
    KEEP_ZSHRC=yes RUNZSH=no CHSH=no sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
      >/tmp/sbx-omz.log 2>&1 || warn "oh-my-zsh install failed (see /tmp/sbx-omz.log)"
  fi
  P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  [ -d "$HOME/.oh-my-zsh" ] && [ ! -d "$P10K_DIR" ] && {
    log "cloning powerlevel10k"
    git clone --depth 1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR" >/dev/null 2>&1 \
      || warn "powerlevel10k clone failed"
  }
  for repo in zsh-autosuggestions zsh-syntax-highlighting; do
    [ -d "$HOME/.zsh/$repo" ] && continue
    mkdir -p "$HOME/.zsh"
    git clone --depth 1 "https://github.com/zsh-users/$repo.git" "$HOME/.zsh/$repo" >/dev/null 2>&1 \
      || warn "clone of $repo failed"
  done
fi

# .zshrc only activates mise for interactive shells, so non-interactive shells (agent tool calls,
# `zsh -c`, hooks) would have the aliases without the tools. dot_zshenv / dot_bash_profile put the
# shims on PATH unconditionally — verify chezmoi actually placed them.
for f in .zshenv .bash_profile; do
  grep -q 'mise/shims' "$HOME/$f" 2>/dev/null \
    || warn "$f is missing the mise shims PATH line — non-interactive shells will lack the toolchain"
done

log "done — $(mise ls --installed 2>/dev/null | wc -l | tr -d ' ') tools, shell $(getent passwd "$(id -u)" | cut -d: -f7)"
