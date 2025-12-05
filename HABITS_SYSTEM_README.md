# Modern Flutter Alışkanlıklar Sistemi

Bu sistem, Flutter uygulamanızda alışkanlıklar takibi için modern bir state management çözümü sunar.

## 🚀 Özellikler

### 1. **Merkezi State Management**
- **Riverpod** kullanarak modern ve type-safe state management
- Hem Alışkanlıklar sayfası hem de Anasayfa aynı state'i kullanır
- Eş zamanlı progress bar güncellemeleri

### 2. **Günlük Sıfırlama**
- Her günün sonunda (tarih değişince) tüm günlük alışkanlıklar otomatik sıfırlanır
- Ertesi gün tekrar baştan başlar
- Haftalık ve aylık alışkanlıklar korunur

### 3. **Kalıcı Veri Saklama**
- **SharedPreferences** ile güvenli veri saklama
- Uygulama kapatılıp açılsa bile progress korunur
- JSON serialization ile verimli veri yönetimi

### 4. **Modern Flutter Best Practices**
- Riverpod annotation ile code generation
- Repository pattern ile veri erişimi
- Consumer widget'lar ile reactive UI
- Type-safe provider'lar

## 📁 Dosya Yapısı

```
lib/
├── models/
│   └── habit.dart                 # Alışkanlık model sınıfları
├── repositories/
│   └── habit_repository.dart      # Veri erişim katmanı
├── providers/
│   └── habit_providers.dart       # Riverpod provider'ları
├── screens/
│   ├── habits_page_new.dart       # Yeni alışkanlıklar sayfası
│   └── home_page_new.dart         # Yeni anasayfa
└── main.dart                      # Ana uygulama dosyası
```

## 🔧 Kurulum

### 1. Bağımlılıklar
```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  shared_preferences: ^2.2.2
  json_annotation: ^4.8.1

dev_dependencies:
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.6
  json_serializable: ^6.7.1
```

### 2. Code Generation
```bash
dart run build_runner build --delete-conflicting-outputs
```

## 📱 Kullanım

### Alışkanlık Ekleme
```dart
final newHabit = Habit(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  text: 'Yeni Alışkanlık',
  description: 'Açıklama',
  iconCodePoint: Icons.spa_outlined.codePoint,
  time: 'Günlük',
  frequency: 'daily',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

ref.read(dailyHabitsProvider.notifier).addHabit(newHabit);
```

### Alışkanlık Toggle
```dart
ref.read(dailyHabitsProvider.notifier).toggleHabit(habitId);
```

### Progress Takibi
```dart
Consumer(
  builder: (context, ref, child) {
    final progressAsync = ref.watch(dailyProgressProvider);
    
    return progressAsync.when(
      data: (progress) => Text('${(progress * 100).toInt()}%'),
      loading: () => CircularProgressIndicator(),
      error: (_, __) => Text('Hata'),
    );
  },
)
```

## 🎯 Özellikler Detayı

### 1. **Günlük Sıfırlama Sistemi**
- `HabitRepository.shouldResetDailyHabits()` ile tarih kontrolü
- `HabitRepository.resetDailyHabitsProgress()` ile sıfırlama
- Otomatik olarak her gün başında çalışır

### 2. **Progress Hesaplama**
- Tamamlanan alışkanlık sayısı / Toplam alışkanlık sayısı
- Gerçek zamanlı güncelleme
- Animasyonlu progress bar

### 3. **Veri Saklama**
- SharedPreferences ile güvenli saklama
- JSON formatında verimli depolama
- Tarih bazlı progress takibi

### 4. **UI Özellikleri**
- Modern ve responsive tasarım
- Haptic feedback
- Smooth animasyonlar
- Confetti efekti (tüm alışkanlıklar tamamlandığında)

## 🔄 State Management Flow

```
User Action → Provider Notifier → Repository → SharedPreferences
     ↓
UI Update ← Provider State ← Repository ← SharedPreferences
```

## 📊 Provider Yapısı

- `dailyHabitsProvider`: Günlük alışkanlıklar
- `weeklyHabitsProvider`: Haftalık alışkanlıklar  
- `monthlyHabitsProvider`: Aylık alışkanlıklar
- `dailyProgressProvider`: Günlük progress
- `weeklyProgressProvider`: Haftalık progress
- `monthlyProgressProvider`: Aylık progress

## 🎨 UI Bileşenleri

### Progress Bar
- Gradient renk geçişleri
- Animasyonlu ilerleme
- Yüzde göstergesi

### Alışkanlık Kartları
- İkon ve açıklama
- Tamamlanma durumu
- Tarih bilgisi
- Toggle ve silme butonları

### Tab Sistemi
- Günlük/Haftalık/Aylık sekmeler
- Smooth geçişler
- Haptic feedback

## 🚀 Performans

- Lazy loading ile verimli veri yükleme
- Provider caching ile hızlı erişim
- Minimal rebuild ile optimize edilmiş UI
- Memory efficient state management

## 🔧 Özelleştirme

### Yeni Alışkanlık Türü Ekleme
1. `Habit` modelinde frequency enum'ına ekle
2. Repository'de ilgili metodları ekle
3. Provider'da yeni provider oluştur
4. UI'da yeni tab ekle

### Tema Özelleştirme
- `AppColors` sınıfında renk değişiklikleri
- `GoogleFonts` ile font özelleştirme
- Gradient ve shadow ayarları

## 📝 Notlar

- Sistem otomatik olarak varsayılan alışkanlıklarla başlar
- Veriler SharedPreferences'ta güvenli şekilde saklanır
- Tarih değişiminde otomatik sıfırlama
- Hata durumlarında graceful fallback

## 🎉 Sonuç

Bu modern alışkanlıklar sistemi, Flutter best practice'lerini takip ederek:
- ✅ Merkezi state management
- ✅ Günlük otomatik sıfırlama  
- ✅ Kalıcı veri saklama
- ✅ Modern UI/UX
- ✅ Type-safe kod
- ✅ Performans optimizasyonu

sağlar ve kullanıcılarınızın alışkanlıklarını etkili bir şekilde takip etmelerine olanak tanır.
