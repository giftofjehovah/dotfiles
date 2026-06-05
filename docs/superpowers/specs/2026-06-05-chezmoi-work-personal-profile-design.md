# Chezmoi work/personal profile — design

**Date:** 2026-06-05
**Status:** Draft, awaiting user review

## Goal

Let the same chezmoi source directory drive two different machine setups — **work** and **personal** — so a single `chezmoi apply` on each laptop installs the right packages and renders the right dotfile contents.

## Out of scope

- Asdf plugins, VSCode extensions, and macOS defaults stay shared across both profiles (per user decision).
- No secret management changes (existing config keeps `age`/`gpg`/`sops` unused as-is).
- No migration of dotfiles other than `~/.gitconfig` and `~/.zshrc`. Future per-profile diffs in other files can follow the same pattern.

## How a machine learns its profile

`.chezmoi.toml.tmpl` prompts once on `chezmoi init` and writes the answer into the rendered `~/.config/chezmoi/chezmoi.toml`. Every subsequent `chezmoi apply` reuses the stored value with no prompt.

```gotmpl
{{- $profile := promptChoiceOnce . "profile" "Which machine profile?" (list "work" "personal") -}}
mode = "symlink"

[data]
profile = {{ $profile | quote }}
```

**Operational notes:**
- Run `chezmoi init` once per machine before the first `apply`. It does not modify any dotfiles.
- To change a machine's profile later: edit `~/.config/chezmoi/chezmoi.toml`, or re-init with `chezmoi init --promptString profile=work`.
- `.profile` becomes available everywhere as `{{ .profile }}` in templates.

## Packages

### Structure of `.chezmoidata/packages.yml`

One file, three top-level sections under `packages`: `common`, `work`, `personal`. Each section may contain any of `taps`, `brews`, `casks`, `mas` (missing keys default to empty lists).

```yaml
packages:
  common:
    taps:
      - nikitabobko/tap            # aerospace WM
    brews:
      - yarn
      - htop
      - prettyping
      - tldr
      - git
      - mackup
      - zoxide
      - fontconfig
      - asdf
      - bat
      - gpg
      - starship
      - direnv
      - coreutils
      - jq
      - tree
      - wget
      - z
      - adr-tools
      - fzf
      - yq
      - uv
      - eza
      - chezmoi
      - git-delta
      - gh
    casks:
      - google-chrome
      - bartender
      - visual-studio-code
      - font-awesome-terminal-fonts
      - font-hack
      - font-fira-code-nerd-font
      - aerospace
    mas: []

  work:
    taps:
      - common-fate/granted
      - databricks/tap
    brews:
      - helm
      - postgresql
      - awscli
      - go-task
      - granted
      - kubectx
      - kubectl
      - sops
      - databricks
      - k9s
      - stern
    casks:
      - slack
      - docker
      - jetbrains-toolbox
      - superhuman
      - figma

  personal:
    brews:
      - mas
    casks:
      - arc
      - discord
      - zoom
      - notion
      - notion-calendar
      - capacities
      - beeper
      - cursor
      - raycast
      - warp
      - claude-code
      - claude
      - ngrok
    mas:
      - { name: '1password', id: 1333542190 }
      - { name: 'moomoo',    id: 1482713641 }
```

**Dropped from the existing file** (already commented out, no longer wanted):
- `koekeishiya/formulae` tap, `warrensbox/tap`
- `yabai`, `skhd`, `terraform`, `tfswitch`

### Install script template

`chezmoi/.chezmoiscripts/run_onchange_after_01-install-packages.sh.tmpl` is rewritten to merge `common` with the active profile's section before emitting the Brewfile body:

```gotmpl
{{ if eq .chezmoi.os "darwin" -}}
#!/bin/bash

{{- $p     := .packages.common -}}
{{- $extra := index .packages .profile -}}
{{- $taps  := concat (default (list) $p.taps)  (default (list) $extra.taps) -}}
{{- $brews := concat (default (list) $p.brews) (default (list) $extra.brews) -}}
{{- $casks := concat (default (list) $p.casks) (default (list) $extra.casks) -}}
{{- $mas   := concat (default (list) $p.mas)   (default (list) $extra.mas) -}}

brew bundle -f -v --file=/dev/stdin <<EOF
{{ range $taps  -}}tap {{ . | quote }}
{{ end -}}
{{ range $brews -}}brew {{ . | quote }}
{{ end -}}
{{ range $casks -}}cask {{ . | quote }}
{{ end -}}
{{ range $mas   -}}mas {{ .name | quote }}, id: {{ .id }}
{{ end -}}
EOF
{{ end -}}
```

