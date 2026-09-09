# .zshenv runs for EVERY zsh invocation, including non-interactive ones used by
# scp/rsync/ssh command execution. An unguarded source of a missing file breaks
# those on any machine without rust, so keep every line here conditional.
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
