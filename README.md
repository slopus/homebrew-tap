# Slopus Tap

## Happy Desktop

```sh
brew install --cask slopus/tap/happy
```

Homebrew selects the native Apple Silicon or Intel macOS download. Linux x64
and arm64 support is enabled when a stable desktop release includes both
AppImages; a macOS-only version is explicitly marked as such.

On Linux, launch with `happy-desktop` (or `~/Applications/Happy.AppImage`). A
graphical desktop and AppImage/FUSE support are required; Ubuntu 24.04 x64 and
arm64 are exercised in CI. On Ubuntu install `libfuse2t64` if AppImage reports
that `libfuse.so.2` is missing. Homebrew does not make macOS downloads run on Linux.

```sh
brew upgrade --cask slopus/tap/happy
brew uninstall --cask slopus/tap/happy
```

The app remains available by [direct download](https://github.com/slopus/happy-desktop/releases/latest).
macOS retains Happy's native auto-updater. Linux upgrades use Homebrew. Uninstall
removes the application only, never your Happy Agent data or workspaces.

The hourly `Update Happy from stable release` workflow pins upstream SHA-256
checksums and tests each candidate before publishing it. CI installs the cask
with Homebrew, verifies macOS Gatekeeper acceptance, boots the packaged app to
its welcome screen on every supported OS/architecture, saves screenshots, and
uninstalls it. Drafts, previews, incomplete releases, downgrades, and same-version
asset replacements are rejected. Maintainers can run the workflow manually for
immediate delivery; it needs no cross-repository publishing credential.

## How do I install these formulae?

`brew install slopus/tap/<formula>`

Or `brew tap slopus/tap` and then `brew install <formula>`.

Or, in a `brew bundle` `Brewfile`:

```ruby
tap "slopus/tap"
brew "<formula>"
```

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
