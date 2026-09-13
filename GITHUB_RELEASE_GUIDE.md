# 📦 Distributing the APK via GitHub Releases

This document explains how to share a built APK of **Fishbowl Game** so anyone can download and install it directly from GitHub, without going through the Google Play Store.

GitHub's **Releases** feature is the right tool for this — it attaches the APK as a downloadable binary tied to a version tag. Don't commit the `.apk` file directly into the repository; that would bloat the git history every time a new build is made.

---

## 🏗️ 1. Build the Release APK

```bash
flutter build apk --release
```

The output file will be at:

```
build/app/outputs/flutter-apk/app-release.apk
```

This is a single "universal" APK that works on any Android device (as opposed to the Play Store, which can split it into smaller per-device APKs automatically).

---

## 🏷️ 2. Pick or Create a Version Tag

Releases are tied to a git tag. To create a new one for the current commit:

```bash
git tag v1.0.1
git push origin v1.0.1
```

Use [semantic versioning](https://semver.org/) (`vMAJOR.MINOR.PATCH`) — bump the patch number for small fixes, the minor number for new features, the major number for breaking/large changes.

---

## 🚀 3. Publish the Release (Web UI)

1. Go to your repository on GitHub.
2. Click **Releases** in the right sidebar (or navigate to `https://github.com/<owner>/<repo>/releases`).
3. Click **Draft a new release**.
4. Under **Choose a tag**, select the tag from step 2.
5. Give the release a **title** (e.g. `v1.0.1`) and write **release notes** describing what changed.
6. Drag and drop `app-release.apk` into the **"Attach binaries by dropping them here"** box at the bottom.
7. Click **Publish release**.

Once published, anyone visiting the release page can download the `.apk` file directly.

---

## 💻 Alternative: Publish via the `gh` CLI

If you have the [GitHub CLI](https://cli.github.com/) installed (`gh`), the same thing can be done from the terminal:

```bash
gh release create v1.0.1 \
  build/app/outputs/flutter-apk/app-release.apk \
  --title "v1.0.1" \
  --notes "Describe what changed in this release."
```

This creates the tag (if it doesn't already exist), creates the release, and uploads the APK as an asset, all in one command.

To install the CLI on Fedora:

```bash
sudo dnf install gh
gh auth login
```

---

## ⚠️ 4. Warn Downloaders About Installation

Since this APK isn't distributed through Google Play, Android will show extra friction when installing it:

- **"Install blocked" / unknown sources** — the person installing needs to allow their browser or file manager to "Install unknown apps" (Android Settings → Apps → *Special access* → *Install unknown apps*).
- **Play Protect warning** — Android may show a warning that the app isn't recognized, since it hasn't been scanned by Play Store's review process. This doesn't mean it's unsafe, just unfamiliar to Play Protect.

It's worth including a short note about this in the release description so downloaders aren't caught off guard.

---

## 🔄 5. Updating an Existing Release

To replace the APK on an already-published release (e.g. you fixed a bug and rebuilt):

```bash
gh release upload v1.0.1 build/app/outputs/flutter-apk/app-release.apk --clobber
```

Or, in the web UI: open the release → **Edit release** → delete the old asset → upload the new one → **Update release**.

---

## 🎉 Done!

The APK is now publicly downloadable from your repository's **Releases** page — no Play Store account or review process required.
