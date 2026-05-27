# 🌸 Nihongo Master — Complete Japanese Learning App

A **free, offline-first, lightweight** Japanese learning app built with **Flutter**.  
Designed to run smoothly on **low-end Android phones** and built entirely from a **mobile phone using Termux**.

![Made with Flutter](https://img.shields.io/badge/Made%20with-Flutter-02569B?logo=flutter)
![Offline first](https://img.shields.io/badge/Offline-First-success)
![JLPT N5-N1](https://img.shields.io/badge/JLPT-N5%E2%86%92N1-FF6F91)
![Free & Open](https://img.shields.io/badge/Free-Open%20Source-blue)

---

## ✨ Features

| # | Module | What it does |
|---|--------|--------------|
| 1 | **Kana** | Hiragana + Katakana charts, tap-to-hear, quiz |
| 2 | **Vocabulary** | JLPT N5→N1 flashcards with SRS (SM-2 algorithm) |
| 3 | **Grammar** | Structured lessons with examples & progress tracking |
| 4 | **AI Tutor** | Offline rule-based + optional online LLM chat (furigana, romaji, translation) |
| 5 | **Anime Mode** | Common anime/manga phrases + shadowing |
| 6 | **Speaking** | Free Android speech recognition + pronunciation score (0–100) |
| 7 | **Quiz** | Multiple-choice, listening, typing — daily challenge |
| 8 | **SRS Review** | Spaced-repetition due cards |
| 9 | **Profile** | Username, XP, level, streak, badges, dark mode |
| 10| **Mascot** | "Mina-chan" 🌸 motivational assistant |

All data ships inside the APK as JSON → **works fully offline**.

---

## 📁 Project structure

```
nihongo_master/
├── pubspec.yaml                     ← Flutter dependencies
├── README.md                        ← This file
│
├── lib/                             ← All Dart source code
│   ├── main.dart                    ← Entry point + Provider setup
│   ├── theme/
│   │   └── app_theme.dart           ← Sakura/night gradients, light+dark themes
│   ├── services/                    ← Business logic (no UI)
│   │   ├── database_service.dart    ← SQLite + seeds vocab/kana/grammar/phrases
│   │   ├── user_progress_service.dart ← XP, level, streak, badges
│   │   ├── theme_service.dart       ← Saves light/dark choice
│   │   ├── notification_service.dart← Daily motivational notification
│   │   ├── tts_service.dart         ← Free Android text-to-speech (Japanese)
│   │   ├── speech_service.dart      ← Free Android speech recognition + scoring
│   │   └── ai_chat_service.dart     ← Offline tutor + optional online LLM
│   ├── widgets/
│   │   └── mascot.dart              ← Mina-chan assistant widget
│   └── screens/                     ← One file per screen
│       ├── splash_screen.dart
│       ├── onboarding_screen.dart
│       ├── home_screen.dart         ← Feature grid + XP header
│       ├── kana_screen.dart
│       ├── kana_quiz_screen.dart
│       ├── vocab_screen.dart        ← Flashcards + SRS grading
│       ├── grammar_screen.dart
│       ├── chat_screen.dart         ← AI chat with furigana / romaji toggle
│       ├── anime_screen.dart
│       ├── speaking_screen.dart
│       ├── quiz_screen.dart
│       ├── srs_screen.dart
│       └── profile_screen.dart
│
├── assets/
│   ├── data/                        ← JSON seed data bundled into APK
│   │   ├── kana.json                ← 92 chars (hiragana + katakana)
│   │   ├── vocab.json               ← JLPT N5–N1 vocabulary
│   │   ├── grammar.json             ← Grammar points N5–N1
│   │   └── phrases.json             ← Daily + anime phrases
│   ├── images/                      ← Drop your own pngs/svgs here
│   └── audio/                       ← Optional pre-recorded mp3 (we use TTS by default)
│
└── android/                         ← Android-specific config
    ├── build.gradle
    ├── settings.gradle
    ├── gradle.properties
    └── app/
        ├── build.gradle             ← minSdk 21 → runs on Android 5.0+
        └── src/main/
            ├── AndroidManifest.xml
            └── res/
                ├── drawable/launch_background.xml
                └── values/styles.xml
```

---

## 📦 Adding more content

Open the JSON files inside `assets/data/` and add more rows — no recompile needed for content tweaks beyond a `flutter pub get` then re-build.

```json
{"kanji":"猫","kana":"ねこ","romaji":"neko","meaning":"cat",
 "jlpt":"N5","example":"猫が好きです。","example_en":"I like cats."}
```

---

## 🛠️ Build the APK **directly on your Android phone** (Termux)

You need **about 5 GB of free space**. No PC required.

### Step 1 — Install Termux

Install Termux **from F-Droid** (the Play Store version is outdated):  
👉 https://f-droid.org/en/packages/com.termux/

Open Termux and update:

```bash
pkg update -y && pkg upgrade -y
```

### Step 2 — Install dependencies

```bash
pkg install -y git curl unzip xz-utils which openjdk-17 wget
termux-setup-storage   # tap Allow when prompted
```

### Step 3 — Install Flutter

```bash
cd ~
git clone --depth 1 -b stable https://github.com/flutter/flutter.git
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
flutter --version
```

### Step 4 — Install the Android command-line tools

```bash
mkdir -p ~/android-sdk/cmdline-tools && cd ~/android-sdk/cmdline-tools
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmd.zip
unzip cmd.zip && mv cmdline-tools latest && rm cmd.zip
export ANDROID_HOME=$HOME/android-sdk
echo 'export ANDROID_HOME=$HOME/android-sdk' >> ~/.bashrc
echo 'export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH' >> ~/.bashrc
source ~/.bashrc
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
flutter config --android-sdk $ANDROID_HOME
```

> ⚠️ Termux cannot run the official Android emulator. We build the **APK** and install it directly.

### Step 5 — Copy the Nihongo Master project to your phone

Two easy options:

**Option A — via USB / file manager**  
Copy the `nihongo_master/` folder into `Internal Storage → Download/`.

**Option B — via git** (recommended)  
```bash
cd ~
# If you uploaded the project to GitHub:
git clone https://github.com/YOUR-USERNAME/nihongo_master.git
cd nihongo_master
```

Or move from the storage you copied to:
```bash
cp -r /storage/emulated/0/Download/nihongo_master ~/
cd ~/nihongo_master
```

### Step 6 — Build the APK

```bash
flutter pub get
flutter build apk --release
```

The signed APK will appear at:

```
build/app/outputs/flutter-apk/app-release.apk
```

### Step 7 — Install on your phone

```bash
cp build/app/outputs/flutter-apk/app-release.apk /storage/emulated/0/Download/
```

Open the file manager → tap the APK → allow "Install from unknown sources" → install. Done! 🌸

---

## ✏️ Editing the app later on mobile

You have two options:

1. **Termux + a text editor** (lightweight, no GUI):
   ```bash
   pkg install nano vim micro
   cd ~/nihongo_master
   micro lib/screens/home_screen.dart
   ```
2. **Acode** (free Android IDE): https://acode.app — open the project folder via Acode, edit any `.dart` or `.json`, then go back to Termux and rebuild:
   ```bash
   cd ~/nihongo_master && flutter build apk --release
   ```

---

## 🤖 Optional: enable online AI tutor

The app uses an **offline rule-based tutor** by default. If you want a smarter LLM:

1. Get a free key from one of:
   - **Groq** (free, fast) — https://console.groq.com
   - **OpenRouter** (many free models) — https://openrouter.ai
   - **Ollama** (self-hosted) — http://localhost:11434/v1/chat/completions
2. Open the app → Profile → fill in **API URL** and **API key** → Save.

That's it — the chat will now route to your endpoint and fall back to offline if the network drops.

---

## 🪶 Performance notes (low-end devices)

- `minSdkVersion 21` → runs on Android 5.0 phones (~1 GB RAM).
- ABI splits in `android/app/build.gradle` cut APK size roughly in half.
- R8 / resource shrinking turned on for release builds.
- No background services. Audio playback uses Android-native TTS (no MP3 bundles needed).
- SQLite avoids re-loading JSON each launch.
- All animations use `flutter_animate` which is very GPU-light.

Typical install size: **~18 MB** per ABI.

---

## 📜 License

MIT — do whatever you want, just keep the credit. Have fun! 🎌
