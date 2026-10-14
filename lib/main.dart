import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/store.dart';
import 'firebase_options.dart';
import 'screens/create_data_screen.dart';
import 'screens/list_data_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/transitions.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const DataMahasiswaApp());
}

class DataMahasiswaApp extends StatelessWidget {
  final FirebaseFirestore? db;

  const DataMahasiswaApp({super.key, this.db});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MahasiswaStore(db)..load(),
      child: MaterialApp(
        title: 'Data Mahasiswa',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          return switch (settings.name) {
            '/list' => slideFadeRoute(const ListDataScreen(), settings),
            '/create' => slideFadeRoute(const CreateDataScreen(), settings),
            _ => fadeRoute(const SplashScreen(), settings),
          };
        },
      ),
    );
  }
}
