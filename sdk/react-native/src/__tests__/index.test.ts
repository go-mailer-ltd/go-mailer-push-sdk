/// <reference types="jest" />
import { jest, describe, it, expect, beforeEach } from '@jest/globals';
import { NativeModules } from 'react-native';
import GoMailer, { GoMailerLogLevel } from '../index';

// This import will set up the mock
import './setup';

// Mock react-native
jest.mock('react-native', () => ({
  NativeModules: {
    GoMailerModule: {
      initialize: jest.fn().mockImplementation(async (config) => {
        return Promise.resolve();
      }),
      getDeviceToken: jest.fn().mockImplementation(async () => {
        return Promise.resolve({ token: 'test-device-token' });
      }),
      addListener: jest.fn(),
      removeAllListeners: jest.fn(),
    },
  },
  NativeEventEmitter: jest.fn().mockImplementation(() => ({
    addListener: () => ({ remove: () => {} }),
    removeAllListeners: () => {},
  })),
}));

describe('GoMailer SDK', () => {
  const defaultConfig = {
    apiKey: 'test-api-key',
    baseUrl: 'https://api.gm-g6.xyz/v1',
    enableAnalytics: true,
    logLevel: GoMailerLogLevel.INFO,
    enableOfflineQueue: true,
    maxRetryAttempts: 3,
    retryDelayMs: 1000,
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should initialize with correct config', async () => {
    const initConfig = { ...defaultConfig };
    await GoMailer.initialize(initConfig);
    expect(NativeModules.GoMailerModule.initialize).toHaveBeenCalledWith(initConfig);
  });

  it('should get device token', async () => {
    await GoMailer.initialize(defaultConfig);
    const token = await GoMailer.getDeviceToken();
    expect(token).toBe('test-device-token');
    expect(NativeModules.GoMailerModule.getDeviceToken).toHaveBeenCalled();
  });
});
