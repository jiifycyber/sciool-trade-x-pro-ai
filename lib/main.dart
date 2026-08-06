import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app_state.dart';
import 'src/integration/integration_controller.dart';
import 'src/grand_build_controller.dart';
import 'src/learning_controller.dart';
import 'src/indicator_consensus_controller.dart';
import 'src/historical_replay_controller.dart';
import 'src/strategy_builder_controller.dart';
import 'src/market_radar_controller.dart';
import 'src/screens/login_screen.dart';
import 'src/theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TradeXAppState()..initialize()),
        ChangeNotifierProvider(create: (_) => IntegrationController()),
        ChangeNotifierProvider(create: (_) => GrandBuildController()),
        ChangeNotifierProvider(create: (_) => MarketRadarController()),
        ChangeNotifierProvider(create: (_) => LearningController()),
        ChangeNotifierProvider(create: (_) => IndicatorConsensusController()),
        ChangeNotifierProvider(create: (_) => StrategyBuilderController()),
        ChangeNotifierProvider(create: (_) => HistoricalReplayController()),
      ],
      child: const TradeXApp(),
    ),
  );
}

class TradeXApp extends StatelessWidget {
  const TradeXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SCIOOL Trade X Pro',
      theme: buildTitanTheme(),
      home: const LoginScreen(),
    );
  }
}
