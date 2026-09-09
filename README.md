# dotfiles

Shell, tmux and git configuration, managed with [GNU Stow](https://www.gnu.org/software/stow/)
and shared across macOS and Linux.

## Layout

Each top-level directory is a stow package whose internal structure mirrors
`$HOME`. `stow zsh` creates `~/.zshrc` as a symlink to `zsh/.zshrc`.

```
zsh/     .zshrc  .zprofile  .zshenv  .profile  .p10k.zsh
tmux/    .tmux.conf  .config/tmux-powerline/{config.sh,themes/,segments/}
git/     .gitconfig  .config/git/ignore
```

## Install on a new machine

```sh
git clone git@github.com:wyatthbc/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles
./install.sh
```

If `$HOME` already has real config files (a fresh oh-my-zsh install writes
`~/.zshrc`), `install.sh` stops and reports the conflict rather than linking
half of it. Then choose:

```sh
./install.sh --adopt    # keep what is live: move it into the repo, then link
                        # (review `git diff` before committing)
./install.sh --unstow   # remove the symlinks again
```

`install.sh` also sets `core.hooksPath=.githooks`, which is per-clone config
and therefore has to be set on every machine — running the installer is what
does that.

### Stow's target directory

Stow defaults its target to the *parent* of the stow directory. This repo lives
at `~/Projects/dotfiles`, so the default would be `~/Projects`, not `~`. Every
invocation needs `-t "$HOME"`; `install.sh` passes it for you. There is
deliberately no `.stowrc`, because `.stowrc` requires an absolute path and any
path hardcoded there would be wrong on the other platform.

## Prerequisites

Not managed here — install separately. Nothing below is fatal if missing; the
configs feature-detect and skip what is absent.

| | |
|---|---|
| shell framework | [oh-my-zsh](https://ohmyz.sh), [powerlevel10k](https://github.com/romkatv/powerlevel10k) theme |
| oh-my-zsh custom plugins | `zsh-autosuggestions`, `F-Sy-H`, `zsh-autocomplete`, `fzf-tab` |
| tmux | [tpm](https://github.com/tmux-plugins/tpm) at `~/.tmux/plugins/tpm`, then `prefix + I` |
| CLI tools | `nvim` `eza` `bat` `fd` `fzf` `zoxide` `yazi` `tlrc` `btop` `jq` |

`jq` is a hard requirement for the `claude_usage` powerline segment specifically.

## Cross-platform handling

Platform differences are handled by feature detection inside the tracked files,
not by per-OS forks, because there turned out to be very little divergence:

- **Homebrew** — `.zprofile` probes `/opt/homebrew`, `/usr/local`,
  `/home/linuxbrew/.linuxbrew` and `~/.linuxbrew` and uses the first that
  exists, covering Apple Silicon, Intel macOS and Linuxbrew.
- **`bat`** — Debian and Ubuntu ship it as `batcat` to avoid a name clash, so
  `.zshrc` aliases `cat` to whichever binary is present.
- **`eza`** — if absent, the `ls`/`ll`/`tree` aliases are not defined at all
  rather than pointing at a missing command.
- **Optional tools** — LM Studio and Antigravity are macOS-only here, so their
  `PATH` entries are guarded by a directory check and skipped elsewhere.
- **`.zshenv`** — every line is conditional. `.zshenv` runs for *every* zsh
  invocation including the non-interactive ones behind `ssh host cmd`, so an
  unguarded `source` of a missing file breaks remote commands rather than just
  printing a warning.
- **No absolute home paths.** Everything uses `$HOME`, so a Linux `/home/<user>`
  works unchanged.

### Machine-specific settings

Anything that should not be shared goes in `~/.zshrc.local`, which `.zshrc`
sources last if it exists. Create it directly in `$HOME` — it is deliberately
not a member of any stow package, so it never enters this repo at all. Use it
for work-only environment variables and one-off paths.

## What is deliberately not here

**This repository is public.** These are excluded, and `.gitignore` plus
`.githooks/pre-commit` exist to keep them out:

- `~/.claude/` — contains session transcripts, plans and memory files with
  internal hostnames and addresses. None of it is publishable as-is.
- `~/.ssh`, `~/.aws`, `~/.kube` — credentials.
- `~/.config/nvim` — not yet managed. Its `lazy-lock.json` pins plugin commits,
  and a single lock shared across machines running different Neovim versions is
  a known source of breakage, so it needs a per-machine answer first.

`.githooks/pre-commit` scans staged additions for AWS keys, GitHub and
Anthropic-style tokens, private key headers, assigned credentials and RFC1918
addresses. It is a backstop, not the primary control — the primary control is
that those directories are not members of any package. Deliberate bypass:
`git commit --no-verify`.

## Known rough edges

- **Linux is untested.** The configs are written for both platforms and syntax
  checked, but everything here has only been *run* on macOS.
- `install.sh` passes `--no-folding`, so directories under `~/.config` stay
  real directories with symlinked files inside, rather than becoming a single
  symlink into this repo. That is deliberate: a folded `~/.config/git` would
  mean anything a tool later writes there lands inside a *public* repo. The
  cost is that adding a new file to a package needs `./install.sh` re-run
  before it is linked into `$HOME`.
- `.tmux.conf` references `~/.claude/hooks/tmux-claude-flag.sh` for the
  per-window Claude status chip. That hook is not in this repo, and without it
  `@claude_state` is simply never set, so the status line falls back to the
  normal tmux-powerline window format.
