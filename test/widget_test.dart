import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:data_mahasiswa_app/data/store.dart';
import 'package:data_mahasiswa_app/main.dart';
import 'package:data_mahasiswa_app/models/mahasiswa.dart';

void main() {
  test('Mahasiswa.initials memakai huruf depan dua kata pertama', () {
    final m = Mahasiswa(
      nim: '2310511024',
      nama: 'Nabila Putri Ramadhani',
      prodi: 'Informatika',
      dosenPa: 'Dr. Raka Prasetyo, M.Kom.',
      createdAt: DateTime(2026, 1, 1),
    );
    expect(m.initials, 'NP');
  });

  test('Store mengisi data awal saat koleksi kosong', () async {
    SharedPreferences.setMockInitialValues({});
    final fake = FakeFirebaseFirestore();
    final store = MahasiswaStore(fake);
    await store.load();
    await Future.delayed(const Duration(milliseconds: 300));
    expect(store.status, StoreStatus.ready);
    expect(store.items.length, 3);
    expect(store.items.first.nim, '2310511024');
  });

  test('Store menolak NIM ganda', () async {
    SharedPreferences.setMockInitialValues({'firestore_seeded_v1': true});
    final fake = FakeFirebaseFirestore();
    await fake.collection('mahasiswa').doc('2310511024').set({
      'nim': '2310511024',
      'nama': 'Nabila Putri Ramadhani',
      'prodi': 'Informatika',
      'dosenPa': 'Dr. Raka Prasetyo, M.Kom.',
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });
    final store = MahasiswaStore(fake);
    final ok = await store.add(Mahasiswa(
      nim: '2310511024',
      nama: 'Nama Lain',
      prodi: 'Informatika',
      dosenPa: 'Dosen X',
      createdAt: DateTime.now(),
    ));
    expect(ok, isFalse);
  });

  testWidgets('Splash tampil lalu pindah ke Lihat Data', (tester) async {
    SharedPreferences.setMockInitialValues({'firestore_seeded_v1': true});
    await tester.pumpWidget(DataMahasiswaApp(db: FakeFirebaseFirestore()));
    expect(find.text('UNIVERSITAS NEGERI NGAWI'), findsOneWidget);
    expect(find.text('Versi 1.0.0'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Lihat Data'), findsOneWidget);
  });
}
