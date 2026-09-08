<div align="center">

# 🛡️ MOTION GUARD

### ⚡ Your phone, guarding itself. ⚡

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS-3DDC84?style=for-the-badge&logo=android&logoColor=white)](#)
[![Material 3](https://img.shields.io/badge/Material-3-757575?style=for-the-badge&logo=materialdesign&logoColor=white)](#)
[![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=for-the-badge)](#)

**A Flutter security utility that watches your device's accelerometer and raises an alarm the moment it's moved, lifted, or tampered with — even while running in the background.**

### 📥 [**Download APK**](https://github.com/amalmathew2003/MotionDetectionApp/releases/latest)

[![Download](https://img.shields.io/badge/Download-APK-success?style=for-the-badge&logo=android&logoColor=white)](https://github.com/amalmathew2003/MotionDetectionApp/releases/latest)
[![Latest Release](https://img.shields.io/github/v/release/amalmathew2003/MotionDetectionApp?style=for-the-badge&label=Latest&color=blue)](https://github.com/amalmathew2003/MotionDetectionApp/releases/latest)

```
  ⚪  STANDBY   ───▶   🟣  ARMED   ───▶   🔴  ALARM!
```

</div>

<br>

## 🎯 Why It Exists

> Leaving a phone unattended on a desk, in a bag, or by a door is risky.

**Motion Guard** turns the built-in accelerometer into a tripwire — arm it, walk away, and get an **immediate, loud alert** if anything disturbs the device.

<br>

## ⚙️ How It Works

Motion Guard runs a background isolate that continuously reads the accelerometer and computes a magnitude vector:

<div align="center">

### `magnitude = √(Δx² + Δy² + Δz²)`

</div>

That value is checked against a user-set threshold on **every sample**. Cross it, and the alarm fires — instantly — whether the app is foregrounded, minimized, or the screen is off.

<br>

## ✨ Features

<table>
<tr>
<td width="50%">

### 🟣 Live Guard Dashboard
A pulsing status orb reflects system state in real time — grey when idle, purple while armed, flashing red on breach — alongside live X/Y/Z bars and a magnitude meter.

</td>
<td width="50%">

### 🌙 Background Detection
Powered by `flutter_background_service`, monitoring continues uninterrupted regardless of app lifecycle state.

</td>
</tr>
<tr>
<td width="50%">

### 📊 Event History
The last **50 breach events** are logged with timestamp and magnitude, auto-tagged as *Normal* or *Strong Motion* (> 5.0).

</td>
<td width="50%">

### 🎚️ Tunable Sensitivity
A single slider moves the trigger threshold from **2.0** (very sensitive) to **7.0** (very lenient), with a choice of alarm tones and instant previews.

</td>
</tr>
</table>

<br>

## 🧱 Stack

<div align="center">

| Layer | Library |
|:---:|:---:|
| 📡 Sensors | `sensors_plus` |
| 🔄 Background execution | `flutter_background_service` |
| 🔔 Notifications | `flutter_local_notifications` |
| 🔊 Audio | `audioplayers` |
| 🔐 Permissions | `permission_handler` |

**Dart SDK `^3.8.1`** &nbsp;·&nbsp; **Material 3** &nbsp;·&nbsp; **Android & iOS**

</div>

<br>

## 📂 Structure

```
lib/
├── main.dart                    ⚡ entry point, background service init
├── models/
│   └── detection_event.dart     📦 motion log entry model
├── screens/
│   ├── main_shell.dart          🧭 bottom nav + state
│   ├── home_screen.dart         🟣 status orb, sensor meters
│   ├── history_screen.dart      📊 breach log
│   └── settings_screen.dart     🎚️ sensitivity & alarm sound
├── services/
│   └── background_service.dart  🔄 isolate + accelerometer stream
└── widgets/
    └── shared_widgets.dart      🌌 glassmorphism UI components
```

<br>

## 🚀 Run It

### Option 1 — Install the APK directly
1. Go to [**Releases**](https://github.com/amalmathew2003/MotionDetectionApp/releases/latest)
2. Download `app-release.apk`
3. Install it on your Android device (enable "Install from unknown sources" if prompted)

### Option 2 — Build from source
```bash
git clone https://github.com/amalmathew2003/motion_detection_app.git
cd motion_detection_app
flutter pub get
flutter run
```

<br>

## 📍 Where It's Useful

| 🖥️ Desk | 🎒 Bags | 🚪 Doors | 🔌 Charging |
|:---:|:---:|:---:|:---:|
| Shared/public workstations | Transit tripwire | Drawers & valuables | Overnight, unattended |

<br>

---

<div align="center">

### 👤 Amal Mathew
**Flutter Developer** · Thrissur, Kerala

[![GitHub](https://img.shields.io/badge/GitHub-amalmathew2003-181717?style=for-the-badge&logo=github)](https://github.com/amalmathew2003)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/amal-mathew-1-)
[![Portfolio](https://img.shields.io/badge/Portfolio-Visit-000000?style=for-the-badge&logo=vercel&logoColor=white)](https://amalmathew2003.github.io/newportfolio/)

<sub>⭐ If you like this project, consider giving it a star!</sub>

</div>
