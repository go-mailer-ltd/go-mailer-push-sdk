/// <reference types="jest" />
import { jest } from '@jest/globals';

const mockGoMailerModule: any = {
  initialize: jest.fn(async () => {}),
  getDeviceToken: jest.fn(async () => ({ token: 'test-device-token' })),
  registerForPushNotifications: jest.fn(async () => {}),
  setUser: jest.fn(async () => {}),
  trackEvent: jest.fn(async () => {}),
  addListener: jest.fn(),
  removeAllListeners: jest.fn(),
};

(global as any).GoMailerModule = mockGoMailerModule;
(global as any).mockGoMailerModule = mockGoMailerModule;
