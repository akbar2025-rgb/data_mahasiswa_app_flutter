import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/options.dart';
import '../data/store.dart';
import '../models/mahasiswa.dart';
import '../theme/app_theme.dart';
import '../widgets/header.dart';

class CreateDataScreen extends StatefulWidget {
  final Mahasiswa? editing;
  const CreateDataScreen({super.key, this.editing});

  @override
  State<CreateDataScreen> createState() => _CreateDataScreenState();
}

class _CreateDataScreenState extends State<CreateDataScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nim;
  late final TextEditingController _nama;
  String? _prodi;
  String? _dosenPa;
  bool _saving = false;

  bool get isEdit => widget.editing != null;

  @override
  void initState() {
    super.initState();
    _nim = TextEditingController(text: widget.editing?.nim ?? '');
    _nama = TextEditingController(text: widget.editing?.nama ?? '');
    _prodi = widget.editing?.prodi.isNotEmpty == true ? widget.editing!.prodi : null;
    _dosenPa = widget.editing?.dosenPa.isNotEmpty == true ? widget.editing!.dosenPa : null;
  }

  @override
  void dispose() {
    _nim.dispose();
    _nama.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final store = context.read<MahasiswaStore>();
    if (!_formKey.currentState!.validate()) return;
    if (_prodi == null || _dosenPa == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi Program Studi dan Dosen PA.')),
      );
      return;
    }
    final nim = _nim.text.trim();
    if (store.nimExists(nim, widget.editing?.nim)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NIM sudah terdaftar. Gunakan NIM lain.')),
      );
      return;
    }
    setState(() => _saving = true);
    final m = Mahasiswa(
      nim: nim,
      nama: _nama.text.trim(),
      prodi: _prodi!,
      dosenPa: _dosenPa!,
      createdAt: widget.editing?.createdAt ?? DateTime.now(),
    );
    final ok = isEdit
        ? await store.update(widget.editing!.nim, m)
        : await store.add(m);
    if (!mounted) return;
    setState(() => _saving = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NIM sudah terdaftar. Gunakan NIM lain.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isEdit ? 'Data berhasil diperbarui.' : 'Data berhasil disimpan.')),
    );
    Navigator.of(context).pushReplacementNamed('/list');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.page,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(title: isEdit ? 'Edit Data' : 'Create Data'),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.softBlue,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_outlined,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Informasi mahasiswa',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Pastikan data sesuai dengan dokumen akademik resmi.',
                            style: TextStyle(color: AppColors.body, fontSize: 14, height: 1.45),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Semua field wajib diisi',
                            style: TextStyle(color: AppColors.hint, fontSize: 13.5),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('NIM', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nim,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Contoh: 2310511024',
                                prefixIcon: Icon(Icons.verified_outlined, color: AppColors.hint),
                              ),
                              validator: (v) {
                                final t = (v ?? '').trim();
                                if (t.isEmpty) return 'NIM wajib diisi';
                                if (!RegExp(r'^[0-9]{8,16}$').hasMatch(t)) {
                                  return 'NIM harus 8-16 digit angka';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Nomor induk mahasiswa harus unik.',
                              style: TextStyle(color: AppColors.body, fontSize: 12.5),
                            ),
                            const SizedBox(height: 18),
                            const Text('Nama', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nama,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                hintText: 'Masukkan Nama Lengkap',
                                prefixIcon: Icon(Icons.person_outline, color: AppColors.hint),
                              ),
                              validator: (v) {
                                if ((v ?? '').trim().isEmpty) return 'Nama wajib diisi';
                                if ((v ?? '').trim().length < 3) return 'Nama minimal 3 karakter';
                                return null;
                              },
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Gunakan nama sesuai dokumen resmi.',
                              style: TextStyle(color: AppColors.body, fontSize: 12.5),
                            ),
                            const SizedBox(height: 18),
                            const Text('Program Studi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _prodi,
                              hint: const Text('Pilih Program Studi'),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.school_outlined, color: AppColors.hint),
                              ),
                              items: prodiOptions
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(() => _prodi = v),
                              validator: (v) => v == null ? 'Program studi wajib dipilih' : null,
                            ),
                            const SizedBox(height: 18),
                            const Text('Dosen Pembimbing Akademik',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _dosenPa,
                              hint: const Text('Pilih Dosen PA'),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.work_outline, color: AppColors.hint),
                              ),
                              items: dosenPaOptions
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                                  .toList(),
                              onChanged: (v) => setState(() => _dosenPa = v),
                              validator: (v) => v == null ? 'Dosen PA wajib dipilih' : null,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    const Divider(color: AppColors.line, height: 32),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.help_outline, color: AppColors.hint, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Periksa kembali sebelum menyimpan data.',
                                  style: TextStyle(color: AppColors.body, fontSize: 13.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).pushReplacementNamed('/list'),
                              icon: const Icon(Icons.grid_view, color: AppColors.primary),
                              label: const Text(
                                'Lihat Data',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.line),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _saving ? null : _submit,
                              icon: _saving
                                  ? const SizedBox(
                                      width: 20, height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.check, color: Colors.white),
                              label: Text(
                                isEdit ? 'Update Data' : 'Input Data',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
