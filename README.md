# Point of Sales Mobile App

Project Tugas Akhir Point Of Sales Mobile.

## CARA MENJALANKAN PROGRAM

### Persiapan Awal

1. Pastikan Flutter SDK sudah terinstall di sistem Anda
2. Pastikan Android Studio atau VS Code sudah terinstall
3. Pastikan Android SDK dan tools sudah dikonfigurasi

### Langkah-langkah Menjalankan

#### 1. Install Dependencies

```bash
flutter pub get
```

#### 2. Persiapan Device/Emulator

**Jika menggunakan Emulator:**

- Buka Android Studio
- Jalankan emulator terlebih dahulu melalui AVD Manager
- Pastikan emulator sudah fully loaded

**Jika menggunakan Device fisik:**

- Aktifkan **Developer Options** di device Android
- Aktifkan **USB Debugging** dalam Developer Options
- Hubungkan device ke komputer via USB
- Pastikan device terdeteksi dengan perintah: `flutter devices`

#### 3. Menjalankan Aplikasi

```bash
flutter run
```

**Alternatif perintah:**

```bash
# Debug mode (default)
flutter run --debug

# Release mode
flutter run --release

# Profile mode
flutter run --profile
```

### Troubleshooting

| Masalah                 | Solusi                                     |
| ----------------------- | ------------------------------------------ |
| Dependency error        | `flutter clean` kemudian `flutter pub get` |
| Device tidak terdeteksi | Cek dengan `flutter devices`               |
| Flutter environment     | Periksa dengan `flutter doctor`            |

### Perintah Berguna

```bash
# Cek device yang tersedia
flutter devices

# Cek status environment Flutter
flutter doctor

# Membersihkan build cache
flutter clean

# Update dependencies
flutter pub upgrade
```

### Catatan Penting

- ✅ Pastikan koneksi internet stabil saat menjalankan `flutter pub get`
- ✅ Untuk device fisik, pastikan driver USB sudah terinstall
- ✅ Untuk iOS development, diperlukan Xcode (hanya di macOS)
- ✅ Pastikan Flutter dan Dart SDK sudah ditambahkan ke PATH

---

### Sistem Requirements

**Minimum:**

- Flutter SDK 3.0+
- Dart SDK 2.17+
- Android SDK API 21+ (Android 5.0)
- RAM 4GB (8GB recommended)

**Development Tools:**

- Android Studio / VS Code
- Android SDK Tools
- USB Driver (untuk device fisik)
