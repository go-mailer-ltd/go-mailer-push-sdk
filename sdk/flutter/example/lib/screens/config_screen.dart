import 'package:flutter/material.dart';
import 'package:go_mailer_push_sdk/go_mailer.dart';
import 'test_screen.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  String _selectedEnvironment = 'development';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoMailer Configuration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  hintText: 'Enter your GoMailer API Key',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter API key';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedEnvironment,
                decoration: const InputDecoration(
                  labelText: 'Environment',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'development',
                    child: Text('Development'),
                  ),
                  DropdownMenuItem(
                    value: 'production',
                    child: Text('Production'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedEnvironment = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Initialize GoMailer with the configuration
                    final config = GoMailerConfig(
                      apiKey: _apiKeyController.text,
                      environment: _selectedEnvironment == 'development'
                          ? GoMailerEnvironment.DEVELOPMENT
                          : GoMailerEnvironment.PRODUCTION,
                    );

                    // Navigate to test screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TestScreen(config: config),
                      ),
                    );
                  }
                },
                child: const Text('Continue to Test Screen'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
