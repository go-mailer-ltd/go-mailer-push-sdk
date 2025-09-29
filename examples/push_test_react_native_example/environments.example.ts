/**
 * Environment Configuration Example for Go Mailer SDK
 * 
 * Copy this file to `environments.ts` and uncomment the environment you want to test.
 * This allows testers to easily switch between different Go Mailer environments.
 */

import GoMailer, { GoMailerEnvironment } from 'go-mailer-push-sdk';

export interface TestEnvironment {
  name: string;
  environment: GoMailerEnvironment;
  apiKey: string;
  description: string;
}

// Available test environments
export const TEST_ENVIRONMENTS: Record<string, TestEnvironment> = {
  production: {
    name: 'Production',
    environment: 'production',
    apiKey: 'TmF0aGFuLTg5NzI3NDY2NDgzMy42MzI2LTE=', // Replace with production API key
    description: 'Live production environment (go-mailer.com)',
  },
  staging: {
    name: 'Staging',
    environment: 'staging', 
    apiKey: 'TmF0aGFuLTg5NzI3NDY2NDgzMy42MzI2LTE=', // Replace with staging API key
    description: 'Staging environment for testing (gm-g7.xyz)',
  },
  development: {
    name: 'Development',
    environment: 'development',
    apiKey: 'TmF0aGFuLTg5NzI3NDY2NDgzMy42MzI2LTE=', // Replace with dev API key
    description: 'Development environment (gm-g6.xyz)',
  },
};

// Current active environment - change this to test different environments
export const CURRENT_ENVIRONMENT = TEST_ENVIRONMENTS.development; // 👈 Change this!

/**
 * Initialize Go Mailer SDK with the current environment
 */
export async function initializeGoMailer(): Promise<void> {
  console.log(`🌍 Initializing Go Mailer SDK for: ${CURRENT_ENVIRONMENT.name}`);
  console.log(`📍 Environment: ${CURRENT_ENVIRONMENT.description}`);
  
  await GoMailer.initialize({
    apiKey: CURRENT_ENVIRONMENT.apiKey,
    environment: CURRENT_ENVIRONMENT.environment,
    logLevel: 'debug', // Enable debug logs for testing
  });
  
  console.log(`✅ SDK initialized for ${CURRENT_ENVIRONMENT.name} environment`);
}

/**
 * Alternative: Initialize with explicit baseUrl (for custom endpoints)
 */
export async function initializeGoMailerCustom(baseUrl: string, apiKey: string): Promise<void> {
  console.log(`🌍 Initializing Go Mailer SDK with custom endpoint: ${baseUrl}`);
  
  await GoMailer.initialize({
    apiKey,
    baseUrl, // Explicit baseUrl overrides environment setting
    logLevel: 'debug',
  });
  
  console.log(`✅ SDK initialized with custom endpoint`);
}

/**
 * Get all available environments for UI selection
 */
export function getAvailableEnvironments(): TestEnvironment[] {
  return Object.values(TEST_ENVIRONMENTS);
}

/**
 * Switch environment at runtime (requires re-initialization)
 */
export async function switchEnvironment(environmentKey: keyof typeof TEST_ENVIRONMENTS): Promise<void> {
  const env = TEST_ENVIRONMENTS[environmentKey];
  if (!env) {
    throw new Error(`Environment '${environmentKey}' not found`);
  }
  
  console.log(`🔄 Switching to ${env.name} environment...`);
  
  // Note: In a real app, you might want to add a method to reinitialize the SDK
  // For now, testers should restart the app after changing CURRENT_ENVIRONMENT
  await GoMailer.initialize({
    apiKey: env.apiKey,
    environment: env.environment,
    logLevel: 'debug',
  });
  
  console.log(`✅ Switched to ${env.name} environment`);
}

// Example usage in your App.tsx:
/*
import { initializeGoMailer, CURRENT_ENVIRONMENT } from './environments';

// In your component:
useEffect(() => {
  initializeGoMailer()
    .then(() => console.log(`Ready to test ${CURRENT_ENVIRONMENT.name}!`))
    .catch(error => console.error('Failed to initialize:', error));
}, []);
*/
