#!/usr/bin/env python3
"""
Cilt Bakım Uygulaması - Icon Generator
Bu script, basit geometrik şekiller kullanarak app icon oluşturur.
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_app_icon(size, filename):
    """App icon oluştur"""
    # Yeni resim oluştur
    img = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    draw = ImageDraw.Draw(img)
    
    # Gradient arka plan simülasyonu (basit)
    center = size // 2
    
    # Dış halka (sarı)
    draw.ellipse([0, 0, size-1, size-1], fill=(255, 217, 61, 255))
    
    # İç halka (pembe)
    margin = size // 8
    draw.ellipse([margin, margin, size-margin-1, size-margin-1], fill=(255, 107, 157, 255))
    
    # Merkezi sembol (beyaz yüz silüeti)
    face_size = size // 3
    face_x = center - face_size // 2
    face_y = center - face_size // 2
    
    # Yüz şekli (oval)
    draw.ellipse([face_x, face_y, face_x + face_size, face_y + face_size], 
                fill=(255, 255, 255, 255))
    
    # Gözler
    eye_size = face_size // 8
    left_eye_x = center - face_size // 4
    right_eye_x = center + face_size // 4
    eye_y = center - face_size // 6
    
    draw.ellipse([left_eye_x - eye_size, eye_y - eye_size, 
                 left_eye_x + eye_size, eye_y + eye_size], 
                fill=(255, 107, 157, 255))
    draw.ellipse([right_eye_x - eye_size, eye_y - eye_size, 
                 right_eye_x + eye_size, eye_y + eye_size], 
                fill=(255, 107, 157, 255))
    
    # Gülümseme
    smile_y = center + face_size // 6
    draw.arc([center - face_size // 3, smile_y - face_size // 8,
              center + face_size // 3, smile_y + face_size // 8],
             0, 180, fill=(255, 107, 157, 255), width=2)
    
    # Kaydet
    img.save(filename, 'PNG')
    print(f"✅ Icon oluşturuldu: {filename} ({size}x{size})")

def main():
    """Ana fonksiyon"""
    print("🎨 Rojda Skincare App Icon Generator")
    print("=" * 40)
    
    # Gerekli boyutlar
    sizes = [
        (48, "android/app/src/main/res/mipmap-mdpi/ic_launcher.png"),
        (72, "android/app/src/main/res/mipmap-hdpi/ic_launcher.png"),
        (96, "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png"),
        (144, "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png"),
        (192, "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"),
        (192, "web/icons/Icon-192.png"),
        (512, "web/icons/Icon-512.png"),
        (192, "web/icons/Icon-maskable-192.png"),
        (512, "web/icons/Icon-maskable-512.png"),
        (32, "web/favicon.png"),
    ]
    
    # Her boyut için icon oluştur
    for size, path in sizes:
        try:
            # Klasör oluştur
            os.makedirs(os.path.dirname(path), exist_ok=True)
            create_app_icon(size, path)
        except Exception as e:
            print(f"❌ Hata: {path} - {e}")
    
    print("\n🎉 Tüm iconlar oluşturuldu!")
    print("📱 Android ve Web iconları hazır")

if __name__ == "__main__":
    main()
