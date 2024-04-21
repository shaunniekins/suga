# Suga - A new Flutter Project

## Description

Suga is a visually engaging Flutter app that utilizes your device's microphone to capture ambient noise levels and dynamically alter the app's background color based on the intensity of the sound. It offers a variety of color modes to personalize the experience and create a mesmerizing visual response to sound.

## Features

- **Real-time Noise Level Detection:** Leverages the device's microphone to capture noise levels.
- **Dynamic Color Change:** The app's background color seamlessly adapts to the detected noise level.
- **Multiple Color Modes:** Choose from various color modes to customize the visual experience:
  - Assorted: Randomly generates color combinations based on the noise level.
  - Black and White: Switches between black and white backgrounds for a minimalist aesthetic.
  - Gradient: Creates a smooth color gradient that transitions from blue to red as the noise level increases.
  - Tiles: Fills the screen with colored tiles that change color individually based on the noise level.
  - Level: Displays a colored bar that grows in height as the noise level rises.
- **Easy Color Mode Switching:** Effortlessly switch between color modes using the floating action button in the bottom right corner.

## Usage

### 1. Grant Microphone Permission (if required):

Upon initial launch, the app might request permission to access the microphone. Grant permission to allow noise level detection.

### 2. Experience the Visual Response:

Make noise in your environment and observe the app's background color or visual elements dynamically changing in response to the captured noise level.

### 3. Explore Color Modes:

Tap the floating action button (FAB) in the bottom right corner to cycle through the available color modes (Assorted, Black and White, Gradient, Tiles, Level) and find the one that best suits your preference.

## Changes Made in Flutter configuration files:

### 1. android/build.gradle

Insertion of the following code:

```
gradle
buildscript {
   ext.kotlin_version = '1.9.23' // Changing to the latest version
   repositories {
       google()
       jcenter()
   }
   dependencies {
       classpath 'com.android.tools.build:gradle:7.4.2'
       classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
   }
}
```

### 2. android/settings.gradle

Change the following line:

```
id "org.jetbrains.kotlin.android" version "1.9.23"
```

to match the ext.kotlin_version change.

```
id "org.jetbrains.kotlin.android" version "$kotlin_version"
```

### 3. gradle/wrapper/gradle-wrapper.properties

Update the distributionUrl property to the latest Gradle version:

```
distributionUrl=https\://services.gradle.org/distributions/gradle-7.6.4-all.zip
```

Note: The changes mentioned in step 3 are not necessarily relevant, but it's a good practice to keep your Gradle version up-to-date.
