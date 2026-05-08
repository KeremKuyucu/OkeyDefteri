import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const OkeyDefteriApp());
}

class OkeyDefteriApp extends StatelessWidget {
  const OkeyDefteriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Okey 101 Skor Defteri',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
