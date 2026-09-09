# POSIX-shell login profile. Kept in sync with .zprofile/.zshrc for the
# sh/bash case; every path is guarded so missing tools are simply skipped.

[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# LM Studio CLI (lms) -- macOS only in practice
[ -d "$HOME/.lmstudio/bin" ] && export PATH="$PATH:$HOME/.lmstudio/bin"

# Added by Antigravity CLI installer
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
