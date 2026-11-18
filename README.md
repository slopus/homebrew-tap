# Slopus Tap

## Happy Desktop

```sh
brew install --cask slopus/tap/happy
```

Then open Happy like any other Mac app: press Cmd+Space, type "Happy", and
press Return (or run `open -a Happy`). The cask installs no `happy` terminal
command; if your terminal has one, it is the older Happy CLI (`happy-coder`),
not the desktop app.

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
with Homebrew, verifies the installed package version and native architecture,
checks macOS signatures and Gatekeeper acceptance, renders the packaged app's
welcome screen on every supported OS/architecture, saves screenshots, and
uninstalls it. It uses Desktop's hidden smoke report with a fresh profile and
analytics disabled, keeping the normal app sandbox. Drafts, previews, incomplete
releases, downgrades, and same-version asset replacements are rejected. Before
publishing, the updater rechecks GitHub Latest and refuses a superseded candidate
or a tap changed during testing. The next run starts from Latest again.

Desktop's stable release flow verifies delivery by watching this public cask;
the tap remains the sole writer and needs no cross-repository credential.
Pull requests run the full gate against GitHub Latest without publishing. The
old `0.0.102` pin predates smoke reports: its separate legacy baseline verifies
installation and identity only, and explicitly claims no launch pass. That
exception never applies to a candidate or updater publication.

Maintainers can retry delivery immediately from Actions → **Update Happy from
stable release** → **Run workflow**, selecting `main`, or with:

```sh
gh workflow run update-happy.yml --repo slopus/homebrew-tap --ref main
```

Check for an already active updater before starting one. The workflow serializes
updates, reports failures in its check and summary, and retains `happy-cask-*`
launch logs, reports, package metadata and screenshots for 30 days. Inspect that
evidence before retrying a failed installation or smoke check; retries never
bypass the publication gate. The hourly schedule is the automatic fallback.

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
