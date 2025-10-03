import React, { useState } from 'react';
import { View, Text, TextInput, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';

export interface ConfigValues {
  apiKey: string;
  environment: 'development' | 'staging' | 'production';
}

interface Props {
  onContinue: (values: ConfigValues) => void;
}

const environments: Array<{label: string; value: ConfigValues['environment']}> = [
  { label: 'Development', value: 'development' },
  { label: 'Staging', value: 'staging' },
  { label: 'Production', value: 'production' }
];

export const ConfigScreen: React.FC<Props> = ({ onContinue }) => {
  const [apiKey, setApiKey] = useState('');
  const [environment, setEnvironment] = useState<ConfigValues['environment']>('development');
  const [error, setError] = useState('');

  const handleContinue = () => {
    if (!apiKey.trim()) {
      setError('Please enter API key');
      return;
    }
    setError('');
    onContinue({ apiKey: apiKey.trim(), environment });
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <View style={styles.logoBox}>
        <Text style={styles.logoIcon}>🔔</Text>
      </View>
      <Text style={styles.title}>GoMailer Configuration</Text>
      <View style={styles.card}>
        <Text style={styles.cardTitle}>API Configuration</Text>
        <TextInput
          placeholder="API Key"
          placeholderTextColor="#6b7280"
          value={apiKey}
          onChangeText={setApiKey}
          autoCapitalize="none"
          style={styles.input}
        />
        <Text style={styles.label}>Environment</Text>
        <View style={styles.envRow}>
          {environments.map(env => (
            <TouchableOpacity
              key={env.value}
              style={[styles.envBtn, environment === env.value && styles.envBtnActive]}
              onPress={() => setEnvironment(env.value)}
            >
              <Text style={styles.envBtnText}>{env.label}</Text>
            </TouchableOpacity>
          ))}
        </View>
        {error ? <Text style={styles.error}>{error}</Text> : null}
      </View>
      <TouchableOpacity style={styles.primaryBtn} onPress={handleContinue}>
        <Text style={styles.primaryBtnText}>Continue</Text>
      </TouchableOpacity>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: { flexGrow: 1, padding: 24, backgroundColor: '#0e1117' },
  logoBox: { alignItems: 'center', marginTop: 48 },
  logoIcon: { fontSize: 64 },
  title: { color: 'white', fontSize: 22, fontWeight: '700', textAlign: 'center', marginTop: 16, marginBottom: 32 },
  card: { backgroundColor: '#1f242d', borderRadius: 14, padding: 16 },
  cardTitle: { color: 'white', fontSize: 16, fontWeight: '600', marginBottom: 16 },
  input: { backgroundColor: '#111827', borderRadius: 10, padding: 12, color: 'white', marginBottom: 16 },
  label: { color: '#9ca3af', fontSize: 12, textTransform: 'uppercase', letterSpacing: 1 },
  envRow: { flexDirection: 'row', marginTop: 12 },
  envBtn: { flex: 1, backgroundColor: '#111827', paddingVertical: 10, marginRight: 8, borderRadius: 8, alignItems: 'center' },
  envBtnActive: { backgroundColor: '#2563eb' },
  envBtnText: { color: 'white', fontSize: 12, fontWeight: '500' },
  primaryBtn: { backgroundColor: '#2563eb', padding: 16, borderRadius: 12, marginTop: 32 },
  primaryBtnText: { color: 'white', fontSize: 16, fontWeight: '600', textAlign: 'center' },
  error: { color: '#f87171', marginTop: 8, fontSize: 12 }
});

export default ConfigScreen;
