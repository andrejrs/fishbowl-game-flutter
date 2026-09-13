# 🚀 Publishing to Google Play

This document explains how to take the **Fishbowl Game** from a local build to a published app on the **Google Play Store**.

---

## 🔐 1. Signing Setup (already done for this project)

Before Google Play will accept a build, release APKs/AABs must be signed with a real release key — not the Flutter debug key.

- Release signing config lives in [`android/app/build.gradle.kts`](./android/app/build.gradle.kts), pointing at `android/key.properties`.
- **`android/key.properties` must live inside the `android/` folder**, not the Flutter project root — the Gradle script resolves it with `rootProject.file("key.properties")`, and `rootProject` for a Flutter app is the `android/` directory. Putting it one level too high causes a silent failure: all signing fields come back `null` and `flutter build appbundle` fails with a bare `NullPointerException` in `FinalizeBundleTask`.
- The release **upload keystore** is stored outside the repo at `/home/human/Projects/flatter/keystores/fishbowl-upload.jks`.
- `applicationId` / `namespace` is `com.akicay.fishbowl` — this is **permanent** once published; Google Play blocks anything under `com.example`.

> ⚠️ **Back up `fishbowl-upload.jks` and `android/key.properties` somewhere safe** (password manager, encrypted backup). If you lose them before enrolling in Play App Signing, you can never push an update to this app package again.

---

## 📦 2. Build the Release App Bundle

Google Play requires an **Android App Bundle (`.aab`)**, not an APK:

```bash
flutter build appbundle --release
```

Output:

```
build/app/outputs/bundle/release/app-release.aab
```

You can confirm it's signed with your real release cert (not the debug key) with:

```bash
apksigner verify --print-certs build/app/outputs/bundle/release/app-release.aab
```

---

## 🏗️ 3. Create a Google Play Console Account

1. Go to [play.google.com/console](https://play.google.com/console/).
2. Pay the one-time **$25 USD** registration fee.
3. Complete the developer account setup (identity verification may be required).

---

## 📝 4. Create the App Listing

In Play Console: **Create app** → set the app name, default language, Free/Paid, and accept the declarations.

### Store listing assets needed:
- **Short description** (max 80 characters)
- **Full description** (max 4000 characters)
- **App icon** — 512×512 PNG (export from [`assets/icon/icon.png`](./assets/icon/icon.png))
- **Feature graphic** — 1024×500
- **Screenshots** — at least 2 phone screenshots (16:9 or 9:16); grab these from a device with `adb shell screencap`
- **Privacy policy URL** — required even for simple apps; a basic static page (e.g. hosted on GitHub Pages) is sufficient

---

## 📋 5. Required Questionnaires

Play Console will require you to fill out, before releasing:
- **Privacy policy** link
- **Ads declaration** (does the app show ads?)
- **Content rating questionnaire**
- **Target audience & age** declaration
- **Data safety form** — what data the app collects. Fishbowl only stores player names locally via `shared_preferences`, so this is likely "no data collected/shared," but review the exact wording Google expects.
- **Government app declaration**

---

## 📤 6. Upload the Build

1. Play Console → your app → **Testing → Internal testing** (recommended first) → **Create release**.
2. Upload `build/app/outputs/bundle/release/app-release.aab`.
3. When prompted, accept **Play App Signing** — Google will manage the actual signing key going forward, and your local keystore becomes just the **upload key** used to authenticate new uploads.
4. Add your own email as an internal tester, save, and roll out.

---

## ✅ 7. Test, Then Promote to Production

1. Install the internal testing build via the opt-in link Play Console gives you.
2. Once verified on a real device (e.g. the moto g52 used for local testing), promote the release to **Production** (or go straight to Production if you're confident).
3. Production rollout usually takes a few hours to a few days for Google's review on a first submission.

---

## 🎉 Done!

Once approved, the **Fishbowl Game** will be live on the Google Play Store 💙
