import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/app_colors.dart';
import 'screens/loading/loading_screen.dart';
import 'services/attribution_service.dart';
import 'state/game_provider.dart';
import 'state/run_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Allow all orientations initially so the loading screen can be shown
  // correctly in both portrait and landscape. The app locks to portrait
  // once loading completes (see LoadingScreen).
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.backgroundDeep,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  // Fire-and-forget: attribution resolves asynchronously in the background
  // and must never delay the first frame the player sees.
  unawaited(AttributionService.instance.init());
  runApp(const LavaFortuneApp());
}

class LavaFortuneApp extends StatelessWidget {
  const LavaFortuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => RunProvider()),
      ],
      child: MaterialApp(
        title: 'Lava Fortune',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.lavaOrange,
            brightness: Brightness.dark,
          ),
          fontFamily: 'Roboto',
        ),
        // The HUD, lane cards and resource chips are laid out at fixed sizes,
        // so very large system font settings would clip them.
        builder: (context, child) => MediaQuery.withClampedTextScaling(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.15,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const LoadingScreen(),
      ),
    );
  }
}
