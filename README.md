# Data Mahasiswa - Universitas Negeri Ngawi

Aplikasi Flutter hasil implementasi desain `app.pdf`:
Splash, Create Data, Lihat Data. CRUD lokal tersimpan di perangkat.

## Struktur

- `lib/main.dart` - entry point dan routes `/`, `/list`, `/create`
- `lib/screens/splash_screen.dart` - layar splash 2 detik
- `lib/screens/create_data_screen.dart` - form NIM, Nama, Prodi, Dosen PA
- `lib/screens/list_data_screen.dart` - cari, urutkan, edit, hapus
- `lib/data/store.dart` - state + persistensi SharedPreferences
- `lib/models/mahasiswa.dart` - model data
- `lib/widgets/transitions.dart` - transisi fade+slide antar layar dan animasi entrance list

## Cara jalan

Flutter SDK 3.2+ harus terpasang.

```bash
cd data_mahasiswa_app
flutter pub get
flutter run
```

Untuk generate folder platform (android/ios) bila belum ada:

```bash
flutter create . --org com.unnga --project-name data_mahasiswa_app
flutter run
```

## Database: Cloud Firestore

Data tersimpan di Cloud Firestore (collection `mahasiswa`, dokumen ber-ID NIM),
diperbarui realtime lewat listener. Tiga data contoh terisi otomatis saat
koleksi masih kosong.

### Setup Firebase (sekali saja)

1. Buat proyek di console.firebase.google.com, misal `data-mahasiswa-unnga`.
2. Di Build > Firestore Database, buat database dan pilih mode.
3. Pasang FlutterFire CLI dan hubungkan aplikasi (mengganti
   `lib/firebase_options.dart` placeholder):
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=data-mahasiswa-unnga
   ```
4. Contoh Firestore Rules untuk development awal:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /mahasiswa/{nim} {
         allow read, write: if true;
       }
     }
   }
   ```
   Aturan di atas terbuka untuk umum, hanya untuk development.
   Kunci kembali dengan Auth sebelum rilis publik.
5. `flutter run`

## Aturan data

- Semua field wajib diisi.
- NIM 8-16 digit angka dan harus unik.
- Edit memakai layar yang sama dengan data terisi.
- Hapus selalu konfirmasi dialog.
