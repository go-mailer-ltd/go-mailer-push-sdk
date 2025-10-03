import React, { useState } from 'react';
import { SafeAreaView, StyleSheet, View } from 'react-native';
import ConfigScreen, { ConfigValues } from './screens/ConfigScreen';
import TestScreen from './screens/TestScreen';

export default function App() {
  const [config, setConfig] = useState<ConfigValues | null>(null);
  return (
    <SafeAreaView style={styles.container}>
      <View style={{ flex: 1 }}>
        {!config ? (
          <ConfigScreen onContinue={setConfig} />
        ) : (
          <TestScreen
            apiKey={config.apiKey}
            environment={config.environment}
            onReset={() => setConfig(null)}
          />
        )}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0e1117' }
});
