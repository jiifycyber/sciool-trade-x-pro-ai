import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../indicator_consensus_controller.dart';
import '../indicators/titan_indicator_pack_250.dart';
import '../theme.dart';
import '../widgets/egypt_widgets.dart';

class UniversalIndicatorScreen extends StatefulWidget {
  const UniversalIndicatorScreen({super.key});

  @override
  State<UniversalIndicatorScreen> createState() =>
      _UniversalIndicatorScreenState();
}

class _UniversalIndicatorScreenState extends State<UniversalIndicatorScreen> {
  String query = '';
  IndicatorCategory? selectedCategory;

  String categoryName(IndicatorCategory c) => switch (c) {
        IndicatorCategory.trend => 'Trend',
        IndicatorCategory.momentum => 'Momentum',
        IndicatorCategory.volatility => 'Volatility',
        IndicatorCategory.volume => 'Volume',
        IndicatorCategory.structure => 'Structure',
      };

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<IndicatorConsensusController>();
    final filtered = controller.indicators.where((indicator) {
      final q = query.toLowerCase();
      final matchesText = indicator.name.toLowerCase().contains(q) ||
          indicator.description.toLowerCase().contains(q);
      final matchesCategory =
          selectedCategory == null || indicator.category == selectedCategory;
      return matchesText && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('250 INDICATOR ENGINE'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${controller.enabledIds.length}/250 ACTIVE',
                style: const TextStyle(
                  color: TitanEgyptColors.emerald,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const EgyptianBanner(),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const EgyptMetric(
                label: 'Implemented',
                value: '250',
                valueColor: TitanEgyptColors.emerald,
              ),
              EgyptMetric(
                label: 'Enabled',
                value: '${controller.enabledIds.length}',
              ),
              EgyptMetric(
                label: 'Bullish',
                value: '${controller.bullish}',
                valueColor: TitanEgyptColors.emerald,
              ),
              EgyptMetric(
                label: 'Bearish',
                value: '${controller.bearish}',
                valueColor: TitanEgyptColors.red,
              ),
              EgyptMetric(
                label: 'Consensus',
                value:
                    '${controller.consensusPercent}% ${controller.consensusDirection}',
                valueColor: TitanEgyptColors.brightGold,
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search all 250 indicators',
            ),
            onChanged: (value) => setState(() => query = value),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: selectedCategory == null,
                onSelected: (_) => setState(() => selectedCategory = null),
              ),
              ...IndicatorCategory.values.map(
                (category) => ChoiceChip(
                  label: Text(categoryName(category)),
                  selected: selectedCategory == category,
                  onSelected: (_) =>
                      setState(() => selectedCategory = category),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          EgyptPanel(
            title: 'Indicator Catalog',
            trailing: Text('${filtered.length} shown'),
            padding: EdgeInsets.zero,
            child: Column(
              children: filtered.map((indicator) {
                final enabled = controller.enabledIds.contains(indicator.id);
                return SwitchListTile(
                  value: enabled,
                  activeColor: TitanEgyptColors.gold,
                  title: Text(indicator.name),
                  subtitle: Text(
                    '${categoryName(indicator.category)} • ${indicator.description}',
                  ),
                  onChanged: (value) => controller.toggle(indicator.id, value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
