import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../quantum_models.dart';
import '../strategy_builder_controller.dart';
import '../widgets/egypt_widgets.dart';

class StrategyBuilderScreen extends StatefulWidget {
  const StrategyBuilderScreen({super.key});

  @override
  State<StrategyBuilderScreen> createState() => _StrategyBuilderScreenState();
}

class _StrategyBuilderScreenState extends State<StrategyBuilderScreen> {
  final name = TextEditingController(text: 'My Quantum Strategy');
  String left = 'EMA 20';
  String operatorSymbol = '>';
  String right = 'EMA 200';
  String action = 'CALL';
  int confidence = 80;
  final conditions = <StrategyCondition>[];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StrategyBuilderController>();
    return Scaffold(
      appBar: AppBar(title: const Text('NO-CODE STRATEGY BUILDER')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const EgyptianBanner(),
          const SizedBox(height: 14),
          EgyptPanel(
            title: 'Create Strategy',
            child: Column(
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Strategy name'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: left,
                        items: controller.fields
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => left = v ?? left),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: operatorSymbol,
                        items: controller.operators
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(
                          () => operatorSymbol = v ?? operatorSymbol,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: right,
                        decoration: const InputDecoration(labelText: 'Value'),
                        onChanged: (v) => right = v,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      conditions.add(
                        StrategyCondition(
                          left: left,
                          operatorSymbol: operatorSymbol,
                          right: right,
                        ),
                      );
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('ADD CONDITION'),
                ),
                const Divider(),
                ...conditions.map((c) => ListTile(title: Text(c.display))),
                DropdownButtonFormField<String>(
                  initialValue: action,
                  items: const ['CALL', 'PUT', 'WAIT']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => action = v ?? action),
                  decoration: const InputDecoration(labelText: 'Action'),
                ),
                const SizedBox(height: 10),
                Text('Minimum confidence: $confidence%'),
                Slider(
                  value: confidence.toDouble(),
                  min: 50,
                  max: 95,
                  divisions: 45,
                  onChanged: (v) => setState(() => confidence = v.round()),
                ),
                FilledButton.icon(
                  onPressed: conditions.isEmpty
                      ? null
                      : () {
                          controller.addStrategy(
                            StrategyDefinition(
                              name: name.text.trim(),
                              conditions: List.unmodifiable(conditions),
                              action: action,
                              minimumConfidence: confidence,
                            ),
                          );
                        },
                  icon: const Icon(Icons.save),
                  label: const Text('SAVE STRATEGY'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          EgyptPanel(
            title: 'Saved Strategies',
            padding: EdgeInsets.zero,
            child: Column(
              children: controller.strategies.asMap().entries.map((entry) {
                return ExpansionTile(
                  title: Text(entry.value.name),
                  subtitle: Text(
                    '${entry.value.action} • ${entry.value.minimumConfidence}%',
                  ),
                  trailing: IconButton(
                    onPressed: () => controller.removeStrategy(entry.key),
                    icon: const Icon(Icons.delete_outline),
                  ),
                  children: entry.value.conditions
                      .map((e) => ListTile(title: Text(e.display)))
                      .toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
