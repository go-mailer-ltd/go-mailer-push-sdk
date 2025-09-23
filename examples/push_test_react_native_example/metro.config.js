const { getDefaultConfig, mergeConfig } = require('@react-native/metro-config');

/**
 * Metro configuration
 * https://reactnative.dev/docs/metro
 *
 * @type {import('@react-native/metro-config').MetroConfig}
 */
const path = require('path');

const config = {
  resolver: {
    extraNodeModules: {
      'go-mailer': path.resolve(__dirname, '../../sdk/react-native'),
    },
  },
  watchFolders: [
    path.resolve(__dirname, '../../sdk/react-native'),
  ],
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
