module.exports = function (api) {
  api.cache(true);
  return {
    presets: [
      // Updated to current preset name; keeps compatibility with RN 0.73
      '@react-native/babel-preset'
    ],
    plugins: []
  };
};
