import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/ad_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/telemetry_service.dart';
import 'services/localization_service.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global hata yakalama (Flutter UI & Framework hataları)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    TelemetryService.sendError(
      event: 'flutter_uncaught_error',
      message: details.exceptionAsString(),
      stackTrace: details.stack,
      metadata: {
        'library': details.library,
        if (details.context != null) 'context': details.context.toString(),
      },
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    TelemetryService.sendError(
      event: 'platform_uncaught_error',
      message: error.toString(),
      stackTrace: stack,
    );
    return true; 
  };

  await SettingsService.init();
  await AdService.init();
  await Supabase.initialize(
    url: 'https://brgwnlbgasameiuuoxte.supabase.co',
    publishableKey: 'sb_publishable_dYkNlqj0PL3jZsq2Kt0Yyg_pi1gyIdl',
  );
  await TelemetryService.init();
  await Localization.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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

class OkeyDefteriApp extends StatefulWidget {
  const OkeyDefteriApp({super.key});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_OkeyDefteriAppState>()?.restartApp();
  }

  @override
  State<OkeyDefteriApp> createState() => _OkeyDefteriAppState();
}

class _OkeyDefteriAppState extends State<OkeyDefteriApp> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: MaterialApp(
        title: Localization.t('app.name'),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
