/// <reference types="jest" />
import { jest } from '@jest/globals';

const mockGoMailerModule = {
  initialize: jest.fn().mockResolvedValue(undefined),
  getDeviceToken: jest.fn().mockResolvedValue('test-device-token'),
  addListener: jest.fn(),
  removeAllListeners: jest.fn(),
};

(global as any).GoMailerModule = mockGoMailerModule;
(global as any).mockGoMailerModule = mockGoMailerModule;
