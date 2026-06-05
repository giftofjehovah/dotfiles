# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/). One source repo drives two machine profiles: **work** and **personal**. The profile is picked once on `chezmoi init` and stored locally; everything else is automatic.

## First-time setup on a new machine

```bash
# 1. Install chezmoi
brew install chezmoi

# 2. Init and choose the profile
chezmoi init git@github.com:giftofjehovah/dotfiles.git
# → prompt: "Which machine profile?"  →  type "work" or "personal"

# 3. Apply — installs brew bundle and renders dotfiles
chezmoi apply -v
```

That's it. The profile answer is saved in `~/.config/chezmoi/chezmoi.toml`; every subsequent `chezmoi apply` uses it silently.

### Non-interactive install (skip the prompt)

Useful for scripts or restoring from backup:

```bash
chezmoi init --promptChoice profile=work     git@github.com:giftofjehovah/dotfiles.git
chezmoi init --promptChoice profile=personal git@github.com:giftofjehovah/dotfiles.git
chezmoi apply -v
```

## What differs between profiles

| Thing | work | personal |
|---|---|---|
| Brew bundle | common + k8s/AWS/Databricks/Slack/Docker/Figma/Superhuman/JetBrains | common + Discord/Notion/Cursor/Warp/Raycast/Claude/Beeper/Arc/Zoom/Capacities/ngrok/Mac App Store apps (1password, moomoo) |
| `~/.gitconfig` | `email = jonathan@stashaway.com` | `email = jonathan.pwh@gmail.com` |
| `~/.zshrc` | includes `export HINDSIGHT_API_URL=...` | omits it |

Everything else (zsh plugins, aerospace, fonts, aliases, functions, asdf plugins, VSCode extensions, macOS defaults) is identical on both.

## Day-to-day

```bash
chezmoi data | jq .profile      # which profile is this machine on?
chezmoi diff                    # what would `apply` change?
chezmoi apply -v                # render templates + run install scripts
chezmoi update                  # git pull + apply, in one command
chezmoi cd                      # cd into the source repo
```

### Adding a package

Edit `.chezmoidata/packages.yml`, place under the right bucket:

```yaml
packages:
  common:  { brews: [...new shared brew...] }
  work:    { casks: [...new work-only cask...] }
  personal:{ casks: [...new personal-only cask...] }
```

Then `chezmoi apply` — the `run_onchange_*` install script re-runs because its content hash changes.

### Adding a per-profile dotfile diff

1. If the file is currently a static dotfile, rename it with `.tmpl`:
   ```bash
   chezmoi cd
   git mv dot_somefile dot_somefile.tmpl
   ```
2. Wrap the diverging block:
   ```gotmpl
   {{ if eq .profile "work" }}
   # work-only content
   {{ end }}
   ```
3. `chezmoi diff <target-path>` then `chezmoi apply <target-path>` to verify.

### Switching a machine's profile

```bash
chezmoi init --promptChoice profile=personal    # or "work"
chezmoi apply -v
```

`brew bundle` does **not** uninstall packages no longer in the new profile's manifest — `brew uninstall <name>` manually if you want a clean state.

## Repo layout

```
.chezmoi.toml.tmpl                                          ← profile prompt
.chezmoidata/packages.yml                                   ← common / work / personal package buckets
.chezmoiignore                                              ← paths not to deploy
chezmoi/.chezmoiscripts/                                    ← run-on-apply scripts
  ├─ run_once_after_00-install-brew-macos.sh                  Homebrew bootstrap
  ├─ run_onchange_after_01-install-packages.sh.tmpl           brew bundle (profile-aware)
  ├─ run_once_after_05-install-asdf-plugins-macos.sh.tmpl     asdf plugins
  ├─ run_once_after_50-install-vscode-plugins-macos.sh.tmpl   VSCode extensions
  └─ run_once_after_98-macos-settings.sh                      macOS defaults
dot_gitconfig.tmpl                                          ← per-profile git identity
dot_zshrc.tmpl                                              ← per-profile shell
dot_aliases.sh, dot_functions.sh, dot_aerospace.toml, ...   ← shared dotfiles
docs/superpowers/specs/2026-06-05-…design.md                ← design rationale
docs/superpowers/plans/2026-06-05-…profile.md               ← implementation plan
```

## Troubleshooting

**`chezmoi diff` shows a warning about the config file template:** run `chezmoi init --promptChoice profile=<your-profile>` to regenerate `~/.config/chezmoi/chezmoi.toml`. Harmless, just noise.

**Brew bundle wants to install a personal app on the work machine:** confirm `chezmoi data | jq .profile` returns `"work"`. If it shows `"personal"`, re-init with the right profile.

**`~/.gitconfig` shows the wrong email after `apply`:** same as above — check the profile.

**Rendered template output looks wrong:** preview without applying:
```bash
chezmoi execute-template < dot_gitconfig.tmpl
```
To preview the *other* profile without changing this machine:
```bash
TMP=$(mktemp -d)/chezmoi.toml
sed 's/profile = "work"/profile = "personal"/' ~/.config/chezmoi/chezmoi.toml > "$TMP"
chezmoi execute-template --config "$TMP" < dot_gitconfig.tmpl
```
