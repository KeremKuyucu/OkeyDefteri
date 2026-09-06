import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Keystore configuration (Supports Vault path, relative path, and legacy path)
val possibleKeyFiles = listOf(
    rootProject.projectDir.parentFile.parentFile.resolve("imza-bilgileri/key.properties"),
    file("C:\\Users\\Kerem\\Projects\\imza-bilgileri\\key.properties")
)
val keystorePropertiesFile = possibleKeyFiles.firstOrNull { it.exists() } ?: file("C:\\Users\\Kerem\\Projects\\imza-bilgileri\\key.properties")
val keystoreProperties = Properties()
var hasValidKeystore = false

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    hasValidKeystore = keystoreProperties.getProperty("storeFile") != null && 
                       keystoreProperties.getProperty("storeFile") != ""
}

android {
    namespace = "com.keremkuyucu.okey_defteri"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
    // AAB derlerken çakışma yaptığı için splits bloğu yorum satırına alındı
    // splits {
    //     abi {
    //         isEnable = true // ABI başına ayrı APK oluştur
    //         reset()     // Varsayılan ayarları sıfırla
    //         include("armeabi-v7a", "arm64-v8a", "x86_64") // Desteklenecek mimariler
    //         isUniversalApk = true // Tek bir evrensel APK oluşturma
    //     }
    // }
    signingConfigs {
        if (hasValidKeystore) {
            create("release") {
                val configuredStore = keystoreProperties.getProperty("storeFile")
                val storeF = file(configuredStore)
                storeFile = if (storeF.exists()) storeF else file(keystorePropertiesFile.parentFile, "ksk.jks")
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.keremkuyucu.okey_defteri"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            if (hasValidKeystore) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
