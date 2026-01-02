import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")

}

// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
println("Looking for key.properties at: ${keystorePropertiesFile.absolutePath}")
println("key.properties exists: ${keystorePropertiesFile.exists()}")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    println("storeFile = ${keystoreProperties.getProperty("storeFile")}")
    println("keyAlias = ${keystoreProperties.getProperty("keyAlias")}")
    println("keyPassword = ${if (keystoreProperties.getProperty("keyPassword") != null) "***" else "null"}")
    println("storePassword = ${if (keystoreProperties.getProperty("storePassword") != null) "***" else "null"}")
}

android {
    namespace = "com.eathink.eathink_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.14206865"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        jvmToolchain(17)
    }

    defaultConfig {
        applicationId = "com.eathink.eathink_mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 21
        versionName = "2.0.1"
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties.getProperty("storeFile")
            val alias = keystoreProperties.getProperty("keyAlias")
            val keyPass = keystoreProperties.getProperty("keyPassword")
            val storePass = keystoreProperties.getProperty("storePassword")
            
            if (storeFilePath != null && alias != null && keyPass != null && storePass != null) {
                keyAlias = alias
                keyPassword = keyPass
                storeFile = file(storeFilePath)
                storePassword = storePass
            }
        }
    }

    buildTypes {
        release {
            val hasValidSigningConfig = keystoreProperties.getProperty("storeFile") != null &&
                keystoreProperties.getProperty("keyAlias") != null &&
                keystoreProperties.getProperty("keyPassword") != null &&
                keystoreProperties.getProperty("storePassword") != null

            signingConfig = if (hasValidSigningConfig) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // Disabled due to NDK strip symbols issue
            isMinifyEnabled = false
            isShrinkResources = false
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
