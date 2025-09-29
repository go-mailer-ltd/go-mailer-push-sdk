import 'package:go_mailer_push_sdk/go_mailer.dart';

/// API Keys for each environment
class ApiKeys {
  static const Map<GoMailerEnvironment, String> keys = {
    GoMailerEnvironment.production: 'R28tTWFpbGVyLTQ5NTExMjgwOTU1OC41NDI4LTQw',
    GoMailerEnvironment.staging: 'R2FtYm8tMTU2Mjc3Njc2Mjg2My43ODI1LTI=',
    GoMailerEnvironment.development: 'R2FtYm8tODAwNDQwMDcwNzc0LjI1NjUtMjcw',
  };

  static String getApiKey(GoMailerEnvironment environment) {
    final key = keys[environment];
    if (key == null) {
      throw Exception('No API key found for environment: $environment');
    }
    return key;
  }
}

/// Environment configuration
class EnvironmentConfig {
  static const List<EnvironmentOption> environments = [
    EnvironmentOption(
      name: 'Production',
      environment: GoMailerEnvironment.production,
      endpoint: 'https://api.go-mailer.com/v1',
      description: 'Live production environment',
    ),
    EnvironmentOption(
      name: 'Staging',
      environment: GoMailerEnvironment.staging,
      endpoint: 'https://api.gm-g7.xyz/v1',
      description: 'Pre-production testing',
    ),
    EnvironmentOption(
      name: 'Development',
      environment: GoMailerEnvironment.development,
      endpoint: 'https://api.gm-g6.xyz/v1',
      description: 'Development testing',
    ),
  ];
}

class EnvironmentOption {
  final String name;
  final GoMailerEnvironment environment;
  final String endpoint;
  final String description;

  const EnvironmentOption({
    required this.name,
    required this.environment,
    required this.endpoint,
    required this.description,
  });
}
