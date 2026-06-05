# Chezmoi work/personal profile — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `chezmoi apply` install a different set of brew/cask/mas packages and render different `~/.gitconfig` / `~/.zshrc` content depending on whether the machine is the user's **work** or **personal** laptop.

**Architecture:** A single `profile` variable, captured once via `promptChoiceOnce` in `.chezmoi.toml.tmpl` and stored in `~/.config/chezmoi/chezmoi.toml`, drives everything. `.chezmoidata/packages.yml` is restructured into `common` / `work` / `personal` sections; the install template merges `common` with the active profile. `dot_gitconfig.tmpl` (new) and `dot_zshrc.tmpl` (renamed from `dot_zshrc`) gate their diverging blocks on `{{ if eq .profile "work" }}`.

**Tech Stack:** chezmoi 2.70 templates (Go templates + sprig), Homebrew `brew bundle`, zsh.

**Spec:** `docs/superpowers/specs/2026-06-05-chezmoi-work-personal-profile-design.md`

---

## File Structure

| Path | Status | Responsibility |
|---|---|---|
| `.chezmoi.toml.tmpl` | Modify | Prompt for profile on init; expose as `.profile`. |
| `.chezmoidata/packages.yml` | Modify | Define `common`, `work`, `personal` package sets. |
| `chezmoi/.chezmoiscripts/run_onchange_after_01-install-packages.sh.tmpl` | Modify | Merge `common` + `.profile` section; pass to `brew bundle`. |
| `dot_gitconfig.tmpl` | Create | Per-profile git identity. |
| `dot_zshrc.tmpl` | Rename + modify (from `dot_zshrc`) | Wrap `HINDSIGHT_API_URL` in profile conditional. |

No new tests are added — chezmoi configurations are verified by running `chezmoi execute-template`, `chezmoi diff`, and `chezmoi apply --dry-run` against representative profile values. Each task ends with one of those verification commands instead of a unit test.

---

## Task 1: Add the `profile` prompt to `.chezmoi.toml.tmpl`

**Files:**
- Modify: `.chezmoi.toml.tmpl` (currently a single line: `mode = "symlink"`)

- [ ] **Step 1: Snapshot the existing rendered config**

Run:
```bash
cp ~/.config/chezmoi/chezmoi.toml ~/.config/chezmoi/chezmoi.toml.bak
```
Reason: we want to be able to restore the current rendered config if anything goes wrong before we commit to a profile.

- [ ] **Step 2: Replace `.chezmoi.toml.tmpl` with the prompt version**

Overwrite `.chezmoi.toml.tmpl` with:

```gotmpl
{{- $profile := promptChoiceOnce . "profile" "Which machine profile?" (list "work" "personal") -}}
mode = "symlink"

[data]
profile = {{ $profile | quote }}
```

- [ ] **Step 3: Verify the template renders against a chosen value**

Run:
```bash
cd ~/.local/share/chezmoi
chezmoi execute-template --init --promptString profile=work < .chezmoi.toml.tmpl
```
Expected output:
```
mode = "symlink"

[data]
profile = "work"
```

Then:
```bash
chezmoi execute-template --init --promptString profile=personal < .chezmoi.toml.tmpl
```
Expected: same but with `profile = "personal"`.

- [ ] **Step 4: Re-init this machine and confirm `.profile` is now in `chezmoi data`**

This machine currently has work email in `~/.gitconfig`, so choose `work`:
```bash
chezmoi init --promptString profile=work
chezmoi data | jq '.profile'
```
Expected: `"work"`.

Then confirm the rendered config file looks right:
```bash
cat ~/.config/chezmoi/chezmoi.toml
```
Expected: contains `profile = "work"` under `[data]`.

- [ ] **Step 5: Commit**

```bash
cd ~/.local/share/chezmoi
git add .chezmoi.toml.tmpl
git commit -m "feat(chezmoi): prompt for machine profile on init"
```

---

## Task 2: Restructure `.chezmoidata/packages.yml` into common/work/personal

**Files:**
- Modify: `.chezmoidata/packages.yml`

- [ ] **Step 1: Replace file contents**

Overwrite `.chezmoidata/packages.yml` with:

```yaml
packages:
  common:
    taps:
      - nikitabobko/tap
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

- [ ] **Step 2: Verify chezmoi parses the new structure**

Run:
```bash
chezmoi data | jq '.packages | keys'
```
Expected:
```json
["common", "personal", "work"]
```

Then spot-check each bucket size:
```bash
chezmoi data | jq '{common: (.packages.common.brews|length), work: (.packages.work.brews|length), personal: (.packages.personal.casks|length)}'
```
Expected: numbers > 0 for each (common.brews ≈ 26, work.brews ≈ 11, personal.casks ≈ 13).

- [ ] **Step 3: Commit**

```bash
git add .chezmoidata/packages.yml
git commit -m "refactor(packages): split into common/work/personal sections"
```

---

## Task 3: Update install template to merge `common` with the active profile

**Files:**
- Modify: `chezmoi/.chezmoiscripts/run_onchange_after_01-install-packages.sh.tmpl`

- [ ] **Step 1: Overwrite the install template**

Replace the file's entire contents with:

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
{{ range $taps -}}
tap {{ . | quote }}
{{ end -}}
{{ range $brews -}}
brew {{ . | quote }}
{{ end -}}
{{ range $casks -}}
cask {{ . | quote }}
{{ end -}}
{{ range $mas -}}
mas {{ .name | quote }}, id: {{ .id }}
{{ end -}}
EOF
{{ end -}}
```

