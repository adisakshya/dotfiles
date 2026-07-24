Adisakshya's dotfiles!
## Dependencies
- [Git](https://git-scm.com/downloads)
- [Make](https://en.wikipedia.org/wiki/Make_(software))
    - For Windows - [Using winget](https://winget.run/pkg/GnuWin32/Make)
    - For Linux - ```$ apt-get install build-essential```

## Prerequisites

### Windows

- **Git for Windows** (includes Git Bash) — required to run the install scripts. Download from <https://git-scm.com/downloads>.
- **GNU Make** — install via `winget install GnuWin32.Make`.
- **Developer Mode enabled *or* an elevated (Administrator) shell** *(required for `make windows` only)* — required for symlink creation. Enable Developer Mode under *Settings → Privacy & security → For developers*, or open a terminal as Administrator. Without one of these, Dotbot will fail to create symlinks mid-install. If you cannot meet this requirement, use `make windows-copy` instead (see [Managed / work machines](#managed--work-machines----make-windows-copy-copy-based-no-admin-required) below).
- **PowerShell execution policy** — local scripts must be allowed to run:
  ```powershell
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
  ```

**Windows Terminal settings** — installing this dotfile symlinks `settings.json` directly into Windows Terminal's `LocalState` directory, **replacing your existing settings file**. Back up your current settings before running `make windows`:

```
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

(For Windows Terminal Preview, substitute `Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe`.) The installer will create a timestamped backup automatically (see [Existing files and dry runs](#existing-files-and-dry-runs)), but you may also want to copy the file somewhere safe manually first.

You can verify all prerequisites are in place before running `make windows` by running the bundled check script in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check-windows-prereqs.ps1
```

`make windows` calls this script automatically and will stop with a descriptive error if any prerequisite is missing.

### Linux

- **`git` and `curl`** — install via your distro's package manager before running `make linux`.
- **`sudo` access** — required for package installation and writing to `/usr/local/bin`.
- **Supported distributions** — Ubuntu/Debian (`apt-get`), Fedora/RHEL (`dnf`), Arch Linux (`pacman`), and Alpine (`apk`). The bootstrap installs `zsh` automatically using the detected package manager.
- **Supported CPU architectures** — x86\_64 (amd64), aarch64/arm64, and armv7l/armv6l (arm).

## Installation

### Download dotfiles repository

```bash
git clone https://github.com/adisakshya/dotfiles ~/.dotfiles && cd ~/.dotfiles
```

Dotfiles can be installed either using the [Makefile](./Makefile) or the dotbot install-scripts.

The Makefile contains bootstrap scripts that install the following dependencies. Oh My Posh, Oh My ZSH, and ZSH plugins are pinned and checksum-verified; ZSH itself is installed via the system package manager without a version pin.
- Source Code Pro Powerline Font (all platforms)
- Oh My Posh (all platforms, pinned to an explicit version with SHA-256 verification)
- Oh My ZSH and required ZSH plugins (Linux only, pinned to specific Git commit SHAs)
- ZSH (Linux only, installed via the detected system package manager without a version pin)

After installing these prerequisites the symlinks are created for the chosen profile using dotbot install-script.

### On Windows

#### Personal machines — `make windows` (symlink-based, recommended)

On machines where you control Developer Mode, install with symlinks so any future edits to files in `~/.dotfiles` are reflected immediately without re-running the installer:

```bash
make windows
```

Requires **Developer Mode** or an **elevated (Administrator) shell** — see [Prerequisites → Windows](#windows) above.

#### Managed / work machines — `make windows-copy` (copy-based, no admin required)

On managed or work laptops where Developer Mode is unavailable or administrator access is restricted, use the copy-based installer instead:

```bash
make windows-copy
```

No UAC prompt and no Developer Mode are required. The following 10 files are installed as plain copies:

| Source | Destination |
|---|---|
| `common/bash/.bashrc` | `~/.bashrc` |
| `common/bash/.bash_profile` | `~/.bash_profile` |
| `.aliases` | `~/.aliases` |
| `.exports` | `~/.exports` |
| `common/oh-my-posh/adisakshya.yaml` | `~/adisakshya.yaml` |
| `windows/powershell/profile.ps1` | `~/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1` |
| `windows/powershell/profile.ps1` | `~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1` |
| `common/vscode/settings.json` | `~/AppData/Roaming/Code/User/settings.json` |
| `windows/windows-terminal/settings.json` | Windows Terminal `LocalState/settings.json` (stable) |
| `windows/windows-terminal/settings.json` | Windows Terminal `LocalState/settings.json` (Preview) |

**Tradeoff:** Because the files are copies rather than symlinks, changes you make to dotfiles in `~/.dotfiles` are not automatically reflected at the destinations. Re-run `make windows-copy` after editing your dotfiles to sync the changes.

**Backups:** Any existing file at a destination is backed up to `~/.dotfiles-backups/<timestamp>/` before being overwritten. You can preview what would be copied without making any changes by running:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install-windows-copy.ps1 -WhatIf
```

### On Linux

```bash
make linux
```

### Installing a predefined profile

```bash
$ ./install-profile <profile> [<configs...>]
```
See [meta/profiles/](./meta/profiles) for available profiles

### Installing single configurations

```bash
$ ./install-standalone <configs...>
```
See [meta/configs/](./meta/configs) for available configurations

### Existing files and dry runs

Installation replaces configured destinations with symlinks. Before relinking, any
existing file, directory, or symlink at a configured destination is copied to
`~/.dotfiles-backups/<UTC timestamp>-<process ID>/`, preserving its path
relative to your home directory. Installation stops if a backup cannot be
created. Forced replacement is enabled only by the installers, after this
backup succeeds.

For standalone configs ending in `-sudo`, the installer explicitly preserves
the caller's `HOME` for Dotbot so privileged linking targets the same paths that
were backed up.

Preview the destinations that would be backed up and the selected profile or
configs without modifying the filesystem or updating submodules:

```bash
./install-profile --dry-run linux
./install-standalone --dry-run bash zsh
```

`--check` is accepted as an alias for `--dry-run`. Restore a backup by copying the
desired file from its timestamped directory back to the corresponding path in
your home directory after removing the generated symlink.

To run the backup step in isolation — without touching submodules or creating
any symlinks — use the helper script at the repository root:

```bash
# Preview what would be backed up for the linux profile
./backup-existing.sh --dry-run --profile linux

# Back up without installing
./backup-existing.sh --profile linux

# Back up specific configs only
./backup-existing.sh --configs bash zsh essentials
```

This is useful when you want to inspect or preserve existing dotfiles before
committing to a full install.

### Re-running / Idempotency

Dotbot skips symlinks that already exist and already point to the correct target, so re-running `./install-profile <profile>` is safe. Only destinations that are missing or point elsewhere are updated (after the usual backup step described above).

### Removing managed symlinks

To remove managed symlinks, manually delete the symlinks listed in the YAML files under `meta/configs/`.

After removing symlinks, restore the original files from the `~/.dotfiles-backups/` directory created during installation.

## GitHub Codespaces

GitHub Codespaces supports automatic dotfiles personalisation: when you create a new Codespace, GitHub clones your dotfiles repository and runs the first recognised entrypoint it finds (`install.sh`, `bootstrap.sh`, `setup.sh`, or `script/setup`).

### Enabling dotfiles in Codespaces

1. Open your [Codespaces settings](https://github.com/settings/codespaces).
2. Under **Dotfiles**, enable *Automatically install dotfiles*.
3. Select this repository (`adisakshya/dotfiles`).

Every new Codespace you create will then clone the repository into `~/.dotfiles` and run `install.sh` automatically. See the [GitHub documentation](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles) for full details.

### What gets installed in a Codespace

The `install.sh` entrypoint runs Dotbot with the `codespaces` profile (`meta/profiles/codespaces`), which creates symlinks for the following configs:

| Config | What it provides |
|---|---|
| `bash` | `~/.bashrc` and `~/.bash_profile` |
| `essentials` | `~/.aliases` and `~/.exports` |
| `oh-my-posh` | `~/adisakshya.yaml` (prompt theme) |
| `vscode` | VS Code / Code Server `settings.json` |
| `zsh` | `~/.zshrc` |

Windows-only configs (`powershell`, `windows-terminal`) and font files are intentionally excluded — they have no effect in a Linux container.

> **Note:** `install.sh` creates the config symlinks but does not install `oh-my-posh` or `oh-my-zsh`. If you want the full prompt experience inside a Codespace, add a [devcontainer feature](https://containers.dev/features) or a `postCreateCommand` in your project's `devcontainer.json` to install those tools, or run `make linux` from the dotfiles directory after the Codespace starts.

### Rebuilding after updating dotfiles

Changes you push to this repository are picked up the next time a Codespace is created. To apply them to an existing Codespace without creating a new one:

```bash
cd ~/.dotfiles && git pull && ./install.sh
```

Or use **Codespaces → Rebuild container** from the VS Code command palette to get a completely fresh environment.

### Known limitations

- **Fonts** — Powerline / Source Code Pro fonts cannot be installed inside the container. In the browser-based editor, any configured Nerd Font will fall back to the browser's default monospace font. When connecting via a local VS Code client, configure the font in your *local* VS Code settings instead.
- **oh-my-posh / oh-my-zsh** — `install.sh` creates the config symlinks but does not install these tools. Without them the `~/.zshrc` prompt line will produce an error on first launch; bash is unaffected.

## Contents

### Profiles
<pre>
meta/profiles
├── <a href="./meta/profiles/codespaces" title="codespaces">codespaces</a>
├── <a href="./meta/profiles/linux" title="linux">linux</a>
└── <a href="./meta/profiles/windows" title="windows">windows</a>
</pre>

### Configs
<pre>
meta
├── <a href="./meta/base.yaml" title="base.yaml">base.yaml</a>
└── configs
    ├── <a href="./meta/configs/bash.yaml" title="bash.yaml">bash.yaml</a>
    ├── <a href="./meta/configs/essentials.yaml" title="essentials.yaml">essentials.yaml</a>
    ├── <a href="./meta/configs/oh-my-posh.yaml" title="oh-my-posh.yaml">oh-my-posh.yaml</a>
    ├── <a href="./meta/configs/powershell.yaml" title="powershell.yaml">powershell.yaml</a>
    ├── <a href="./meta/configs/vscode.yaml" title="vscode.yaml">vscode.yaml</a>
    ├── <a href="./meta/configs/windows-terminal.yaml" title="windows-terminal.yaml">windows-terminal.yaml</a>
    └── <a href="./meta/configs/zsh.yaml" title="zsh.yaml">zsh.yaml</a>
</pre>

## Updating pinned installation artifacts

Remote executables and installer inputs are pinned in `Makefile`,
`remote/Makefile`, and `scripts/install-windows-tools.ps1`. To upgrade one:

1. Change the explicit version or Git commit to the intended upstream release.
2. Download the artifact from that versioned URL and calculate its SHA-256 digest
   (`sha256sum <file>` on Linux or `Get-FileHash -Algorithm SHA256 <file>` on
   Windows). Never take a digest from the same untrusted download location as the
   artifact without also validating the publisher's signature.
3. Replace the corresponding checksum, run the checks below, and review the URL
   scan to ensure no mutable `latest`, `master` raw-download, or piped-shell URL
   was introduced.
4. For Git dependencies, update the full commit SHA. Dotbot remains recorded by
   the repository's submodule gitlink; installers intentionally do not pass
   `--remote`, so a checkout always installs that recorded revision.

The verified-download helpers write to a temporary file and move it into place
only after its digest matches. A checksum failure stops installation and removes
that temporary file.
