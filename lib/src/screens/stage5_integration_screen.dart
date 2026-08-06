import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../integration/connector_models.dart';
import '../integration/integration_controller.dart';

class Stage5IntegrationScreen extends StatelessWidget {
  const Stage5IntegrationScreen({super.key});

  String stateText(ConnectorState? state) => switch (state) {
        ConnectorState.connected => 'CONNECTED',
        ConnectorState.configured => 'CONFIGURED',
        ConnectorState.error => 'ERROR',
        ConnectorState.locked => 'LOCKED',
        _ => 'DISCONNECTED',
      };

  @override
  Widget build(BuildContext context) {
    final integration = context.watch<IntegrationController>();
    final status = integration.connectorStatus;

    return Scaffold(
      appBar: AppBar(title: const Text('Stage 5 Integration Center')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pocket Option Connector'),
                  const SizedBox(height: 10),
                  Text('Status: ${stateText(status?.state)}'),
                  Text(status?.message ?? 'Connection has not been checked.'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: integration.checkConnection,
                    icon: const Icon(Icons.sync),
                    label: const Text('Check Connector'),
                  ),
                ],
              ),
            ),
          ),
          SwitchListTile(
            value: integration.killSwitch,
            onChanged: integration.setKillSwitch,
            title: const Text('Emergency Kill Switch'),
            subtitle: const Text('Keep enabled until authorized live testing.'),
          ),
          SwitchListTile(
            value: integration.liveModeRequested,
            onChanged: integration.requestLiveMode,
            title: const Text('Request Live Mode'),
            subtitle: const Text(
              'Requesting live mode does not unlock execution without a supported connector.',
            ),
          ),
          const SizedBox(height: 12),
          Text('Approval Queue',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (integration.queue.isEmpty)
            const Card(
              child: ListTile(
                title: Text('No pending execution requests'),
              ),
            ),
          ...integration.queue.map(
            (request) => Card(
              child: ListTile(
                title: Text(
                  '${request.symbol} • ${request.direction.toUpperCase()}',
                ),
                subtitle: Text(
                  '\$${request.amount.toStringAsFixed(2)} • '
                  '${request.expirationMinutes} minute(s) • '
                  '${request.confidence}% confidence',
                ),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      onPressed: () async {
                        final message = await integration.approve(request.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle),
                    ),
                    IconButton(
                      onPressed: () => integration.reject(request.id),
                      icon: const Icon(Icons.cancel),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Audit Log', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (integration.auditLog.isEmpty)
            const Card(child: ListTile(title: Text('No audit activity yet'))),
          ...integration.auditLog.take(20).map(
                (entry) => Card(
                  child: ListTile(
                    title: Text(entry.action),
                    subtitle: Text(entry.detail),
                    trailing: Text(
                      '${entry.time.hour.toString().padLeft(2, '0')}:'
                      '${entry.time.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
