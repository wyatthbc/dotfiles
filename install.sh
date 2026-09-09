#!/usr/bin/env bash
# Symlink this repo's stow packages into $HOME.
#
#   ./install.sh              link packages (fails loudly on conflicts)
#   ./install.sh --adopt      pull existing $HOME files INTO the repo, then link
#   ./install.sh --unstow     remove the symlinks, leaving files in the repo
#
# --adopt overwrites the repo's copy with whatever is live in $HOME. Always
# review `git diff` afterwards before committing.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh tmux git)

if ! command -v stow >/dev/null 2>&1; then
  cat >&2 <<'MSG'
error: GNU Stow is not installed.
  macOS:          brew install stow
  Debian/Ubuntu:  sudo apt install stow
  Fedora/RHEL:    sudo dnf install stow
  Arch:           sudo pacman -S stow
MSG
  exit 1
fi

# Two flags that always apply:
#   -t "$HOME"     stow defaults its target to the PARENT of the stow
#                  directory, which is wrong here (this repo lives under
#                  ~/Projects), so the target is always explicit.
#   --no-folding   without it, stow may replace a whole directory such as
#                  ~/.config/git with a single symlink into this repo. Anything
#                  a tool later writes there would then land inside a public
#                  repo instead of in $HOME. Real directories with symlinked
#                  files inside avoid that. Cost: adding a new file to a
#                  package needs ./install.sh re-run to link it.
stow_cmd() { stow -d "$REPO" -t "$HOME" --no-folding "$@"; }

case "${1:-}" in
  --unstow)
    stow_cmd -D "${PACKAGES[@]}"
    echo "unstowed: \$HOME no longer links to this repo"
    exit 0
    ;;
  --adopt)
    echo "adopting live \$HOME files into the repo..."
    stow_cmd --adopt "${PACKAGES[@]}"
    echo
    echo "NOTE: the repo now holds whatever was live in \$HOME."
    echo "      Review before committing:  git -C \"$REPO\" diff"
    ;;
  '')
    # Dry run first so a conflict produces advice instead of a half-linked home.
    if ! stow_cmd -n "${PACKAGES[@]}" 2>/tmp/dotfiles-stow-conflict; then
      echo "error: stow found conflicts -- \$HOME already has real files here:" >&2
      sed 's/^/  /' /tmp/dotfiles-stow-conflict >&2
      cat >&2 <<'MSG'

Two ways forward:
  1. Keep the versions currently in $HOME:   ./install.sh --adopt
     (moves them into the repo; review `git diff` before committing)
  2. Keep the versions in this repo:         move the $HOME files aside, re-run
MSG
      exit 1
    fi
    stow_cmd "${PACKAGES[@]}"
    ;;
  *)
    echo "usage: $0 [--adopt|--unstow]" >&2
    exit 2
    ;;
esac

# Versioned hooks travel with the repo; core.hooksPath is per-clone config.
git -C "$REPO" config core.hooksPath .githooks
echo "linked: ${PACKAGES[*]}"
echo "pre-commit secret guard enabled (core.hooksPath=.githooks)"
echo
echo "Next: exec zsh   # or open a new shell"
