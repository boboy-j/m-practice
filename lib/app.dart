import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'services/audio_generator.dart';
import 'services/metronome_service.dart';
import 'services/pitch_detector_service.dart';
import 'pages/home_page.dart';
import 'pages/pitch/pitch_practice_page.dart';
import 'pages/rhythm/rhythm_practice_page.dart';
import 'pages/score/score_practice_page.dart';

/// 主题状态管理
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/pitch', builder: (context, state) => const PitchPracticePage()),
    GoRoute(path: '/rhythm', builder: (context, state) => const RhythmPracticePage()),
    GoRoute(path: '/score', builder: (context, state) => const ScorePracticePage()),
  ],
);

class MPracticeApp extends StatelessWidget {
  const MPracticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        Provider(create: (_) => AudioGenerator()),
        ChangeNotifierProxyProvider<AudioGenerator, MetronomeService>(
          create: (context) => MetronomeService(
            audioGen: context.read<AudioGenerator>(),
          ),
          update: (_, audioGen, metronome) => metronome!,
        ),
        ChangeNotifierProvider(create: (_) => PitchDetectorService()),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, _) {
          return MaterialApp.router(
            title: 'M-Practice',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.mode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
