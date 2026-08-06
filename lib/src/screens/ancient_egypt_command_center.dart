import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../app_state.dart';
import '../market_radar_controller.dart';
import '../integration/integration_controller.dart';
import '../theme.dart';
import '../widgets/egypt_widgets.dart';
import 'dashboard_screen.dart';
import 'market_radar_screen.dart';
import 'strategy_lab_screen.dart';
import 'stage5_integration_screen.dart';
import 'journal_screen.dart';
import 'learning_center_screen.dart';
import 'settings_screen.dart';
import 'universal_indicator_screen.dart';
import 'quantum_ai_screen.dart';
import 'strategy_builder_screen.dart';
import 'historical_replay_screen.dart';
import 'advanced_reports_screen.dart';
import 'quantum_assistant_screen.dart';

class AncientEgyptCommandCenter extends StatelessWidget {
  const AncientEgyptCommandCenter({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<TradeXAppState>();
    final radar = context.watch<MarketRadarController>();
    final integration = context.watch<IntegrationController>();
    final best = radar.bestOpportunity;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 1000) {
              return _mobile(context, app, radar, integration);
            }
            return _desktop(context, app, radar, integration);
          },
        ),
      ),
    );
  }

  Widget _desktop(
    BuildContext context,
    TradeXAppState app,
    MarketRadarController radar,
    IntegrationController integration,
  ) {
    final best = radar.bestOpportunity;
    return Row(
      children: [
        _sideNav(context),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.4,
                colors: [
                  Color(0xFF1A1308),
                  TitanEgyptColors.obsidian,
                ],
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                const EgyptianBanner(),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    EgyptMetric(
                      label: 'Equity',
                      value: '\$${app.accountBalance.toStringAsFixed(2)}',
                    ),
                    EgyptMetric(
                      label: 'Daily P/L',
                      value: '\$${app.dailyProfit.toStringAsFixed(2)}',
                      valueColor: app.dailyProfit >= 0
                          ? TitanEgyptColors.emerald
                          : TitanEgyptColors.red,
                    ),
                    EgyptMetric(
                      label: 'Win Rate',
                      value: '${app.winRate.toStringAsFixed(1)}%',
                    ),
                    EgyptMetric(
                      label: 'Trades Today',
                      value: '${app.tradesToday}/${app.maxTradesPerDay}',
                    ),
                    EgyptMetric(
                      label: 'Best Setup',
                      value: best == null
                          ? 'SCAN'
                          : '${best.symbol} ${best.confidence}%',
                      valueColor: TitanEgyptColors.emerald,
                    ),
                    EgyptMetric(
                      label: 'Protection',
                      value: integration.killSwitch ? 'ON' : 'OFF',
                      valueColor: integration.killSwitch
                          ? TitanEgyptColors.red
                          : TitanEgyptColors.emerald,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.42,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _marketRadarPanel(context, radar),
                    _spiderTrendPanel(context, radar),
                    _chartStationPanel(context, app),
                    _entryCommandPanel(context, app),
                    _consensusPanel(context, radar),
                    _riskPanel(context, app, integration),
                  ],
                ),
                const SizedBox(height: 10),
                _bottomDock(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _mobile(
    BuildContext context,
    TradeXAppState app,
    MarketRadarController radar,
    IntegrationController integration,
  ) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const EgyptianBanner(),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SizedBox(
              width: 170,
              child: EgyptMetric(
                label: 'Win Rate',
                value: '${app.winRate.toStringAsFixed(1)}%',
              ),
            ),
            SizedBox(
              width: 170,
              child: EgyptMetric(
                label: 'Daily P/L',
                value: '\$${app.dailyProfit.toStringAsFixed(2)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _marketRadarPanel(context, radar),
        const SizedBox(height: 10),
        _spiderTrendPanel(context, radar),
        const SizedBox(height: 10),
        _chartStationPanel(context, app),
        const SizedBox(height: 10),
        _entryCommandPanel(context, app),
        const SizedBox(height: 10),
        _consensusPanel(context, radar),
        const SizedBox(height: 10),
        _riskPanel(context, app, integration),
        const SizedBox(height: 10),
        _bottomDock(context),
      ],
    );
  }

  Widget _sideNav(BuildContext context) {
    final items = <(IconData, String, Widget)>[
      (Icons.dashboard, 'Dashboard', const AncientEgyptCommandCenter()),
      (Icons.radar, 'Market Radar', const MarketRadarScreen()),
      (Icons.psychology, 'SpiderTrend AI', const MarketRadarScreen()),
      (Icons.auto_awesome, 'Quantum AI', const QuantumAiScreen()),
      (Icons.account_tree, 'Strategy Builder', const StrategyBuilderScreen()),
      (Icons.replay_circle_filled, 'Historical Replay', const HistoricalReplayScreen()),
      (Icons.insights, 'Advanced Reports', const AdvancedReportsScreen()),
      (Icons.record_voice_over, 'Quantum Assistant', const QuantumAssistantScreen()),
      (Icons.candlestick_chart, 'Chart Station', const DashboardScreen()),
      (Icons.tune, 'Indicators', const UniversalIndicatorScreen()),
      (Icons.auto_awesome, 'Quantum AI', const QuantumAiScreen()),
      (Icons.account_tree, 'Strategy Builder', const StrategyBuilderScreen()),
      (Icons.replay, 'Replay', const HistoricalReplayScreen()),
      (Icons.insights, 'Reports', const AdvancedReportsScreen()),
      (Icons.science, 'Strategy Lab', const StrategyLabScreen()),
      (Icons.receipt_long, 'Trade Journal', const JournalScreen()),
      (Icons.school, 'Learning Center', const LearningCenterScreen()),
      (Icons.shield, 'Risk Governor', const SettingsScreen()),
      (Icons.hub, 'Integration', const Stage5IntegrationScreen()),
    ];

    return Container(
      width: 190,
      color: TitanEgyptColors.charcoal,
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Icon(
            Icons.account_balance,
            size: 48,
            color: TitanEgyptColors.gold,
          ),
          const SizedBox(height: 8),
          const Text(
            'TradeX AI',
            style: TextStyle(
              color: TitanEgyptColors.brightGold,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: items.skip(1).map((item) {
                return ListTile(
                  leading: Icon(item.$1, color: TitanEgyptColors.gold),
                  title: Text(
                    item.$2,
                    style: const TextStyle(
                      color: Color(0xFFE8D6A3),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => item.$3),
                  ),
                );
              }).toList(),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(14),
            child: Icon(
              Icons.pets,
              size: 56,
              color: TitanEgyptColors.bronze,
            ),
          ),
        ],
      ),
    );
  }

  Widget _marketRadarPanel(
    BuildContext context,
    MarketRadarController radar,
  ) {
    return EgyptPanel(
      title: 'Market Radar',
      trailing: TextButton(
        onPressed: radar.scanning ? null : radar.scanAll,
        child: Text(radar.scanning ? 'SCANNING' : 'FULL RADAR'),
      ),
      child: Column(
        children: [
          if (radar.opportunities.isEmpty)
            const ListTile(
              title: Text('No live scan yet'),
              subtitle: Text('Run the radar to rank five Forex pairs.'),
            ),
          ...radar.opportunities.take(5).toList().asMap().entries.map(
                (entry) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 15,
                    backgroundColor: TitanEgyptColors.bronze,
                    child: Text('${entry.key + 1}'),
                  ),
                  title: Text(entry.value.symbol),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SignalPill(
                        text: entry.value.direction,
                        color: entry.value.direction == 'CALL'
                            ? TitanEgyptColors.emerald
                            : entry.value.direction == 'PUT'
                                ? TitanEgyptColors.red
                                : TitanEgyptColors.amber,
                      ),
                      const SizedBox(width: 8),
                      Text('${entry.value.confidence}%'),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _spiderTrendPanel(
    BuildContext context,
    MarketRadarController radar,
  ) {
    final best = radar.bestOpportunity;
    final direction = best?.direction ?? 'WAIT';
    final confidence = best?.confidence ?? 0;
    return EgyptPanel(
      title: 'SpiderTrend AI',
      child: Column(
        children: [
          const Icon(
            Icons.remove_red_eye,
            size: 72,
            color: TitanEgyptColors.cyan,
          ),
          const SizedBox(height: 8),
          Text(
            direction,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: direction == 'CALL'
                  ? TitanEgyptColors.emerald
                  : direction == 'PUT'
                      ? TitanEgyptColors.red
                      : TitanEgyptColors.amber,
            ),
          ),
          Text(
            'TRADE GRADE ${confidence >= 90 ? "A+" : confidence >= 80 ? "A" : confidence >= 70 ? "B+" : "C"}',
            style: const TextStyle(
              color: TitanEgyptColors.brightGold,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$confidence%',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: TitanEgyptColors.emerald,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tf in const ['1m', '5m', '15m'])
                SignalPill(
                  text: '$tf ${direction == "WAIT" ? "NEUTRAL" : "BULLISH"}',
                  color: direction == 'WAIT'
                      ? TitanEgyptColors.amber
                      : TitanEgyptColors.emerald,
                ),
            ],
          ),
          const SizedBox(height: 10),
          ...?best?.reasons.take(5).map(
                (r) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text('✓ $r'),
                ),
              ),
        ],
      ),
    );
  }

  Widget _chartStationPanel(
    BuildContext context,
    TradeXAppState app,
  ) {
    return EgyptPanel(
      title: 'Chart Station • ${app.selectedSymbol}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CustomPaint(
              painter: _EgyptChartPainter(),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: const [
              SignalPill(text: 'RSI', color: TitanEgyptColors.cyan),
              SignalPill(text: 'MACD', color: TitanEgyptColors.emerald),
              SignalPill(text: 'BB', color: TitanEgyptColors.gold),
              SignalPill(text: 'ATR', color: TitanEgyptColors.amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _entryCommandPanel(
    BuildContext context,
    TradeXAppState app,
  ) {
    final direction = app.signal == null
        ? 'WAIT'
        : switch (app.signal!.direction) {
            var d when d.name == 'call' => 'CALL',
            var d when d.name == 'put' => 'PUT',
            _ => 'WAIT',
          };

    return EgyptPanel(
      title: 'Entry Command',
      child: Column(
        children: [
          const Icon(
            Icons.account_balance,
            size: 54,
            color: TitanEgyptColors.gold,
          ),
          Text(
            app.selectedSymbol,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          Text(
            direction,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: direction == 'CALL'
                  ? TitanEgyptColors.emerald
                  : direction == 'PUT'
                      ? TitanEgyptColors.red
                      : TitanEgyptColors.amber,
            ),
          ),
          const SizedBox(height: 8),
          _kv('Signal detected', app.market?.time.toString() ?? '—'),
          _kv('Entry status', app.entryStatus),
          _kv('Suggested amount',
              '\$${app.signal?.suggestedAmount.toStringAsFixed(2) ?? "0.00"}'),
          _kv('Expiration',
              '${app.signal?.expirationMinutes ?? 0} minute(s)'),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: null,
            icon: const Icon(Icons.lock),
            label: const Text('APPROVAL QUEUE'),
          ),
        ],
      ),
    );
  }

  Widget _consensusPanel(
    BuildContext context,
    MarketRadarController radar,
  ) {
    final best = radar.bestOpportunity;
    final confidence = best?.confidence ?? 0;
    return EgyptPanel(
      title: 'Indicator Consensus',
      child: Column(
        children: [
          _consensusRow('Trend', 12, 2, 1),
          _consensusRow('Momentum', 7, 1, 2),
          _consensusRow('Volatility', 3, 2, 4),
          _consensusRow('Volume', 4, 1, 2),
          _consensusRow('Price Action', 6, 1, 1),
          _consensusRow('Structure', 5, 0, 1),
          const Divider(),
          Text(
            '$confidence% ${best?.direction == "PUT" ? "BEARISH" : "BULLISH"}',
            style: const TextStyle(
              fontSize: 28,
              color: TitanEgyptColors.emerald,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskPanel(
    BuildContext context,
    TradeXAppState app,
    IntegrationController integration,
  ) {
    return EgyptPanel(
      title: 'Risk Governor',
      child: Column(
        children: [
          _kv('Risk per trade', '${app.riskPercent.toStringAsFixed(1)}%'),
          _kv('Daily loss limit',
              '${app.dailyLossLimitPercent.toStringAsFixed(1)}%'),
          _kv('Max trades per day', '${app.maxTradesPerDay}'),
          _kv('Loss cooldown', '3'),
          _kv('Min confidence', '${app.minimumConfidence}%'),
          _kv('Minimum payout', '${app.payout}%'),
          _kv('Martingale', 'OFF'),
          _kv('Kill switch', integration.killSwitch ? 'ON' : 'OFF'),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.shield),
            label: const Text('MANAGE RISK'),
          ),
        ],
      ),
    );
  }

  Widget _bottomDock(BuildContext context) {
    final actions = <(IconData, String, Widget)>[
      (Icons.science, 'Strategy Lab', const StrategyLabScreen()),
      (Icons.history, 'Backtester', const StrategyLabScreen()),
      (Icons.receipt_long, 'Trade Journal', const JournalScreen()),
      (Icons.school, 'Learning Center', const LearningCenterScreen()),
      (Icons.analytics, 'Performance', const JournalScreen()),
      (Icons.tune, 'Indicators', const UniversalIndicatorScreen()),
      (Icons.auto_awesome, 'Quantum AI', const QuantumAiScreen()),
      (Icons.account_tree, 'Strategy Builder', const StrategyBuilderScreen()),
      (Icons.replay, 'Replay', const HistoricalReplayScreen()),
      (Icons.insights, 'Reports', const AdvancedReportsScreen()),
    ];

    return Container(
      decoration: BoxDecoration(
        color: TitanEgyptColors.charcoal,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TitanEgyptColors.bronze),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        children: actions.map((action) {
          return TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => action.$3),
            ),
            icon: Icon(action.$1),
            label: Text(action.$2),
          );
        }).toList(),
      ),
    );
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              key.toUpperCase(),
              style: const TextStyle(
                color: TitanEgyptColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: TitanEgyptColors.brightGold,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _consensusRow(String label, int bull, int bear, int neutral) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          SizedBox(
            width: 36,
            child: Text(
              '$bull',
              textAlign: TextAlign.center,
              style: const TextStyle(color: TitanEgyptColors.emerald),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$bear',
              textAlign: TextAlign.center,
              style: const TextStyle(color: TitanEgyptColors.red),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$neutral',
              textAlign: TextAlign.center,
              style: const TextStyle(color: TitanEgyptColors.amber),
            ),
          ),
        ],
      ),
    );
  }
}

class _EgyptChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = TitanEgyptColors.bronze.withOpacity(.25)
      ..strokeWidth = .7;
    final up = Paint()
      ..color = TitanEgyptColors.emerald
      ..strokeWidth = 2;
    final down = Paint()
      ..color = TitanEgyptColors.red
      ..strokeWidth = 2;
    final ma = Paint()
      ..color = TitanEgyptColors.cyan
      ..strokeWidth = 1.4;

    for (int i = 1; i < 8; i++) {
      final x = size.width * i / 8;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (int i = 1; i < 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final points = <Offset>[];
    for (int i = 0; i < 34; i++) {
      final x = size.width * i / 33;
      final y = size.height *
          (.72 - i * .011 + .10 * math.sin(i * .72) + .04 * math.cos(i * .27));
      points.add(Offset(x, y.clamp(12, size.height - 12)));
    }

    for (int i = 1; i < points.length; i++) {
      canvas.drawLine(points[i - 1], points[i],
          points[i].dy < points[i - 1].dy ? up : down);
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy + 18);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy + 18);
    }
    canvas.drawPath(path, ma);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