- [ ] **Step 2: Render the template against the current (work) profile and inspect**

Run:
```bash
chezmoi execute-template < chezmoi/.chezmoiscripts/run_onchange_after_01-install-packages.sh.tmpl
```
Expected: a Brewfile heredoc that contains:
- `tap "nikitabobko/tap"`, `tap "common-fate/granted"`, `tap "databricks/tap"`
- `brew "git"` (from common), `brew "kubectl"` (from work)
- `cask "google-chrome"` (common), `cask "slack"` (work)
- **No** `brew "mas"`, **no** `cask "arc"`, **no** `mas "1password"...` lines
- **No** empty `mas` lines

- [ ] **Step 3: Render against personal profile and inspect**

Run:
```bash
chezmoi execute-template --init --promptString profile=personal < chezmoi/.chezmoiscripts/run_onchange_after_01-install-packages.sh.tmpl
```
Expected: heredoc contains `cask "arc"`, `cask "claude"`, `brew "mas"`, `mas "1password", id: 1333542190`, `mas "moomoo", id: 1482713641`. **No** `cask "slack"`, **no** `brew "kubectl"`.

- [ ] **Step 4: Sanity-check that `chezmoi apply --dry-run` doesn't blow up**

Run:
```bash
chezmoi apply --dry-run -v 2>&1 | head -40
```
Expected: no template-parsing errors; the script appears in the dry-run output.

- [ ] **Step 5: Commit**

```bash
git add chezmoi/.chezmoiscripts/run_onchange_after_01-install-packages.sh.tmpl
git commit -m "feat(install): merge common and profile-specific package sets"
```

---

## Task 4: Create `dot_gitconfig.tmpl`

**Files:**
- Create: `dot_gitconfig.tmpl`

- [ ] **Step 1: Inspect the current ~/.gitconfig and capture any keys we don't want to lose**

Run:
```bash
cat ~/.gitconfig
```
The current contents are only:
```
[user]
	email = jonathan@stashaway.com
```
i.e. no extra sections (`[core]`, `[alias]`, etc.) to preserve. If, on running this task, additional sections exist, copy them verbatim into the template **outside** the `{{ if eq .profile "work" }}` block before continuing.

- [ ] **Step 2: Create the template file**

