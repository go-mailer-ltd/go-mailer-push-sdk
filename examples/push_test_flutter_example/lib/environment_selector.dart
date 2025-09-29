import 'package:flutter/material.dart';
import 'package:go_mailer_push_sdk/go_mailer.dart';
import 'config.dart';

class EnvironmentSelector extends StatelessWidget {
  final GoMailerEnvironment currentEnvironment;
  final Function(GoMailerEnvironment) onEnvironmentChanged;

  const EnvironmentSelector({
    Key? key,
    required this.currentEnvironment,
    required this.onEnvironmentChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentConfig = EnvironmentConfig.environments
        .firstWhere((env) => env.environment == currentEnvironment);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Environment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () => _showEnvironmentDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Switch'),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getEnvironmentColor(currentEnvironment),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentConfig.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          currentConfig.endpoint,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    currentConfig.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEnvironmentColor(GoMailerEnvironment environment) {
    switch (environment) {
      case GoMailerEnvironment.production:
        return Colors.green;
      case GoMailerEnvironment.staging:
        return Colors.orange;
      case GoMailerEnvironment.development:
        return Colors.blue;
    }
  }

  void _showEnvironmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Environment'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: EnvironmentConfig.environments.length,
              itemBuilder: (context, index) {
                final env = EnvironmentConfig.environments[index];
                final isSelected = env.environment == currentEnvironment;
                
                return Card(
                  color: isSelected ? Colors.blue[50] : null,
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getEnvironmentColor(env.environment),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        env.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      env.endpoint,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(env.description),
                    trailing: isSelected 
                        ? Icon(Icons.check_circle, color: Colors.blue)
                        : null,
                    onTap: () {
                      Navigator.of(context).pop();
                      if (env.environment != currentEnvironment) {
                        _confirmEnvironmentChange(context, env.environment);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _confirmEnvironmentChange(BuildContext context, GoMailerEnvironment newEnvironment) {
    final newConfig = EnvironmentConfig.environments
        .firstWhere((env) => env.environment == newEnvironment);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Switch Environment'),
          content: Text(
            'Switch to ${newConfig.name}?\n\n'
            'Endpoint: ${newConfig.endpoint}\n\n'
            'This will reinitialize the SDK with the new environment.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onEnvironmentChanged(newEnvironment);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Switch'),
            ),
          ],
        );
      },
    );
  }
}
