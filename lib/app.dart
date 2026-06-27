import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'services/metronome_service.dart';
import 'services/pitch_detector_service.dart';
import 'pages/home_page.dart';
import 'pages/pitch/pitch_practice_page.dart';
import 'pages/rhythm/rhythm_practice_page.dart';
import 'pages/score/score_practice_page.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/pitch',
      builder: (context, state) => const PitchPracticePage(),
    ),
    GoRoute(
      path: '/rhythm',
      builder: (context, state) => const RhythmPracticePage(),
    ),
    GoRoute(
      path: '/score',
      builder: (context, state) => const ScorePracticePage(),
    ),
  ],
);

class MPracticeApp extends StatelessWidget {
  const MPracticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MetronomeService()),
        ChangeNotifierProvider(create: (_) => PitchDetectorService()),
      ],
      child: MaterialApp.router(
        title: 'M-Practice',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: _router,
      ),
    );
  }
}
