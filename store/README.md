# Store submission kit

Everything to paste or upload into **Google Play Console** and **App Store
Connect**. The listing *text* (name, descriptions, keywords) lives in the main
[README → Store listing](../README.md#️-store-listing), so there's one copy to
keep in sync. All images here are rendered from the real app by
`./tool/store/generate.sh`; rerun it after a noticeable UI change.

```
store/
  google-play/
    icon-512.png                  App icon, 512×512
    feature-graphic.png           Feature graphic, 1024×500
    phone-screenshots/            5 × 1080×1920
  app-store/
    iphone-6.9/                   5 × 1320×2868 (6.9" display, required)
    ipad-13/                      5 × 2064×2752 (13" display, required: the app supports iPad)
```

Screenshot order tells the story: **01** the light show → **02** spectrum →
**03** beats → **04** customize modes → **05** privacy.

## Before the first upload

- [ ] App ID / bundle ID is `com.shaunniekins.suga` (set in
      `android/app/build.gradle.kts` and the Xcode project). It can't change
      once the app is published.
- [ ] Android upload key and `android/key.properties` exist (see
      [README → Releasing](../README.md#-releasing)); the `.aab` is not
      debug-signed.
- [ ] The website is live, so the privacy policy URL works:
      `https://suga.shaunniekins.com/privacy`.
- [ ] `version:` in `pubspec.yaml` is bumped for every upload.

## Google Play Console

**Main store listing** (Grow → Store presence)

| Field | Value |
|---|---|
| App name | from README (`Suga: Music Visualizer`) |
| Short description | from README |
| Full description | from README |
| App icon | `google-play/icon-512.png` |
| Feature graphic | `google-play/feature-graphic.png` |
| Phone screenshots | `google-play/phone-screenshots/*.png` (in order) |
| Tablet screenshots | optional; `app-store/ipad-13/*.png` work if you add them |
| Category | Music & Audio |
| Contact email | `contact@shaunniekins.com` |
| Website | `https://suga.shaunniekins.com` |

**App content** (Policy → App content)

| Form | Answer |
|---|---|
| Privacy policy | `https://suga.shaunniekins.com/privacy` |
| Ads | No, the app has no ads |
| App access | All functionality is available without special access (no login) |
| Content rating (IARC) | No violence, sexual content, language, gambling or user interaction; expect *Everyone / PEGI 3* |
| Target audience | 13 and over (choosing under-13 adds Families policy requirements) |
| Data safety | **No data collected, no data shared.** The microphone is used on-device only and audio never leaves the device, which Google doesn't count as collection. No encryption-in-transit question applies (nothing is transmitted). Data deletion: not applicable (nothing collected). |
| Government / financial / health apps | Not applicable |

**Release notes** for 1.0.0: `First release.`

## App Store Connect

**App information**

| Field | Value |
|---|---|
| Name | from README (`Suga: Music Visualizer`) |
| Subtitle | from README |
| Category | Music (primary), Entertainment (secondary) |
| Privacy Policy URL | `https://suga.shaunniekins.com/privacy` |
| Content rights | Contains no third-party content |
| Age rating | Answer *None* to every content question → **4+** |

**Version page**

| Field | Value |
|---|---|
| Promotional text | from README |
| Description | from README (with *Reduce Motion*) |
| Keywords | from README |
| Support URL | `https://suga.shaunniekins.com/#support` |
| Marketing URL | `https://suga.shaunniekins.com` |
| iPhone screenshots | `app-store/iphone-6.9/*.png` |
| iPad screenshots | `app-store/ipad-13/*.png` |
| Copyright | `2026 shaunniekins` |
| App icon | from the build (`ios/Runner/Assets.xcassets`, 1024×1024) |

**App Privacy:** *Data Not Collected.* Audio is processed on the device and
never leaves it, so nothing is collected under Apple's definition.

**App Review notes** (App Review Information → Notes):

```
Suga is a music visualizer. Tap the round logo, allow microphone access, and play music near the device (or speak or clap) — the screen reacts to the sound. No account or login is needed. Audio is processed on the device in real time and is never recorded, stored or transmitted.
```

**Export compliance:** the app uses no encryption beyond what iOS provides.
`ITSAppUsesNonExemptEncryption = NO` is already in `ios/Runner/Info.plist`, so
App Store Connect won't ask on each upload.

## When something changes

- New permission, SDK, analytics or network feature → update
  [`website/privacy.html`](../website/privacy.html), the Play **Data safety**
  form and Apple's **App Privacy** answers *before* releasing.
- New or renamed mode, or a changed feature claim → update the README listing
  text, the website, and rerun `./tool/store/generate.sh`.
