import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../models/mahasiswa.dart';
import '../theme/app_theme.dart';
import 'create_data_screen.dart';
import '../widgets/header.dart';
import '../widgets/student_card.dart';
import '../widgets/transitions.dart';

enum SortMode { newest, name, nim }

class ListDataScreen extends StatefulWidget {
  const ListDataScreen({super.key});

  @override
  State<ListDataScreen> createState() => _ListDataScreenState();
}

class _ListDataScreenState extends State<ListDataScreen> {
  final _search = TextEditingController();
  String _query = '';
  SortMode _sort = SortMode.newest;
  final Set<String> _animated = {};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Mahasiswa> _filtered(List<Mahasiswa> items) {
    final q = _query.trim().toLowerCase();
    var list = q.isEmpty
        ? List<Mahasiswa>.from(items)
        : items.where((e) => e.nama.toLowerCase().contains(q) || e.nim.contains(q)).toList();
    switch (_sort) {
      case SortMode.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortMode.name:
        list.sort((a, b) => a.nama.compareTo(b.nama));
        break;
      case SortMode.nim:
        list.sort((a, b) => a.nim.compareTo(b.nim));
        break;
    }
    return list;
  }

  Future<void> _confirmDelete(Mahasiswa m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus data?'),
        content: Text('${m.nama} (${m.nim}) akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<MahasiswaStore>().remove(m.nim);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data dihapus.')));
    }
  }

  void _openSort() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final s in SortMode.values)
              ListTile(
                title: Text(s == SortMode.newest ? 'Diurutkan terbaru' : s == SortMode.name ? 'Nama A-Z' : 'NIM ter kecil'),
                trailing: _sort == s ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() => _sort = s);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<MahasiswaStore>();
    return Scaffold(
      backgroundColor: AppColors.page,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: const PageHeader(title: 'Lihat Data'),
            ),
            Container(height: 1, color: AppColors.line),
            Expanded(
              child: Builder(
                builder: (_) {
                  if (store.status == StoreStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (store.status == StoreStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(store.errorMessage ?? 'Gagal memuat data.'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => store.load(),
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    );
                  }
                  final list = _filtered(store.items);
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 6),
                            const Icon(Icons.search, color: AppColors.hint, size: 24),
                            const SizedBox(width: 6),
                            Expanded(
                              child: TextField(
                                controller: _search,
                                onChanged: (v) => setState(() => _query = v),
                                decoration: const InputDecoration(
                                  hintText: 'Cari NIM atau nama mahasiswa',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: InkWell(
                                onTap: _openSort,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.softBlue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.tune, color: AppColors.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text(
                            '${list.length} mahasiswa',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.ink),
                          ),
                          const Spacer(),
                          Text(
                            _sort == SortMode.newest ? 'Diurutkan terbaru' : _sort == SortMode.name ? 'Nama A-Z' : 'NIM ter kecil',
                            style: const TextStyle(color: AppColors.body, fontSize: 12.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (list.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(color: AppColors.softBlue, borderRadius: BorderRadius.circular(16)),
                                child: const Icon(Icons.search_off_outlined, color: AppColors.primary, size: 28),
                              ),
                              const SizedBox(height: 14),
                              const Text('Tidak ada data ditemukan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                              const SizedBox(height: 6),
                              const Text(
                                'Coba kata kunci lain atau tambah data baru.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.body, fontSize: 13.5),
                              ),
                            ],
                          ),
                        )
                      else
                        for (var i = 0; i < list.length; i++) ...[
                          Builder(builder: (_) {
                            final m = list[i];
                            final card = StudentCard(
                              m: m,
                              onEdit: () => Navigator.of(context).push(
                                slideFadeRoute(
                                  CreateDataScreen(editing: m),
                                  const RouteSettings(name: '/create'),
                                ),
                              ),
                              onDelete: () => _confirmDelete(m),
                            );
                            if (!_animated.add(m.nim)) return card;
                            return Entrance(
                              delayMs: (i * 60).clamp(0, 300),
                              child: card,
                            );
                          }),
                          const SizedBox(height: 14),
                        ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/create'),
            icon: const Icon(Icons.add, color: Colors.white, size: 24),
            label: const Text(
              'Tambah / Input Data',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }
}
