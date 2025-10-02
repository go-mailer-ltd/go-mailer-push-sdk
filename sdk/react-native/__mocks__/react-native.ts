const mockGoMailerModule = {
  initialize: jest.fn().mockResolvedValue(undefined),
  getDeviceToken: jest.fn().mockResolvedValue('test-device-token'),
  addListener: jest.fn(),
  removeAllListeners: jest.fn(),
};

const NativeModules = {
  GoMailerPushSDK: mockGoMailerModule,
};

class NativeEventEmitter {
  addListener() { return { remove: () => {} }; }
  removeAllListeners() {}
  removeSubscription() {}
}

export {
  NativeModules,
  NativeEventEmitter,
  mockGoMailerModule as default,
};
