# example_flutter_gemini

A Flutter example app demonstrating usage of the `flutter_gemini` package with several demo screens.

## Ringkasan

Aplikasi ini berisi beberapa contoh penggunaan API Gemini (melalui package `flutter_gemini`) termasuk:

- Stream & Future: memanggil model baik sebagai stream (partial updates) maupun future (single response).
- Multi-turn Chat: contoh percakapan multi-turn dengan log percakapan menggunakan stream.
- Text & Image: mengirim prompt gabungan teks + gambar (menggunakan `image_picker`).
- Utility APIs: fungsi pembantu seperti menghitung token, melihat daftar model, dan mengambil info model.
- Embeddings: membuat embedding untuk teks (single & batch).
- Advanced Usage: contoh konfigurasi generation (temperature, max tokens) dan pengaturan safety.
- Legacy APIs: contoh pemanggilan fitur lama (completions-style) untuk referensi.

## Struktur penting (lib/)

- `lib/main.dart`
  - Inisialisasi `Gemini` dengan `apiKey` (nilai demo di file). Menjalankan aplikasi.
- `lib/home_screen.dart`
  - Daftar navigasi ke semua demo section.
- `lib/sections/chat_stream_section.dart`
  - Demo memanggil `gemini.promptStream` (streaming) dan `gemini.prompt` (future) untuk menampilkan output incremental atau final.
- `lib/sections/chat_section.dart`
  - Contoh UI multi-turn chat. Menyimpan history `Content` dan menampilkan balasan model saat diterima via `streamChat`.
- `lib/sections/text_and_image_section.dart`
  - Menggunakan `image_picker` untuk memilih gambar dari galeri, lalu mengirim gambar sebagai inline part bersama teks.
- `lib/sections/utility_section.dart`
  - Tombol untuk `listModels()`, `info()` (contoh menggunakan model `gemini-pro`), dan `countTokens()`.
- `lib/sections/embeddings_section.dart`
  - `batchEmbedContents` untuk membuat embedding single atau batch (split berdasarkan koma pada demo).
- `lib/sections/advanced_section.dart`
  - Demo `promptStream` dengan `GenerationConfig` dan `SafetySetting` (contoh temperature & max tokens slider).
- `lib/sections/legacy_section.dart`
  - Contoh panggilan lama (completions-style): stream, text-only, text+image.

## Dependency utama

- flutter_gemini
- flutter_markdown_plus (render markdown dari model)
- image_picker (pilih gambar dari galeri)

Periksa `pubspec.yaml` untuk versi lengkap.

## Setup & Menjalankan

1. Pastikan Anda memiliki Flutter SDK yang sesuai (stable channel direkomendasikan).
2. Pasang dependencies:

```powershell
flutter pub get
```

3. Set API key:

- Saat ini `lib/main.dart` berisi konstanta `apiKey` dengan nilai demo. Ganti nilai `apiKey` tersebut dengan kunci API Anda sebelum menjalankan.
- Alternatif: ubah implementasi untuk membaca dari variabel lingkungan atau konfigurasi rahasia.

4. Jalankan aplikasi pada emulator atau perangkat:

```powershell
flutter run -d <device_id>
```

## Izin untuk Image Picker

- Android: pastikan manifest memiliki izin yang diperlukan jika menargetkan Android API yang memerlukannya. Untuk versi Android yang lebih baru, `image_picker` biasanya menangani permission runtime, namun Anda mungkin perlu menambahkan di `android/app/src/main/AndroidManifest.xml` jika diperlukan:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

- iOS: tambahkan deskripsi di `ios/Runner/Info.plist`:

```text
<key>NSPhotoLibraryUsageDescription</key>
<string>App needs access to your photo library to attach images to prompts.</string>
```

## Catatan penggunaan & keamanan

- API key disimpan secara langsung di `lib/main.dart` untuk demo. Jangan commit kunci produksi ke repository publik. Gunakan variabel lingkungan atau secret manager untuk produksi.
- Fitur safety di `AdvancedSection` mencontohkan pengaturan `SafetySetting` — tetap lakukan review manual terhadap hasil model bila diperlukan.

## Troubleshooting

- Jika panggilan ke `flutter_gemini` gagal, periksa koneksi internet dan validitas API key.
- Jika `image_picker` tidak memunculkan galeri pada perangkat Android, pastikan permissions diberikan saat runtime dan konfigurasi file manifest/gradle sesuai.
- Lihat konsol `flutter run` untuk stack trace lengkap saat error.
