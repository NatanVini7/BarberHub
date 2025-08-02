import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/autenticacao_service/auth_service.dart';
import '/theme/theme_notifier.dart';
import '/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import '/screens/wrapper.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier(ThemeMode.dark)),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (ctx, themeNotifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Tratto',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.getThemeMode,
            home: Wrapper(),
          );
        },
      ),
    );
  }
}
