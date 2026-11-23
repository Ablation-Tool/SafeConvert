# SafeConvert: Architecture, Privacy & Safety Boundaries

**SafeConvert** is a standalone **Android**, **Apple** (iPhone, Apple Fold, iPad), and **Web** application with two simultaneous layers:

1. **Layer One (Cover Screen):** A fast, zero-ad, zero-tracking everyday **Unit Converter** (Length, Weight, Temperature, Volume) with a neutral launcher icon and app name (`SafeConvert`).
2. **Layer Two (Discreet Safety Companion):** A local international personal safety companion, trauma-informed post-incident checklist, Calming Studio, Young Child Easy Picture Mode, SHA-256 private proof vault, and Bluetooth LE Help Beacon & Blind Encrypted Relay Mesh.

> **Opening Layer Two:** Type any 3-digit `9`/`1` variant into the unit converter number field (`911`, `991`, `919`, `199`, `119`, `191`, `999`, or `111`). Decimals and leading zeros also work (`9.11`, `91.1`, `0.911`, `1.19`, `9.99`).
>
> **Instant Return to Cover:** Tap **`✕ EXIT`**, tap the top bar, press **Back** or **`ESC`**, switch apps, lock the screen, or leave idle for 90 seconds.

---

## 1. Security & Anti-Surveillance Design

| Protection | Android (`research.zoetic.safeconvert`) | Apple (`research.zoetic.safeconvert`) |
|:---|:---|:---|
| **Network Isolation** | Zero `INTERNET` permission in `AndroidManifest.xml`, `setBlockNetworkLoads(true)`, and strict `file:///android_asset/safeconvert/` request interception. | `WKWebView` loads only bundled local files and cancels non-file navigation except user-tapped external links. |
| **Screenshot & Recents Shield** | Dynamically enables `WindowManager.LayoutParams.FLAG_SECURE` when Layer Two opens and clears it on exit. | Immediately stops speech, exits to cover, and covers the viewport with a thick `UIVisualEffectView` blur shield on `willResignActiveNotification`. |
| **Zero Cloud Backup** | `android:allowBackup="false"`, `android:fullBackupContent="false"`, and strict `data_extraction_rules.xml` exclusion. | `PrivacyInfo.xcprivacy` declares zero tracking and zero collected data. |
| **Instant Panic Exit** | Cuts TTS (`<10 ms`), stops BLE advertising/scanning, cancels GPS fix, locks passcode vault, wipes ephemeral chat/art, and returns to the Unit Converter. | Stops `AVSpeechSynthesizer` immediately, runs `exitHelp()`, and hides screen behind blur shield. |
| **External Link Allowlist** | User-tapped `tel:`, `sms:`, `mailto:`, `geo:`, and `https:` only. | User-tapped `tel:`, `sms:`, `mailto:`, `geo:` (translated to Apple Maps), `maps:`, and `https:` only. |

---

## 2. International Packs, Vault & BLE Help Beacon

- **8 Regional Packs & 5 Languages:** US (`911`), EU (`112`, `116 111`, `116 006`), UK (`999` / `112` + Silent Solution `55`, `0808 2000 247`), Canada (`911`, `988`), Australia (`000`, `1800RESPECT`), Mexico / LATAM (`911`), India (`112`, `181`, `1098`), and Global (`112` / `911`). Instant switching across English (`EN`), Spanish (`ES`), French (`FR`), German (`DE`), and Portuguese (`PT`).
- **Private Proof Vault (`SafeEvidenceStore.java` + `SafeVaultLock.java`):** UTC-timestamped notes, opt-in `.m4a` audio, and opt-in `.mp4` video saved strictly in app-private storage (never in the public Gallery) with SHA-256 verification, optional 4-32 character `PBKDF2WithHmacSHA256` passcode lock that auto-locks on exit, and a 2-step explicit permission gate before sharing.
- **Bluetooth LE Help Beacon (`SafeBeaconMesh.java` + `SafeBeaconMeshCore.swift`):**
  - 22-byte signed packet with 15-minute rotating SHA-256 ephemeral tags.
  - Starts strictly OFF. Never scans or advertises in the background.
  - Hard 30-minute auto-expiry timer and 1-tap Rotate / Revoke All Keys.

---

## 3. Honest Safety Boundaries & Credits

- **Not Medical, Legal, or Emergency Dispatch Advice:** SafeConvert is a local information, calming, documentation, and short-range Bluetooth LE tool. It is not professional therapy, legal counsel, or a guarantee of physical safety. Calls and texts depend on your phone, carrier, signal, and local services.
- **Bluetooth LE Range:** Short-range peer-to-peer BLE typically reaches ~30-80 m between active SafeConvert phones depending on walls and terrain. It does not use Apple's proprietary global Find My network.
- **Recording Laws:** One-party vs. two-party audio/video consent laws vary by jurisdiction. Record only when safe and lawful.
- **Credits:** Original SafeConvert concept credited to **ExileKingdom / Nuclide**. Standalone Android, Apple (iOS / iPadOS / Apple Fold), and Web implementation engineered independently under GPL-3.0.
