# 🌟 GlowSun - Professional Skincare Tracking App

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-9.0+-orange.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)](https://flutter.dev)

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
<div align="center">
  <img src="screenshots/homepage.jpg" width="200" alt="Home Page">
  <img src="screenshots/homepage2.jpg" width="200" alt="Home Page 2">
</div>
- Modern and clean design
- Daily routine cards
- Quick access buttons
- Progress tracking

### Login & Authentication
<div align="center">
  <img src="screenshots/login.jpg" width="200" alt="Login Page">
  <img src="screenshots/create.jpg" width="200" alt="Create Account">
</div>

### Profile Page
<div align="center">
  <img src="screenshots/profilepage.jpg" width="200" alt="Profile Page">
  <img src="screenshots/profilepae2.jpg" width="200" alt="Profile Page 2">
</div>
- Customizable profile
- Skin type and problems
- Direct editing capabilities

### Statistics & Analytics
<div align="center">
  <img src="screenshots/statistics.jpg" width="200" alt="Statistics">
  <img src="screenshots/statisitcs2.jpg" width="200" alt="Statistics 2">
</div>
- Detailed charts and graphs
- Analysis reports
- Progress tracking

### Calendar View
<div align="center">
  <img src="screenshots/calendar.jpg" width="200" alt="Calendar">
</div>
- Monthly view with entries
- Detailed daily view
- Filtering options

### Habit Tracking
<div align="center">
  <img src="screenshots/habits.jpg" width="200" alt="Habits">
  <img src="screenshots/habits2.jpg" width="200" alt="Habits 2">
  <img src="screenshots/habits3.jpg" width="200" alt="Habits 3">
</div>
- Daily/weekly/monthly habits
- Progress tracking with animations
- Confetti celebrations

### Product Search
<div align="center">
  <img src="screenshots/productsearch.jpg" width="200" alt="Product Search">
</div>
- Search by name, brand, or ingredient
- Barcode scanning support
- Product recommendations

### Entry Management
<div align="center">
  <img src="screenshots/entrypage.jpg" width="200" alt="Entry Page">
  <img src="screenshots/entrypage2.jpg" width="200" alt="Entry Page 2">
  <img src="screenshots/allentires.jpg" width="200" alt="All Entries">
</div>

### Skin Type Quiz
<div align="center">
  <img src="screenshots/quiz.jpg" width="200" alt="Skin Quiz">
</div>
- 12 questions to discover your skin type
- 95% accuracy

### Skincare Information
<div align="center">
  <img src="screenshots/scincreinformation.jpg" width="200" alt="Skincare Info">
  <img src="screenshots/scincareinformation2.jpg" width="200" alt="Skincare Info 2">
  <img src="screenshots/scincareinformation3.jpg" width="200" alt="Skincare Info 3">
</div>
- Detailed ingredient information
- Usage recommendations
- Compatibility checks

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
- Copy `lib/firebase_options.example.dart` to `lib/firebase_options.dart`
- Replace placeholder values in `firebase_options.dart` with your Firebase project credentials
- Add `google-services.json` to `android/app/` folder (if using Android)
- Add `GoogleService-Info.plist` to `ios/Runner/` folder (if using iOS)

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





## 📞 Contact

For questions about this project:
- Email: roj.gulerr@gmail.com
- GitHub Issues: [Issues](https://github.com/yourusername/glowsun/issues)

---

⭐ If you liked this project, don't forget to give it a star!
