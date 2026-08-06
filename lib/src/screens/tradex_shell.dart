import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../market_radar_controller.dart';
import '../integration/integration_controller.dart';
import '../theme.dart';
import '../widgets/tradex_widgets.dart';

import 'dashboard_screen.dart';
import 'market_radar_screen.dart';
import 'quantum_ai_screen.dart';
import 'universal_indicator_screen.dart';
import 'strategy_builder_screen.dart';
import 'strategy_lab_screen.dart';
import 'historical_replay_screen.dart';
import 'journal_screen.dart';
import 'learning_center_screen.dart';
import 'advanced_reports_screen.dart';
import 'settings_screen.dart';
import 'stage5_integration_screen.dart';
import 'quantum_assistant_screen.dart';
import 'login_screen.dart';

class TradeXShell extends StatefulWidget {
  const TradeXShell({super.key});

  @override
  State<TradeXShell> createState() => _TradeXShellState();
}

class _TradeXShellState extends State<TradeXShell> {
  int selected = 0;

  final labels = const [
    'Command Center',
    'Live Scanner',
    'Market Radar',
    'Quantum AI',
    '250 Indicators',
    'Strategy Builder',
    'Strategy Lab',
    'Historical Replay',
    'Trade Journal',
    'Learning Center',
    'Advanced Reports',
    'Risk Governor',
    'Integration',
    'AI Assistant',
  ];

  final icons = const [
    Icons.space_dashboard_rounded,
    Icons.candlestick_chart_rounded,
    Icons.radar_rounded,
    Icons.auto_awesome_rounded,
    Icons.tune_rounded,
    Icons.account_tree_rounded,
    Icons.science_rounded,
    Icons.replay_circle_filled_rounded,
    Icons.receipt_long_rounded,
    Icons.school_rounded,
    Icons.insights_rounded,
    Icons.shield_rounded,
    Icons.hub_rounded,
    Icons.psychology_rounded,
  ];

  List<Widget> get pages => const [
        TradeXCommandCenter(),
        DashboardScreen(),
        MarketRadarScreen(),
        QuantumAiScreen(),
        UniversalIndicatorScreen(),
        StrategyBuilderScreen(),
        StrategyLabScreen(),
        HistoricalReplayScreen(),
        JournalScreen(),
        LearningCenterScreen(),
        AdvancedReportsScreen(),
        SettingsScreen(),
        Stage5IntegrationScreen(),
        QuantumAssistantScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final scaffold = Scaffold(
          appBar: AppBar(
            title: Text(labels[selected]),
            leading: wide
                ? null
                : Builder(
                    builder: (context) => IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(Icons.menu_rounded),
                    ),
                  ),
            actions: [
              const XPill(text: 'LIVE READY', color: TradeXColors.green),
              const SizedBox(width: 10),
              IconButton(
                tooltip: 'Refresh',
                onPressed: () {
                  context.read<TradeXAppState>().refreshMarket();
                },
                icon: const Icon(Icons.refresh_rounded),
              ),
              IconButton(
                tooltip: 'Sign out',
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                ),
                icon: const Icon(Icons.logout_rounded),
              ),
              const SizedBox(width: 8),
            ],
          ),
          drawer: wide
              ? null
              : Drawer(
                  backgroundColor: TradeXColors.backgroundAlt,
                  child: SafeArea(child: _menu(context, compact: false)),
                ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.6,
                colors: [
                  Color(0xFF142050),
                  TradeXColors.background,
                ],
              ),
            ),
            child: IndexedStack(index: selected, children: pages),
          ),
        );

        if (!wide) return scaffold;

        return Scaffold(
          body: Row(
            children: [
              Container(
                width: 258,
                decoration: const BoxDecoration(
                  color: TradeXColors.backgroundAlt,
                  border: Border(
                    right: BorderSide(color: TradeXColors.border),
                  ),
                ),
                child: SafeArea(child: _menu(context, compact: false)),
              ),
              Expanded(child: scaffold),
            ],
          ),
        );
      },
    );
  }

  Widget _menu(BuildContext context, {required bool compact}) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 22, 18, 18),
          child: Row(
            children: [
              _BrandMark(),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SCIOOL',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.8,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'TRADE X PRO',
                      style: TextStyle(
                        color: TradeXColors.cyan,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            itemCount: labels.length,
            itemBuilder: (context, index) {
              final active = selected == index;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: ListTile(
                  selected: active,
                  selectedTileColor: TradeXColors.cyan.withOpacity(.10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: active
                          ? TradeXColors.cyan.withOpacity(.35)
                          : Colors.transparent,
                    ),
                  ),
                  leading: Icon(
                    icons[index],
                    color:
                        active ? TradeXColors.cyan : TradeXColors.muted,
                  ),
                  title: Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          active ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    setState(() => selected = index);
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: XGlassPanel(
            padding: const EdgeInsets.all(13),
            glowColor: TradeXColors.green,
            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: TradeXColors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'System protected',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TradeXColors.cyan, TradeXColors.violet],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TradeXColors.cyan.withOpacity(.20),
            blurRadius: 18,
          ),
        ],
      ),
      child: const Icon(
        Icons.insights_rounded,
        color: Color(0xFF07111D),
        size: 27,
      ),
    );
  }
}

