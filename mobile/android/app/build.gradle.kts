plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Applies google-services.json (see settings.gradle.kts for the version).
    id("com.google.gms.google-services")
}

android {
    namespace = "com.zaytona.mobile"
    // flutter_secure_storage 11.x's Android implementation requires compiling
    // against API 37+ (flutter.compileSdkVersion is still 36 on this Flutter
    // SDK) — see https://flutter.dev/to/review-gradle-config.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications' Android implementation needs
        // java.time APIs that aren't natively available below API 26.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.zaytona.mobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
