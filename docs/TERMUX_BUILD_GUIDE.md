# 📱 Step-by-step: Build Nihongo Master APK on an Android phone

This guide assumes you have **only a phone** — no PC, no laptop.

> ⏱️ Total time: ~45 minutes (mostly waiting for downloads).  
> 💾 Free space needed: ~5 GB.

---

## 1. Install Termux

Termux from the Play Store is **outdated** and will break. Use F-Droid:

1. Open Chrome → go to <https://f-droid.org/en/packages/com.termux/>
2. Tap **Download APK**.
3. Allow "Install from unknown sources" if prompted.
4. Open Termux.

Also install **Termux:API** (optional but helpful):
<https://f-droid.org/en/packages/com.termux.api/>

---

## 2. First-time setup

Inside Termux, type each command and press Enter:

```bash
pkg update -y && pkg upgrade -y
pkg install -y git curl wget unzip xz-utils which openjdk-17 nano
termux-setup-storage   # accept the popup → gives Termux access to your files
```

---

## 3. Install Flutter

```bash
cd ~
git clone --depth 1 -b stable https://github.com/flutter/flutter.git
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
flutter --version
```

You should see something like `Flutter 3.24.x • channel stable`.

---

## 4. Install Android SDK command-line tools

```bash
mkdir -p ~/android-sdk/cmdline-tools && cd ~/android-sdk/cmdline-tools
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmd.zip
unzip cmd.zip && mv cmdline-tools latest && rm cmd.zip

cat >> ~/.bashrc <<'EOF'
export ANDROID_HOME=$HOME/android-sdk
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH
EOF
source ~/.bashrc

yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
flutter config --android-sdk $ANDROID_HOME
flutter doctor
```

`flutter doctor` should now show ✅ next to "Android toolchain".

---

## 5. Get the Nihongo Master source code

If you received the project as a ZIP, place it in `Download/` and run:

```bash
cd ~
cp -r /storage/emulated/0/Download/nihongo_master .
cd nihongo_master
```

If you uploaded the project to GitHub:

```bash
cd ~
git clone https://github.com/YOUR-USERNAME/nihongo_master.git
cd nihongo_master
```

---

## 6. Build the APK

```bash
flutter pub get
flutter build apk --release
```

The build takes 3–10 minutes on a typical phone. Output:

```
build/app/outputs/flutter-apk/app-release.apk
```

Copy it to your visible Downloads folder so you can tap it:

```bash
cp build/app/outputs/flutter-apk/app-release.apk /storage/emulated/0/Download/
```

Open File Manager → tap **app-release.apk** → install. 🎉

---

## 7. Common errors

| Problem | Fix |
|---|---|
| `Gradle build failed: out of memory` | `export GRADLE_OPTS="-Xmx768m"` then rebuild |
| `Android licenses not accepted` | `yes \| flutter doctor --android-licenses` |
| `Permission denied` writing to /storage | rerun `termux-setup-storage` |
| App crashes on launch (older phone) | edit `android/app/build.gradle` → set `minSdkVersion 19` |
| TTS doesn't speak Japanese | Android Settings → System → Languages → Text-to-speech → install Japanese voice |

---

## 8. Editing later

```bash
cd ~/nihongo_master
nano lib/screens/home_screen.dart   # or use Acode editor app
flutter build apk --release
```

You can rebuild as many times as you want — only changed code recompiles.

がんばって！ 🌸
