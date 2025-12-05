# 🌟 GlowSun - Professional Skincare Tracking App

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-9.0+-orange.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)](https://flutter.dev)

**English | [Türkçe](#türkçe)**

GlowSun is a modern Flutter application designed for personalized skincare routines and product tracking. Built with professional-grade architecture, it offers comprehensive skincare management with advanced features like habit tracking, detailed analytics, and Firebase integration.


## ✨ Features

### 🏠 Home Page
- Daily skincare routines
- Habit tracking with progress bars
- Quick access buttons
- Daily reminders and notifications

### 👤 Profile Management
- Profile photo upload
- Personal information (name, email)
- Skin type selection
- Skin problems identification
- Persistent data storage

### 📊 Statistics & Analytics
- Skin condition charts (FL Chart)
- Product usage analysis
- Monthly/weekly reports
- Progress tracking with visual graphs

### 📅 Calendar View
- Daily skincare entries
- Routine tracking
- Historical data
- Date-based filtering

### 🎯 Habit Tracking
- Daily/weekly/monthly habits
- Progress tracking with animations
- Confetti celebrations
- Haptic feedback
- Automatic daily reset

### 📚 Skincare Information
- Detailed ingredient information
- Usage recommendations
- Compatibility checks
- Benefits and effects

### 🔐 Authentication
- Firebase Authentication
- Local authentication fallback
- Secure data encryption
- User session management

### 🛍️ Product Search & API
- **SkincareAPI Integration** - Real product database
- Product search by name, brand, or ingredient
- Barcode scanning support
- Product recommendations
- Fallback to mock data when API unavailable

## 🛠️ Tech Stack

### Frontend
- **Flutter 3.0+** - Cross-platform UI framework
- **Dart** - Programming language
- **Material Design 3** - UI/UX design system
- **Google Fonts (Poppins)** - Typography

### Backend & Services
- **Firebase Authentication** - User management
- **Cloud Firestore** - Real-time database
- **Firebase Storage** - File storage
- **Firebase Analytics** - Usage analytics
- **Firebase Messaging** - Push notifications
- **SkincareAPI** - Real skincare product data (2000+ products)

### Local Storage
- **Hive** - NoSQL local database
- **SharedPreferences** - Key-value storage

### Core Libraries
- **Riverpod** - State management
- **FL Chart** - Data visualization
- **Image Picker** - Photo selection
- **Table Calendar** - Calendar widget
- **Confetti** - Celebration animations
- **Crypto** - Data encryption
- **HTTP** - API communication

### Development Tools
- **Build Runner** - Code generation
- **JSON Serializable** - JSON serialization
- **Hive Generator** - Hive adapters
- **Flutter Lints** - Code analysis

## 📱 Screenshots

### Home Page
- Modern and clean design
- Daily routine cards
- Quick access buttons
- Progress tracking

### Profile Page
- Customizable profile
- Skin type and problems
- Direct editing capabilities

### Statistics
- Detailed charts and graphs
- Analysis reports
- Progress tracking

### Calendar
- Monthly view with entries
- Detailed daily view
- Filtering options

## 🚀 Installation

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/glowsun.git
cd glowsun
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Firebase configuration:**
- Create a new project in Firebase Console
- Add `google-services.json` to `android/app/` folder
- Add `GoogleService-Info.plist` to `ios/Runner/` folder

4. **Run the application:**
```bash
flutter run
```

## 📦 Build

### Android APK
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🔧 Configuration

### Firebase
- Authentication: Email/Password
- Firestore: Data storage
- Analytics: Usage analytics
- Storage: Image storage

### Local Storage
- Hive: Offline data storage
- SharedPreferences: User preferences

## 📊 Data Structure

### User Profile
```dart
{
  "name": "User Name",
  "email": "email@example.com",
  "skinType": "Combination",
  "skinProblems": ["Acne", "Blackheads"],
  "profileImage": "image_url"
}
```

### Skincare Entry
```dart
{
  "date": "2024-01-01",
  "products": ["Serum", "Moisturizer"],
  "skinCondition": 4,
  "notes": "Daily notes",
  "images": ["image1.jpg", "image2.jpg"]
}
```

## 🎨 Design System

### Colors
- **Primary**: Pink (#FF6B9D)
- **Secondary**: Brown (#8B4513)
- **Background**: Light Pink (#FFF5F8)
- **Accent**: Yellow (#FFD93D)

### Typography
- **Font**: Google Fonts Poppins
- **Headings**: 20-24px, Bold
- **Body**: 14-16px, Medium
- **Caption**: 12px, Regular

## 🔐 Security

- Firebase Authentication
- Data encryption
- Secure API calls
- User privacy protection

## 📈 Performance

- Lazy loading
- Image optimization
- Efficient state management
- Memory management

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the `LICENSE` file for details.

## 👨‍💻 Developer

**Rojin Güler**
- GitHub: [@rojinguler](https://github.com/rojinguler)
- LinkedIn: [Rojin Güler](https://linkedin.com/in/rojinguler)

## 📞 Contact

For questions about this project:
- Email: roj.gulerr@gmail.com
- GitHub Issues: [Issues](https://github.com/yourusername/glowsun/issues)

---

⭐ If you liked this project, don't forget to give it a star!

---

# Türkçe

GlowSun, kişiselleştirilmiş cilt bakım rutinleri ve ürün takibi için tasarlanmış modern bir Flutter uygulamasıdır. Profesyonel düzeyde mimari ile geliştirilmiş olup, alışkanlık takibi, detaylı analitik ve Firebase entegrasyonu gibi gelişmiş özellikler sunar.

## ✨ Özellikler

### 🏠 Ana Sayfa
- Günlük cilt bakım rutinleri
- İlerleme çubukları ile alışkanlık takibi
- Hızlı erişim butonları
- Günlük hatırlatmalar ve bildirimler

### 👤 Profil Yönetimi
- Profil fotoğrafı yükleme
- Kişisel bilgiler (isim, email)
- Cilt tipi seçimi
- Cilt sorunları belirleme
- Kalıcı veri saklama

### 📊 İstatistikler ve Analitik
- Cilt durumu grafikleri (FL Chart)
- Ürün kullanım analizi
- Aylık/haftalık raporlar
- Görsel grafiklerle ilerleme takibi

### 📅 Takvim Görünümü
- Günlük cilt bakım girişleri
- Rutin takibi
- Geçmiş veriler
- Tarih bazlı filtreleme

### 🎯 Alışkanlık Takibi
- Günlük/haftalık/aylık alışkanlıklar
- Animasyonlarla ilerleme takibi
- Konfeti kutlamaları
- Haptic feedback
- Otomatik günlük sıfırlama

### 📚 Cilt Bakım Bilgileri
- Detaylı içerik bilgileri
- Kullanım önerileri
- Uyumluluk kontrolleri
- Faydalar ve etkiler

### 🔐 Kimlik Doğrulama
- Firebase Authentication
- Yerel kimlik doğrulama yedeklemesi
- Güvenli veri şifreleme
- Kullanıcı oturum yönetimi

### 🛍️ Ürün Arama ve API
- **SkincareAPI Entegrasyonu** - Gerçek ürün veritabanı
- İsim, marka veya içerik bazında ürün arama
- Barkod tarama desteği
- Ürün önerileri
- API mevcut olmadığında mock veri yedeklemesi

## 🛠️ Teknoloji Yığını

### Frontend
- **Flutter 3.0+** - Çapraz platform UI framework'ü
- **Dart** - Programlama dili
- **Material Design 3** - UI/UX tasarım sistemi
- **Google Fonts (Poppins)** - Tipografi

### Backend ve Servisler
- **Firebase Authentication** - Kullanıcı yönetimi
- **Cloud Firestore** - Gerçek zamanlı veritabanı
- **Firebase Storage** - Dosya depolama
- **Firebase Analytics** - Kullanım analizi
- **Firebase Messaging** - Push bildirimleri
- **SkincareAPI** - Gerçek cilt bakım ürün verileri (2000+ ürün)

### Yerel Depolama
- **Hive** - NoSQL yerel veritabanı
- **SharedPreferences** - Anahtar-değer depolama

### Temel Kütüphaneler
- **Riverpod** - Durum yönetimi
- **FL Chart** - Veri görselleştirme
- **Image Picker** - Fotoğraf seçimi
- **Table Calendar** - Takvim widget'ı
- **Confetti** - Kutlama animasyonları
- **Crypto** - Veri şifreleme
- **HTTP** - API iletişimi

### Geliştirme Araçları
- **Build Runner** - Kod üretimi
- **JSON Serializable** - JSON serileştirme
- **Hive Generator** - Hive adaptörleri
- **Flutter Lints** - Kod analizi

## 📱 Ekran Görüntüleri

### Ana Sayfa
- Modern ve temiz tasarım
- Günlük rutin kartları
- Hızlı erişim butonları
- İlerleme takibi

### Profil Sayfası
- Özelleştirilebilir profil
- Cilt tipi ve sorunları
- Doğrudan düzenleme özellikleri

### İstatistikler
- Detaylı grafikler ve çizelgeler
- Analiz raporları
- İlerleme takibi

### Takvim
- Girişlerle aylık görünüm
- Detaylı günlük görünüm
- Filtreleme seçenekleri

## 🚀 Kurulum

1. **Repository'yi klonlayın:**
```bash
git clone https://github.com/yourusername/glowsun.git
cd glowsun
```

2. **Bağımlılıkları yükleyin:**
```bash
flutter pub get
```

3. **Firebase yapılandırması:**
- Firebase Console'da yeni proje oluşturun
- `google-services.json` dosyasını `android/app/` klasörüne ekleyin
- `GoogleService-Info.plist` dosyasını `ios/Runner/` klasörüne ekleyin

4. **Uygulamayı çalıştırın:**
```bash
flutter run
```

## 📦 Derleme

### Android APK
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🔧 Yapılandırma

### Firebase
- Authentication: Email/Şifre
- Firestore: Veri saklama
- Analytics: Kullanım analizi
- Storage: Resim saklama

### Yerel Depolama
- Hive: Çevrimdışı veri saklama
- SharedPreferences: Kullanıcı tercihleri

## 📊 Veri Yapısı

### Kullanıcı Profili
```dart
{
  "name": "Kullanıcı Adı",
  "email": "email@example.com",
  "skinType": "Karma",
  "skinProblems": ["Sivilce", "Siyah Nokta"],
  "profileImage": "image_url"
}
```

### Cilt Bakım Girişi
```dart
{
  "date": "2024-01-01",
  "products": ["Serum", "Nemlendirici"],
  "skinCondition": 4,
  "notes": "Günlük notlar",
  "images": ["image1.jpg", "image2.jpg"]
}
```

## 🎨 Tasarım Sistemi

### Renkler
- **Primary**: Pembe (#FF6B9D)
- **Secondary**: Kahverengi (#8B4513)
- **Background**: Açık Pembe (#FFF5F8)
- **Accent**: Sarı (#FFD93D)

### Tipografi
- **Font**: Google Fonts Poppins
- **Başlıklar**: 20-24px, Kalın
- **Gövde**: 14-16px, Orta
- **Alt Yazı**: 12px, Normal

## 🔐 Güvenlik

- Firebase Authentication
- Veri şifreleme
- Güvenli API çağrıları
- Kullanıcı gizliliği koruması

## 📈 Performans

- Lazy loading
- Resim optimizasyonu
- Verimli durum yönetimi
- Bellek yönetimi

## 🤝 Katkıda Bulunma

1. Repository'yi fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit yapın (`git commit -m 'Add amazing feature'`)
4. Branch'e push yapın (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır - detaylar için `LICENSE` dosyasına bakın.

## 👨‍💻 Geliştirici

**Rojin Güler**
- GitHub: [@rojinguler](https://github.com/rojinguler)
- LinkedIn: [Rojin Güler](https://linkedin.com/in/rojinguler)

## 📞 İletişim

Bu proje hakkında sorularınız için:
- Email: roj.gulerr@gmail.com
- GitHub Issues: [Issues](https://github.com/yourusername/glowsun/issues)

---

⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!