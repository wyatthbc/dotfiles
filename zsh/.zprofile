# Homebrew. Probe the known prefixes rather than hardcoding one, so this file
# works on Apple Silicon, Intel macOS, and Linuxbrew without editing.
for _brew in /opt/homebrew/bin/brew \
             /usr/local/bin/brew \
             /home/linuxbrew/.linuxbrew/bin/brew \
             "$HOME/.linuxbrew/bin/brew"; do
  if [ -x "$_brew" ]; then
    eval "$("$_brew" shellenv)"
    break
  fi
done
unset _brew

# Added by Antigravity CLI installer
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
