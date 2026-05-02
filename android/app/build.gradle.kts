// android/app/build.gradle.kts

import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ── Signing: load key.properties if it exists ─────────────────────────────────
// Locally: create android/key.properties with your keystore data (don't commit it!)
// Codemagic: key.properties is generated automatically during CI builds.
//            As a fallback, we also read CM_* environment variables directly.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    }
}

android {
    // TODO: Change namespace to your own App Bundle ID:
    namespace = "com.scalebook.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Change applicationId to your own App Bundle ID:
        applicationId = "com.scalebook.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ── Signing config ────────────────────────────────────────────────────────
    // Hybrid approach:
    //   1. Try key.properties first (local development)
    //   2. Fall back to Codemagic environment variables (CI/CD)
    //   3. If neither is available and we're NOT in CI, release falls back to
    //      debug signing so local `flutter run --release` still works.
    //   4. If we ARE in CI and signing is not configured, throw an error
    //      to prevent silent debug-signed builds that Google Play rejects.
    signingConfigs {
        create("release") {
            val kStoreFile = keystoreProperties["storeFile"] as? String
                ?: System.getenv("CM_KEYSTORE_PATH")
            val kStorePassword = keystoreProperties["storePassword"] as? String
                ?: System.getenv("CM_KEYSTORE_PASSWORD")
            val kKeyAlias = keystoreProperties["keyAlias"] as? String
                ?: System.getenv("CM_KEY_ALIAS")
            val kKeyPassword = keystoreProperties["keyPassword"] as? String
                ?: System.getenv("CM_KEY_PASSWORD")

            if (kStoreFile != null && kStorePassword != null
                && kKeyAlias != null && kKeyPassword != null
            ) {
                storeFile = file(kStoreFile)
                storePassword = kStorePassword
                keyAlias = kKeyAlias
                keyPassword = kKeyPassword
            }
        }
    }

    buildTypes {
        getByName("debug") {
            // Debug build – default settings, signed with debug keys automatically.
        }
        getByName("release") {
            val releaseConfig = signingConfigs.getByName("release")
            val isCI = System.getenv("CI") == "true"

            signingConfig = if (releaseConfig.storeFile != null) {
                // Signing properly configured (key.properties or CM_* env vars)
                releaseConfig
            } else if (isCI) {
                // In CI but signing is not configured – fail fast instead of
                // silently producing a debug-signed build that Google Play rejects.
                throw GradleException(
                    "Release signing not configured in CI! " +
                    "Check CM_KEYSTORE_PATH, CM_KEYSTORE_PASSWORD, CM_KEY_ALIAS, " +
                    "and CM_KEY_PASSWORD environment variables in Codemagic."
                )
            } else {
                // Local development without key.properties –
                // fallback to debug keys so `flutter run --release` still works.
                signingConfigs.getByName("debug")
            }

            // Optional: enable minification and shrink for release
            // isMinifyEnabled = true
            // isShrinkResources = true
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
        }
    }
}

flutter {
    source = "../.."
}
