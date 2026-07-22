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
- **Developer Mode enabled *or* an elevated (Administrator) shell** — required for symlink creation. Enable Developer Mode under *Settings → Privacy & security → For developers*, or open a terminal as Administrator. Without one of these, Dotbot will fail to create symlinks mid-install.
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

```bash
make windows
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

## Contents

### Profiles
<pre>
meta/profiles
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
