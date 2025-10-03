// Updated Metro config per RN 0.73 recommendation
const {getDefaultConfig, mergeConfig} = require('@react-native/metro-config');

const projectRoot = __dirname;
const defaultConfig = getDefaultConfig(projectRoot);

module.exports = mergeConfig(defaultConfig, {
  resolver: {
    sourceExts: [...defaultConfig.resolver.sourceExts, 'cjs', 'mjs', 'ts', 'tsx'],
  },
  transformer: {
    ...defaultConfig.transformer,
  }
});