class TradeXCommandCenter extends StatelessWidget {
  const TradeXCommandCenter({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<TradeXAppState>();
    final radar = context.watch<MarketRadarController>();
    final integration = context.watch<IntegrationController>();
    final best = radar.bestOpportunity;
    final width = MediaQuery.sizeOf(context).width;

    return RefreshIndicator(
      onRefresh: () async {
        await app.refreshMarket();
        await radar.scanAll();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          XGlassPanel(
            glowColor: TradeXColors.cyan,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 16,
              children: [
                const SizedBox(
                  width: 540,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SCIOOL TRADE X PRO',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.8,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Professional AI trading command center with live scanning, strategy research, risk controls, and performance intelligence.',
                        style: TextStyle(
                          color: TradeXColors.muted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    XPill(
                      text: app.liveDataConfigured
                          ? 'MARKET DATA READY'
                          : 'API KEY NEEDED',
                      color: app.liveDataConfigured
                          ? TradeXColors.green
                          : TradeXColors.amber,
                    ),
                    XPill(
                      text: integration.killSwitch
                          ? 'KILL SWITCH ON'
                          : 'RISK PROTECTED',
                      color: integration.killSwitch
                          ? TradeXColors.red
                          : TradeXColors.cyan,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: width >= 1350 ? 5 : width >= 850 ? 3 : 2,
            childAspectRatio: width >= 850 ? 1.8 : 1.45,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              XMetricCard(
                label: 'Equity',
                value: '\$${app.accountBalance.toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet_rounded,
                accent: TradeXColors.cyan,
                change: 'Protected balance',
              ),
              XMetricCard(
                label: 'Daily P/L',
                value:
                    '${app.dailyProfit >= 0 ? "+" : ""}\$${app.dailyProfit.toStringAsFixed(2)}',
                icon: Icons.trending_up_rounded,
                accent: app.dailyProfit >= 0
                    ? TradeXColors.green
                    : TradeXColors.red,
                change: 'Current session',
              ),
              XMetricCard(
                label: 'Win Rate',
                value: '${app.winRate.toStringAsFixed(1)}%',
                icon: Icons.workspace_premium_rounded,
                accent: TradeXColors.violet,
                change: '${app.wins}/${app.settledTrades} settled',
              ),
              XMetricCard(
                label: 'Trades Today',
                value: '${app.tradesToday}/${app.maxTradesPerDay}',
                icon: Icons.speed_rounded,
                accent: TradeXColors.amber,
                change: 'Daily governor',
              ),
              XMetricCard(
                label: 'Best Setup',
                value: best == null
                    ? 'Run Radar'
                    : '${best.symbol} ${best.confidence}%',
                icon: Icons.radar_rounded,
                accent: TradeXColors.green,
                change: best?.direction ?? 'Awaiting scan',
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 970) {
                return Column(
                  children: [
                    _scannerPanel(context, app),
                    const SizedBox(height: 12),
                    _aiPanel(context, best),
                    const SizedBox(height: 12),
                    _riskPanel(context, app, integration),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _scannerPanel(context, app)),
                  const SizedBox(width: 12),
                  Expanded(flex: 4, child: _aiPanel(context, best)),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: _riskPanel(context, app, integration)),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                _quickTool(
                  context,
                  icon: Icons.radar_rounded,
                  title: 'Market Radar',
                  description: 'Rank live pairs by opportunity quality.',
                  color: TradeXColors.cyan,
                  onTap: radar.scanAll,
                ),
                _quickTool(
                  context,
                  icon: Icons.tune_rounded,
                  title: '250 Indicators',
                  description: 'Search, filter, and manage the indicator pack.',
                  color: TradeXColors.violet,
                  onTap: () {},
                ),
                _quickTool(
                  context,
                  icon: Icons.account_tree_rounded,
                  title: 'Strategy Builder',
                  description: 'Build rules without writing code.',
                  color: TradeXColors.green,
                  onTap: () {},
                ),
                _quickTool(
                  context,
                  icon: Icons.receipt_long_rounded,
                  title: 'Trade Journal',
                  description: 'Record outcomes and learning statistics.',
                  color: TradeXColors.amber,
                  onTap: () {},
                ),
              ];

              return GridView.count(
                crossAxisCount: constraints.maxWidth >= 1100
                    ? 4
                    : constraints.maxWidth >= 650
                        ? 2
                        : 1,
                childAspectRatio: 2.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: cards,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _scannerPanel(BuildContext context, TradeXAppState app) {
    final market = app.market;
    return XGlassPanel(
      glowColor: TradeXColors.cyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          XSectionTitle(
            title: 'Live Market Scanner',
            subtitle: 'Real Forex candle analysis',
            trailing: IconButton(
              onPressed: app.isLoading ? null : app.refreshMarket,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: app.selectedSymbol,
            items: app.symbols
                .map((symbol) => DropdownMenuItem(
                      value: symbol,
                      child: Text(symbol),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) app.setSymbol(value);
            },
            decoration: const InputDecoration(
              labelText: 'Market pair',
              prefixIcon: Icon(Icons.currency_exchange_rounded),
            ),
          ),
          const SizedBox(height: 14),
          if (app.marketError != null)
            Text(
              app.marketError!,
              style: const TextStyle(color: TradeXColors.red),
            )
          else if (market == null)
            const Text(
              'Connect live data and run a scan.',
              style: TextStyle(color: TradeXColors.muted),
            )
          else
            Wrap(
              spacing: 18,
              runSpacing: 10,
              children: [
                _value('Price', market.price.toStringAsFixed(5)),
                _value('EMA ${app.strategy.emaFast}', market.emaFast.toStringAsFixed(5)),
                _value('EMA ${app.strategy.emaSlow}', market.emaSlow.toStringAsFixed(5)),
                _value('Momentum', market.momentum.toStringAsFixed(2)),
                _value('Volatility', market.volatility.toStringAsFixed(2)),
                _value('Payout', '${market.payout}%'),
              ],
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: app.isLoading ? null : app.refreshMarket,
              icon: app.isLoading
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.radar_rounded),
              label: Text(
                app.isLoading ? 'SCANNING...' : 'SCAN LIVE MARKET',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiPanel(BuildContext context, dynamic best) {
    final direction = best?.direction ?? 'WAIT';
    final confidence = best?.confidence ?? 0;
    final color = direction == 'CALL'
        ? TradeXColors.green
        : direction == 'PUT'
            ? TradeXColors.red
            : TradeXColors.amber;

    return XGlassPanel(
      glowColor: TradeXColors.violet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const XSectionTitle(
            title: 'TradeX AI',
            subtitle: 'Multi-timeframe opportunity intelligence',
          ),
          const SizedBox(height: 18),
          Center(
            child: Container(
              width: 122,
              height: 122,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(.22),
                    TradeXColors.panelStrong,
                  ],
                ),
                border: Border.all(color: color.withOpacity(.65), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(.18),
                    blurRadius: 28,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$confidence%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 27,
                    ),
                  ),
                  Text(
                    direction,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (best == null)
            const Text(
              'Run Market Radar to generate the ranked AI assessment.',
              style: TextStyle(color: TradeXColors.muted),
            )
          else ...[
            _value('Best market', best.symbol),
            const SizedBox(height: 8),
            _value('Expiration', '${best.expirationMinutes} minute(s)'),
            const SizedBox(height: 10),
            ...best.reasons.take(4).map<Widget>(
                  (reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      '✓ $reason',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _riskPanel(
    BuildContext context,
    TradeXAppState app,
    IntegrationController integration,
  ) {
    return XGlassPanel(
      glowColor: integration.killSwitch
          ? TradeXColors.red
          : TradeXColors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const XSectionTitle(
            title: 'Risk Governor',
            subtitle: 'Hard protection rules',
          ),
          const SizedBox(height: 15),
          _riskRow('Risk per trade', '${app.riskPercent.toStringAsFixed(1)}%'),
          _riskRow(
            'Daily loss limit',
            '${app.dailyLossLimitPercent.toStringAsFixed(1)}%',
          ),
          _riskRow('Max trades', '${app.maxTradesPerDay}'),
          _riskRow('Min confidence', '${app.minimumConfidence}%'),
          _riskRow('Minimum payout', '${app.payout}%'),
          _riskRow('Martingale', 'OFF'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (integration.killSwitch
                      ? TradeXColors.red
                      : TradeXColors.green)
                  .withOpacity(.10),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: (integration.killSwitch
                        ? TradeXColors.red
                        : TradeXColors.green)
                    .withOpacity(.35),
              ),
            ),
            child: Text(
              integration.killSwitch
                  ? 'EXECUTION LOCKED'
                  : 'PROTECTION ACTIVE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: integration.killSwitch
                    ? TradeXColors.red
                    : TradeXColors.green,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickTool(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return XGlassPanel(
      glowColor: color,
      onTap: onTap,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TradeXColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: TradeXColors.muted,
          ),
        ],
      ),
    );
  }

  Widget _value(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: TradeXColors.muted,
            fontWeight: FontWeight.w800,
            fontSize: 9,
            letterSpacing: .6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _riskRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: TradeXColors.muted),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
