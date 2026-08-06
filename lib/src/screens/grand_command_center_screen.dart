import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../grand_build_controller.dart';
import '../integration/integration_controller.dart';
import 'dashboard_screen.dart';
import 'journal_screen.dart';
import 'settings_screen.dart';
import 'stage5_integration_screen.dart';
import 'strategy_lab_screen.dart';
import 'market_radar_screen.dart';
import 'learning_center_screen.dart';

class GrandCommandCenterScreen extends StatelessWidget {
  const GrandCommandCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<TradeXAppState>();
    final grand = context.watch<GrandBuildController>();
    final integration = context.watch<IntegrationController>();

    return Scaffold(
      appBar: AppBar(title: const Text('TradeX AI — GRAND BUILD')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TradeX Intelligence',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Stage 6 Grand Research, Risk, Approval, and Integration Platform',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _tile(
                context,
                icon: Icons.radar,
                title: 'Live Scanner',
                subtitle: 'Signals and approvals',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                ),
              ),
              _tile(
                context,
                icon: Icons.radar,
                title: 'Market Radar',
                subtitle: 'Scan 5 pairs • 1m/5m/15m',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MarketRadarScreen(),
                  ),
                ),
              ),
              _tile(
                context,
                icon: Icons.psychology,
                title: 'Learning Center',
                subtitle: 'Pair, timing, confidence analytics',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LearningCenterScreen(),
                  ),
                ),
              ),
              _tile(
                context,
                icon: Icons.science,
                title: 'Strategy Lab',
                subtitle: grand.report == null
                    ? 'Run backtests'
                    : '${grand.report!.winRate.toStringAsFixed(1)}% latest test',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StrategyLabScreen()),
                ),
              ),
              _tile(
                context,
                icon: Icons.hub,
                title: 'Integration',
                subtitle: integration.connectorStatus?.message ??
                    'Connector locked',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Stage5IntegrationScreen(),
                  ),
                ),
              ),
              _tile(
                context,
                icon: Icons.receipt_long,
                title: 'Trade Journal',
                subtitle:
                    '${app.settledTrades} settled • ${app.winRate.toStringAsFixed(1)}%',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JournalScreen()),
                ),
              ),
              _tile(
                context,
                icon: Icons.shield,
                title: 'Risk Governor',
                subtitle:
                    '${app.riskPercent.toStringAsFixed(2)}% risk • ${app.maxTradesPerDay} max',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
              _tile(
                context,
                icon: Icons.analytics,
                title: 'Performance',
                subtitle:
                    'P/L \$${app.dailyProfit.toStringAsFixed(2)} today',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JournalScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Icon(
                integration.killSwitch ? Icons.lock : Icons.lock_open,
              ),
              title: Text(
                integration.killSwitch
                    ? 'Emergency protection enabled'
                    : 'Emergency protection disabled',
              ),
              subtitle: const Text(
                'Live execution still requires a documented, authorized connector.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 250,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 34),
                const SizedBox(height: 16),
                Text(title,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 5),
                Text(subtitle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
