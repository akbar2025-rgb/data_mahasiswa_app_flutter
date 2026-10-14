import 'package:cloud_firestore/cloud_firestore.dart';

class Mahasiswa {
  final String nim;
  final String nama;
  final String prodi;
  final String dosenPa;
  final DateTime createdAt;

  const Mahasiswa({
    required this.nim,
    required this.nama,
    required this.prodi,
    required this.dosenPa,
    required this.createdAt,
  });

  String get initials {
    final parts = nama.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        'nim': nim,
        'nama': nama,
        'prodi': prodi,
        'dosenPa': dosenPa,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt'];
    final createdAt = switch (rawDate) {
      Timestamp t => t.toDate(),
      String s => DateTime.tryParse(s) ?? DateTime.now(),
      _ => DateTime.now(),
    };
    return Mahasiswa(
      nim: json['nim'] as String,
      nama: json['nama'] as String,
      prodi: json['prodi'] as String? ?? '',
      dosenPa: json['dosenPa'] as String? ?? '',
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nim': nim,
        'nama': nama,
        'prodi': prodi,
        'dosenPa': dosenPa,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  Mahasiswa copyWith({String? nim, String? nama, String? prodi, String? dosenPa}) {
    return Mahasiswa(
      nim: nim ?? this.nim,
      nama: nama ?? this.nama,
      prodi: prodi ?? this.prodi,
      dosenPa: dosenPa ?? this.dosenPa,
      createdAt: createdAt,
    );
  }
}
