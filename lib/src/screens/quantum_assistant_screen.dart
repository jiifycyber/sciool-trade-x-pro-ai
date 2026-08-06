import 'package:flutter/material.dart';
import '../widgets/egypt_widgets.dart';

class QuantumAssistantScreen extends StatefulWidget {
  const QuantumAssistantScreen({super.key});

  @override
  State<QuantumAssistantScreen> createState() =>
      _QuantumAssistantScreenState();
}

class _QuantumAssistantScreenState extends State<QuantumAssistantScreen> {
  final controller = TextEditingController();
  final messages = <String>[
    'TITAN: Ask about the strongest setup, rejected trades, sessions, or risk controls.',
  ];

  void send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    final lower = text.toLowerCase();
    String answer;
    if (lower.contains('strongest')) {
      answer =
          'TITAN: Run Market Radar. The top-ranked aligned setup will appear first.';
    } else if (lower.contains('reject') || lower.contains('why')) {
      answer =
          'TITAN: Trades are rejected for weak confidence, timeframe conflict, missed entry, payout limits, volatility, or risk-governor blocks.';
    } else if (lower.contains('london')) {
      answer =
          'TITAN: Use the session filters in Strategy Lab and Market Radar to focus on London-session setups.';
    } else if (lower.contains('risk')) {
      answer =
          'TITAN: Check Risk Governor for trade percentage, daily loss limit, maximum trades, cooldown, and kill switch.';
    } else {
      answer =
          'TITAN: This offline assistant understands platform commands. A generative AI service can be added later through a secure backend.';
    }
    setState(() {
      messages.add('YOU: $text');
      messages.add(answer);
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TITAN QUANTUM ASSISTANT')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: EgyptianBanner(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: messages
                  .map(
                    (m) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(m),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => send(),
                    decoration:
                        const InputDecoration(labelText: 'Ask TITAN'),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: send,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
