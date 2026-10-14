import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mahasiswa.dart';

enum StoreStatus { loading, ready, error }

class MahasiswaStore extends ChangeNotifier {
  static const _seedFlag = 'firestore_seeded_v1';

  final FirebaseFirestore _db;
  StoreStatus status = StoreStatus.loading;
  String? errorMessage;
  final List<Mahasiswa> _items = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  bool _seedAttempted = false;

  MahasiswaStore([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  List<Mahasiswa> get items => List.unmodifiable(_items);

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('mahasiswa');

  Future<void> load() async {
    status = StoreStatus.loading;
    notifyListeners();
    await _sub?.cancel();
    _sub = _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(_onSnapshot, onError: _onError);
  }

  Future<void> _onSnapshot(QuerySnapshot<Map<String, dynamic>> snap) async {
    _items
      ..clear()
      ..addAll(snap.docs.map((d) => Mahasiswa.fromJson(d.data())));
    if (_items.isEmpty && !_seedAttempted) {
      _seedAttempted = true;
      await _seedOnce();
      return;
    }
    status = StoreStatus.ready;
    notifyListeners();
  }

  void _onError(Object e) {
    status = StoreStatus.error;
    if (e is FirebaseException) {
      errorMessage = switch (e.code) {
        'permission-denied' =>
          'Akses ditolak. Ubah Firestore Rules ke mode test di console.',
        'unavailable' =>
          'Server tidak terjangkau. Periksa koneksi internet.',
        'not-found' =>
          'Database belum dibuat. Buat di Build > Firestore Database.',
        _ => 'Gagal memuat data (${e.code}).',
      };
    } else {
      errorMessage = 'Gagal memuat data. Periksa koneksi lalu coba lagi.';
    }
    notifyListeners();
  }

  Future<bool> add(Mahasiswa m) async {
    final doc = await _col.doc(m.nim).get();
    if (doc.exists) return false;
    await _col.doc(m.nim).set(m.toFirestore());
    return true;
  }

  Future<bool> update(String oldNim, Mahasiswa m) async {
    if (m.nim != oldNim) {
      final clash = await _col.doc(m.nim).get();
      if (clash.exists) return false;
      final batch = _db.batch();
      batch.delete(_col.doc(oldNim));
      batch.set(_col.doc(m.nim), m.toFirestore());
      await batch.commit();
      return true;
    }
    await _col.doc(oldNim).set(m.toFirestore());
    return true;
  }

  Future<void> remove(String nim) async {
    await _col.doc(nim).delete();
  }

  bool nimExists(String nim, [String? exceptNim]) {
    return _items.any((e) => e.nim == nim && e.nim != exceptNim);
  }

  Future<void> _seedOnce() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_seedFlag) == true) {
        status = StoreStatus.ready;
        notifyListeners();
        return;
      }
      final now = DateTime.now();
      final batch = _db.batch();
      for (final m in [
        Mahasiswa(
          nim: '2310511024',
          nama: 'Nabila Putri Ramadhani',
          prodi: 'Informatika',
          dosenPa: 'Dr. Raka Prasetyo, M.Kom.',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        Mahasiswa(
          nim: '2310511031',
          nama: 'Muhammad Fikri Akbar',
          prodi: 'Sistem Informasi',
          dosenPa: 'Siti Nurhaliza, S.Kom., M.T.',
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        Mahasiswa(
          nim: '2310511046',
          nama: 'Alya Rahmawati',
          prodi: 'Informatika',
          dosenPa: 'Dr. Hendra Wijaya, M.Cs.',
          createdAt: now.subtract(const Duration(days: 2)),
        ),
      ]) {
        batch.set(_col.doc(m.nim), m.toFirestore());
      }
      await batch.commit();
      await prefs.setBool(_seedFlag, true);
    } catch (_) {
      status = StoreStatus.error;
      errorMessage = 'Gagal memuat data. Periksa koneksi lalu coba lagi.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
