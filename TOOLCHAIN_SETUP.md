# 🧩 Toolchain Setup (Linux)

This document explains how to set up the **OS-level toolchain** — JDK, Android SDK, and native build dependencies — needed to build and run the Fishbowl Game on Linux.

Unlike [`SETUP_GUIDE.md`](./SETUP_GUIDE.md) (which assumes Flutter and the Android SDK are already installed), this document starts from a bare Linux machine.

---

## 🐧 1. Install System Packages

### Debian / Ubuntu

```bash
sudo apt update && sudo apt install -y openjdk-17-jdk libgtk-3-dev clang mesa-utils
```

### Fedora

```bash
sudo dnf install -y java-17-openjdk-devel gtk3-devel clang glx-utils
sudo dnf install -y cmake gcc-c++ pkg-config
sudo dnf install -y android-tools
```

These packages provide:
- **JDK 17** — required to run Gradle, which builds the Android side of the app.
- **GTK3 development headers** (`libgtk-3-dev` / `gtk3-devel`) — required to build Flutter's Linux desktop embedder.
- **`clang`, `cmake`, `gcc-c++`, `pkg-config`** — the native build toolchain Flutter's Linux engine and any native (C/C++) plugins need to compile.
- **`glx-utils` / `mesa-utils`** — OpenGL utilities (`glxinfo`, etc.), useful for graphics debugging.
- **`android-tools`** — provides `adb` and `fastboot` for talking to Android devices over USB (Fedora only; Debian gets these from the Android SDK's `platform-tools` instead).

> ⚠️ **Fedora-specific note:** Fedora's own repositories may only ship newer JDKs (e.g. JDK 25/27), which can fail to build against Gradle/AGP (Android Gradle Plugin) with a cryptic version-mismatch error. If that happens, install a standalone JDK 17 from [Eclipse Adoptium (Temurin)](https://adoptium.net/) instead of relying on the distro package, and point `JAVA_HOME` at it (see step 3).

---

## 📦 2. Install the Flutter SDK and Android SDK

1. Download the [Flutter SDK](https://docs.flutter.dev/get-started/install/linux) and extract it somewhere on disk (e.g. `~/Projects/flatter/flutter`).
2. Download the [Android command-line tools](https://developer.android.com/studio#command-line-tools-only) and extract them into an SDK directory (e.g. `~/Projects/flatter/android-sdk/cmdline-tools/latest`).
3. If you had to install a standalone JDK 17 (see the Fedora note above), extract it too (e.g. `~/Projects/flatter/jdk17`).

---

## 🔧 3. Set Environment Variables

Add the following to `~/.bashrc` (or `~/.zshrc`), adjusting paths to match where you installed things in step 2:

```bash
export JAVA_HOME=~/Projects/flatter/jdk17
export ANDROID_HOME=~/Projects/flatter/android-sdk
export PATH=$PATH:~/Projects/flatter/flutter/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
```

- **`JAVA_HOME`** — tells Gradle and other JVM-based tools which JDK to use. Point this at your standalone JDK 17 if the system JDK is incompatible.
- **`ANDROID_HOME`** — tells the Android SDK tools (and Flutter) where the SDK lives.
- **`PATH`** additions — make the `flutter`/`dart` commands available (`flutter/bin`), plus `sdkmanager`/`avdmanager` (`cmdline-tools/latest/bin`) and `adb`/`fastboot` (`platform-tools`).

Reload your shell (`source ~/.bashrc`) or open a new terminal for these to take effect.

---

## ✅ 4. Accept Android SDK Licenses & Install SDK Packages

```bash
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

- **`yes | sdkmanager --licenses`** — `sdkmanager --licenses` interactively prompts `y/n` for each Android SDK license; piping `yes` auto-answers "yes" to all of them non-interactively.
- **`sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"`** — installs the three SDK components a Flutter Android build needs: `platform-tools` (`adb`, `fastboot`), the Android 34 platform SDK (compile/target API), and the matching `34.0.0` build tools (`aapt`, `zipalign`, `apksigner`, etc.).

---

## ⚙️ 5. Persist the JDK Path for Flutter

```bash
flutter config --jdk-dir="/path/to/your/jdk17"
```

This tells Flutter which JDK to use for Gradle builds specifically. Unlike the `JAVA_HOME` export in step 3, this setting is written to Flutter's own config file, so it survives across terminal sessions even in a shell where `JAVA_HOME` isn't set.

> 💡 Keep this in sync with `JAVA_HOME` — if they point at different JDKs, whichever one Gradle actually picks up can be inconsistent. Run `flutter config` to check the current value.

---

## 🩺 6. Verify

```bash
flutter doctor
```

This should report the Flutter SDK, Android toolchain, and connected devices as all set up correctly (green checkmarks). Resolve anything it flags before continuing.

To confirm a device is visible and authorized:

```bash
adb devices
```

A connected phone should show as `device` (not `unauthorized` — if it does, accept the USB debugging prompt on the phone itself) or `unknown`.

---

## 🎉 Done!

With packages installed, environment variables set and persisted, SDK licenses accepted, and the JDK path configured, you're ready to follow [`SETUP_GUIDE.md`](./SETUP_GUIDE.md) to fetch dependencies, run, and build the app.