Create `dot_gitconfig.tmpl` with these exact contents (tab indent inside `[user]`, matching git's own style):

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

- [ ] **Step 3: Render against both profiles**

Run:
```bash
chezmoi execute-template --init --promptString profile=work < dot_gitconfig.tmpl
```
Expected:
```
[user]
	email = jonathan@stashaway.com
	name = Jonathan
```

Run:
```bash
chezmoi execute-template --init --promptString profile=personal < dot_gitconfig.tmpl
```
Expected: same but with `jonathan.pwh@gmail.com`.

- [ ] **Step 4: Diff against the live config**

Run:
```bash
chezmoi diff ~/.gitconfig
```
Expected: shows chezmoi taking ownership of `~/.gitconfig` (current file → templated file). On the work profile the user/email lines should match what's already there, plus a new `name = Jonathan` line.

- [ ] **Step 5: Apply just this file and confirm**

Run:
```bash
chezmoi apply ~/.gitconfig
cat ~/.gitconfig
```
Expected: file now contains both `email` and `name`. Verify git still works:
```bash
git -C ~/.local/share/chezmoi config user.email
```
Expected: `jonathan@stashaway.com` (since this machine is on the work profile).

- [ ] **Step 6: Commit**

```bash
cd ~/.local/share/chezmoi
git add dot_gitconfig.tmpl
git commit -m "feat(git): template gitconfig with per-profile identity"
```

---

## Task 5: Rename `dot_zshrc` → `dot_zshrc.tmpl` and gate `HINDSIGHT_API_URL`

**Files:**
- Rename + modify: `dot_zshrc` → `dot_zshrc.tmpl`

- [ ] **Step 1: Rename via git so history is preserved**

Run:
```bash
cd ~/.local/share/chezmoi
git mv dot_zshrc dot_zshrc.tmpl
```

- [ ] **Step 2: Wrap the `HINDSIGHT_API_URL` export in a profile conditional**

The current file contains this exact line:
```
export HINDSIGHT_API_URL=http://localhost:8888
```

Replace that single line with the following three-line block:
```gotmpl
{{- if eq .profile "work" }}
export HINDSIGHT_API_URL=http://localhost:8888
{{- end }}
```

Leave every other line in the file untouched.

- [ ] **Step 3: Render against both profiles**

Run:
```bash
chezmoi execute-template --init --promptString profile=work < dot_zshrc.tmpl | grep -n HINDSIGHT
```
Expected: one line, `export HINDSIGHT_API_URL=http://localhost:8888`.

Run:
```bash
chezmoi execute-template --init --promptString profile=personal < dot_zshrc.tmpl | grep -n HINDSIGHT
```
Expected: no output (empty).

- [ ] **Step 4: Diff and apply**

Run:
```bash
chezmoi diff ~/.zshrc
```
Expected: on the work profile, no diff at all (the rendered output equals the current `~/.zshrc`).

Run:
```bash
chezmoi apply ~/.zshrc
```
Expected: no change announced (file already matches).

- [ ] **Step 5: Commit**

```bash
git add dot_zshrc.tmpl
git commit -m "feat(zsh): gate work-only HINDSIGHT_API_URL behind profile"
```

---

## Task 6: End-to-end verification on the work profile

**Files:** none modified.

- [ ] **Step 1: Confirm chezmoi state is clean**

Run:
```bash
chezmoi diff
```
Expected: empty (no pending changes; everything we templated already matches reality).

- [ ] **Step 2: Render the install script and confirm it would invoke brew with the right set**

Run:
```bash
chezmoi execute-template < chezmoi/.chezmoiscripts/run_onchange_after_01-install-packages.sh.tmpl | grep -E '^(brew|cask|mas|tap) ' | sort > /tmp/brewfile-work.txt
wc -l /tmp/brewfile-work.txt
head -20 /tmp/brewfile-work.txt
```
Expected: line count ≈ 60–65 entries; the file contains work-specific entries (`brew "kubectl"`, `cask "slack"`) and **none** of the personal-only ones (`cask "arc"`, `brew "mas"`, `mas "1password"...`).

- [ ] **Step 3: Run the install script for real**

Run:
```bash
chezmoi apply -v
```
Expected: `run_onchange_after_01-install-packages.sh` executes (its hash changed). `brew bundle` runs and reports already-installed packages without errors. If unexpected uninstalls happen, abort and inspect `/tmp/brewfile-work.txt`.

- [ ] **Step 4: Spot-check the dotfiles**

Run:
```bash
grep -c HINDSIGHT_API_URL ~/.zshrc
cat ~/.gitconfig
```
Expected: `1` for the grep; gitconfig shows work email + name.

---

## Task 7: Document a one-paragraph runbook in the spec

**Files:**
- Modify: `docs/superpowers/specs/2026-06-05-chezmoi-work-personal-profile-design.md`

- [ ] **Step 1: Append a "Runbook" section to the bottom of the spec**

Append:

```markdown
## Runbook (post-implementation)

**New machine setup (either profile):**
1. `brew install chezmoi`
2. `chezmoi init https://github.com/<user>/dotfiles.git` — prompts for `profile` (work/personal).
3. `chezmoi apply -v` — installs brew bundle for that profile and renders templated dotfiles.

**Switching a machine's profile:**
1. Edit `~/.config/chezmoi/chezmoi.toml`, change the `profile` value under `[data]`.
2. `chezmoi apply -v`. Note that `brew bundle` does not uninstall packages no longer in the manifest — remove those manually with `brew uninstall <name>` if desired.

**Adding a new package:**
- Edit `.chezmoidata/packages.yml`, place under the right bucket (`common`/`work`/`personal`).
- `chezmoi apply` — the `run_onchange_*` script re-runs because its hash changes.

**Adding a new per-profile dotfile diff:**
- Rename the file to add a `.tmpl` suffix (use `git mv` so history is kept).
- Wrap diverging blocks in `{{ if eq .profile "work" }} ... {{ else }} ... {{ end }}`.
- `chezmoi diff <path>` then `chezmoi apply <path>` to verify.
```

- [ ] **Step 2: Commit**

```bash
git add docs/superpowers/specs/2026-06-05-chezmoi-work-personal-profile-design.md
git commit -m "docs(chezmoi): add post-implementation runbook"
```

---

## Self-review notes

- **Spec coverage:** prompt (Task 1), packages.yml restructure (Task 2), install template (Task 3), gitconfig template (Task 4), zshrc template (Task 5), verification (Task 6), runbook (Task 7) — every spec section maps to a task.
- **No placeholders:** every code block contains real, copy-pasteable content. The one spot that depends on local state (Task 4 Step 1: "if extra sections exist, preserve them") gives an explicit instruction, not a TODO.
- **Type consistency:** `.profile` (lowercase) is used everywhere. Sub-keys in `.chezmoidata/packages.yml` (`taps`, `brews`, `casks`, `mas`) are spelled the same in the YAML, in the install template, and in the verification jq queries.
- **Rollback path:** Task 1 Step 1 backs up `~/.config/chezmoi/chezmoi.toml`. The rename in Task 5 uses `git mv` so reverting is one `git revert` away. `~/.gitconfig` is small and was effectively rewritten in Task 4 Step 5 — easy to restore from `git -C ~/.local/share/chezmoi log` if needed.
