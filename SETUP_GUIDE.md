# 🧰 Project Setup & Build Guide

This document explains how to **import**, **run**, and **build** the Fishbowl Game Flutter project using **Visual Studio Code**.

---

## 🪄 1. Prerequisites

Before you start, make sure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)  
- [Dart SDK](https://dart.dev/get-dart) *(usually included with Flutter)*  
- [Visual Studio Code](https://code.visualstudio.com/)  
- **Flutter** and **Dart** VS Code extensions  
- [Android Studio](https://developer.android.com/studio) (for Android SDK and emulator)

To confirm Flutter is correctly installed, run in your terminal:

```bash
flutter doctor
```

If everything is properly set up, you’ll see green check marks ✅.  
If there are any warnings or missing tools, follow the suggestions from `flutter doctor` to fix them.

---

## 📦 2. Clone the Repository

Open a terminal and clone the repository from GitHub:

```bash
git clone git@github.com:andrejrs/fishbowl-game-flutter.git
```

Then navigate to the project directory:

```bash
cd fishbowl-game-flutter
```

---

## 🧩 3. Open the Project in VS Code

1. Open **VS Code**.  
2. Click **File → Open Folder** and select the `fishbowl-game` folder.  
3. When prompted, VS Code will detect it as a Flutter project and may ask to install recommended extensions — click **Yes**.

---

## 📥 4. Install Dependencies

Run the following command to fetch all required packages:

```bash
flutter pub get
```

This will install all dependencies defined in your `pubspec.yaml` file.

---

## ▶️ 5. Run the Project

You can run the app on an **emulator** or a **physical device**.

### Option 1 – From VS Code
- Click the **Run ▶️** button in the top-right corner  
- Or open the **Command Palette** (`Ctrl + Shift + P` / `Cmd + Shift + P`)  
  and select **Flutter: Launch Emulator** or **Flutter: Run Without Debugging**

### Option 2 – From Terminal
Run:

```bash
flutter run
```

If multiple devices are connected, Flutter will prompt you to choose one.

---

## 📱 6. Build APK for Android

To generate a release APK (ready for installation on any Android device):

```bash
flutter build apk --release
```

The generated APK file will be located at:

```
build/app/outputs/flutter-apk/app-release.apk
```

You can then copy this file to your Android device or share it for installation.

---

## 🧾 7. (Optional) Build for Debug or Profile

For testing or debugging, you can also build:

- **Debug APK:**  
  ```bash
  flutter build apk --debug
  ```
- **Profile APK:**  
  ```bash
  flutter build apk --profile
  ```

---

## ⚡ Common Issues

- **Device not found:**  
  Make sure an emulator is running or a physical device is connected and authorized.

- **Gradle build failed:**  
  Run:
  ```bash
  flutter clean
  flutter pub get
  ```
  Then try building again.

- **Missing Android SDK:**  
  Open Android Studio → Settings → SDK Manager → Install latest SDK platform.

---

## 🧠 Notes

- Each time you modify dependencies in `pubspec.yaml`, run `flutter pub get` again.  
- You can hot-reload changes during development with `r` in the terminal or by clicking **Hot Reload** in VS Code.  
- For iOS builds, a macOS environment with Xcode is required.

---

## 🎉 Done!

You’re ready to start exploring and contributing to the **Fishbowl Game** Flutter project!  
Happy coding 💙