Because the file is `run_onchange_*`, its hash changes when either `packages.yml` or `.profile` changes, so brew bundle re-runs only when the resolved package set actually differs.

## Dotfile templates

### `dot_gitconfig.tmpl` (new file)

Current `~/.gitconfig` is not tracked. Add a tracked template:

```gotmpl
[user]
{{- if eq .profile "work" }}
	email = jonathan@stashaway.com
	name = Jonathan
{{- else }}
	email = jonathan.pwh@gmail.com
	name = Jonathan
{{- end }}
```

### `dot_zshrc.tmpl` (rename `dot_zshrc`)

Wrap the work-only `HINDSIGHT_API_URL` export in a profile conditional. Everything else stays as it is today.

```gotmpl
# ... existing content unchanged ...
{{ if eq .profile "work" -}}
export HINDSIGHT_API_URL=http://localhost:8888
{{ end -}}
# ... existing content unchanged ...
```

Future per-profile additions go in the same template using the same conditional.

## Files changed

| Path | Change |
|---|---|
| `.chezmoi.toml.tmpl` | Add `promptChoiceOnce` for `profile`; expose under `[data]`. |
| `.chezmoidata/packages.yml` | Restructure into `common` / `work` / `personal`. |
| `chezmoi/.chezmoiscripts/run_onchange_after_01-install-packages.sh.tmpl` | Merge `common` + `.profile` section. |
| `dot_gitconfig.tmpl` | New file. |
| `dot_zshrc` → `dot_zshrc.tmpl` | Rename and wrap `HINDSIGHT_API_URL` in `{{ if eq .profile "work" }}`. |

## Verification

After implementation, on the work machine:

1. `chezmoi init` — prompted; choose `work`. Inspect `~/.config/chezmoi/chezmoi.toml` to confirm `profile = "work"`.
2. `chezmoi data | jq .profile` → `"work"`.
3. `chezmoi execute-template '{{ .profile }}'` → `work`.
4. `chezmoi diff` — confirm `~/.gitconfig` shows work email and `~/.zshrc` includes `HINDSIGHT_API_URL`.
5. `chezmoi apply -v` — observe `brew bundle` runs once with work + common packages and **without** Slack/Steam/etc. cross-contamination.

On the personal machine, same checks with `personal` chosen; confirm `mas` brew + 1password + moomoo install, work-only k8s/databricks/AWS tools do not.

## Risks and rollback

- **Wrong profile picked at init.** Mitigation: edit `~/.config/chezmoi/chezmoi.toml`, re-run `chezmoi apply`. Brew won't uninstall already-installed packages, but `chezmoi apply` will install the new profile's additions.
- **`dot_gitconfig.tmpl` overwrites a hand-tuned local `.gitconfig`.** Mitigation: `chezmoi diff` before first `apply`; copy any local-only sections (`[alias]`, `[core]`, etc.) into the template up front.
- **Existing `dot_zshrc` becoming `.tmpl` is a one-way rename.** Mitigation: the only template-time substitution added is the `{{ if }}` block; the file remains readable as plain zsh on either profile.

## Open questions

None at write time. Personal git identity defaulted to `jonathan.pwh@gmail.com` from the user's global config; correct in the template if a different identity is preferred.

## Runbook (post-implementation)

**New machine setup (either profile):**
1. `brew install chezmoi`
2. `chezmoi init https://github.com/<user>/dotfiles.git` — prompts for `profile` (work/personal).
3. `chezmoi apply -v` — installs brew bundle for that profile and renders templated dotfiles.

**Switching a machine's profile:**
1. `chezmoi init --promptChoice profile=<work|personal>` (or edit `~/.config/chezmoi/chezmoi.toml` and change the `profile` value under `[data]`).
2. `chezmoi apply -v`. Note that `brew bundle` does not uninstall packages no longer in the manifest — remove those manually with `brew uninstall <name>` if desired.

**Adding a new package:**
- Edit `.chezmoidata/packages.yml`, place under the right bucket (`common`/`work`/`personal`).
- `chezmoi apply` — the `run_onchange_*` script re-runs because its hash changes.

**Adding a new per-profile dotfile diff:**
- Rename the file to add a `.tmpl` suffix (use `git mv` so history is kept).
- Wrap diverging blocks in `{{ if eq .profile "work" }} ... {{ else }} ... {{ end }}`.
- `chezmoi diff <path>` then `chezmoi apply <path>` to verify.
