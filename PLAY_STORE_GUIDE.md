# 📱 Play Store'a Yükleme Rehberi

Bu rehber, GlowSun uygulamasını Google Play Store'a yüklemek için gereken adımları içerir.

## ✅ Ön Hazırlık

### 1. Google Play Console Hesabı
- [Google Play Console](https://play.google.com/console) hesabı oluştur
- Tek seferlik $25 kayıt ücreti öde
- Geliştirici hesabını doğrula

### 2. Application ID Değiştirme
`android/app/build.gradle.kts` dosyasında `applicationId` değerini kendi benzersiz ID'n ile değiştir:
```kotlin
applicationId = "com.rojda.glowsun"  // Kendi ID'ni kullan
```

**Önemli:** Application ID bir kez yayınlandıktan sonra değiştirilemez!

## 🔐 Keystore Oluşturma

Play Store'a yüklemek için bir keystore dosyası oluşturman gerekiyor.

### Adım 1: Keystore Oluştur
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Önemli Bilgiler:**
- Keystore dosyasını ve şifresini GÜVENLİ bir yerde sakla
- Bu dosyayı kaybedersen, uygulama güncellemeleri yapamazsın!
- Şifreyi unutursan, uygulamayı güncelleyemezsin!

### Adım 2: key.properties Dosyası Oluştur
`android/key.properties` dosyası oluştur:
```properties
storePassword=<keystore-şifresi>
keyPassword=<key-şifresi>
keyAlias=upload
storeFile=<keystore-dosya-yolu>
```

**Örnek:**
```properties
storePassword=mySecurePassword123
keyPassword=mySecurePassword123
keyAlias=upload
storeFile=C:/Users/Rojin/upload-keystore.jks
```

### Adım 3: build.gradle.kts'i Güncelle
`android/app/build.gradle.kts` dosyasına şunu ekle (dosyanın başına):

```kotlin
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Ve `android` bloğuna şunu ekle:

```kotlin
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

Ve `buildTypes` içindeki `release` bloğunu güncelle:

```kotlin
release {
    signingConfig = signingConfigs.release
    isMinifyEnabled = false
    isShrinkResources = false
    proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
}
```

## 📦 APK/AAB Oluşturma

### App Bundle (Önerilen - Play Store için)
```bash
flutter build appbundle --release
```
Dosya: `build/app/outputs/bundle/release/app-release.aab`

### APK (Alternatif)
```bash
flutter build apk --release
```
Dosya: `build/app/outputs/flutter-apk/app-release.apk`

## 🚀 Play Store'a Yükleme

### 1. Play Console'a Git
- [Google Play Console](https://play.google.com/console) → "Create app"

### 2. Uygulama Bilgileri
- **App name:** GlowSun
- **Default language:** English
- **App or game:** App
- **Free or paid:** Free
- **Privacy Policy:** Gerekli (Firebase kullanıyorsan)

### 3. Store Listing
- **App icon:** 512x512 PNG (yüksek kalite)
- **Feature graphic:** 1024x500 PNG
- **Screenshots:** En az 2 adet (telefon ekran boyutları)
- **Short description:** 80 karakter max
- **Full description:** 4000 karakter max
- **Privacy Policy URL:** (Firebase kullanıyorsan gerekli)

### 4. Content Rating
- Uygulama içeriğini değerlendir
- Yaş sınırı belirle

### 5. App Access
- Uygulama erişim bilgilerini doldur

### 6. Pricing & Distribution
- Ücretsiz mi, ücretli mi?
- Hangi ülkelerde yayınlanacak?

### 7. Production Release
- Oluşturduğun `.aab` dosyasını yükle
- Release notes ekle
- Yayınla!

## 📋 Gerekli Dosyalar

### 1. App Icon
- **Boyut:** 512x512 PNG
- **Format:** PNG (transparent background)
- **Konum:** `android/app/src/main/res/mipmap-*/ic_launcher.png`

### 2. Feature Graphic
- **Boyut:** 1024x500 PNG
- **Format:** PNG
- Play Store'da üstte görünen büyük resim

### 3. Screenshots
- **Minimum:** 2 adet
- **Önerilen:** 4-8 adet
- **Boyutlar:**
  - Phone: 16:9 veya 9:16
  - Tablet: 16:9 veya 9:16

### 4. Privacy Policy (Gerekli)
Firebase kullanıyorsan Privacy Policy gerekli. Şunları içermeli:
- Hangi veriler toplanıyor?
- Veriler nasıl kullanılıyor?
- Veriler kimlerle paylaşılıyor?
- Kullanıcı hakları

**Privacy Policy oluşturma:**
- [Privacy Policy Generator](https://www.privacypolicygenerator.info/)
- Veya kendi web sitende yayınla

## ⚠️ Önemli Notlar

1. **Application ID:** Bir kez yayınlandıktan sonra değiştirilemez!
2. **Keystore:** Dosyayı ve şifreyi GÜVENLİ sakla!
3. **Version Code:** Her yeni sürümde artırılmalı (`pubspec.yaml` → `version: 1.0.0+1`)
4. **Testing:** Önce Internal Testing'de test et
5. **Review Süresi:** İlk yayın 1-7 gün sürebilir

## 🔄 Güncelleme Yapma

1. `pubspec.yaml`'da version'ı artır:
   ```yaml
   version: 1.0.1+2  # +2 = versionCode
   ```

2. Yeni AAB oluştur:
   ```bash
   flutter build appbundle --release
   ```

3. Play Console'da yeni release oluştur ve yükle

## 📞 Yardım

Sorun yaşarsan:
- [Flutter Deployment Docs](https://docs.flutter.dev/deployment/android)
- [Play Console Help](https://support.google.com/googleplay/android-developer)

---

**Başarılar! 🎉**

