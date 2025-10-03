import React, { useCallback, useEffect, useRef, useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, TextInput, ScrollView, Platform, PermissionsAndroid } from 'react-native';
import GoMailer from 'go-mailer-push-sdk';

interface Props {
  apiKey: string;
  environment: 'development' | 'staging' | 'production';
  onReset: () => void;
}

interface LogEntry {
  id: string;
  ts: number;
  level: 'info' | 'error';
  msg: string;
  data?: any;
}

const TestScreen: React.FC<Props> = ({ apiKey, environment, onReset }) => {
  const [email, setEmail] = useState('');
  const [initialized, setInitialized] = useState(false);
  const [deviceToken, setDeviceToken] = useState<string | null>(null);
  const [lastEvent, setLastEvent] = useState<any>(null);
  const [logs, setLogs] = useState<LogEntry[]>([]);
  const listenRef = useRef<any>(null);

  const addLog = useCallback((entry: Omit<LogEntry, 'id' | 'ts'>) => {
    setLogs(prev => [{ id: Math.random().toString(36).slice(2), ts: Date.now(), ...entry }, ...prev].slice(0, 200));
  }, []);

  const initialize = async () => {
    if (initialized) return;
    try {
      await GoMailer.initialize({ apiKey, environment });
      setInitialized(true);
      addLog({ level: 'info', msg: 'SDK initialized' });
      try {
        const token = await GoMailer.getDeviceToken?.();
        if (token) {
          setDeviceToken(token);
          addLog({ level: 'info', msg: 'Existing device token', data: token });
        }
      } catch (err) {
        addLog({ level: 'error', msg: 'getDeviceToken failed', data: String(err) });
      }
    } catch (e) {
      addLog({ level: 'error', msg: 'Initialization failed', data: String(e) });
    }
  };

  const handleSetUser = async () => {
    if (!email.trim()) {
      addLog({ level: 'error', msg: 'Email is required to set user' });
      return;
    }
    try {
      addLog({ level: 'info', msg: 'Setting user...', data: { email: email.trim() } });
      await GoMailer.setUser({ userId: email.trim(), email: email.trim() });
      addLog({ level: 'info', msg: 'User set successfully', data: { email: email.trim() } });
    } catch (e) {
      addLog({ level: 'error', msg: 'Set user failed', data: String(e) });
    }
  };

  const registerForPush = async () => {
    if (!email.trim()) {
      addLog({ level: 'error', msg: 'Email is required for push registration' });
      return;
    }
    
    try {
      // For Android 13+, we need to request notification permission first
      if (Platform.OS === 'android' && Platform.Version >= 33) {
        addLog({ level: 'info', msg: 'Requesting POST_NOTIFICATIONS permission...' });
        const granted = await PermissionsAndroid.request(
          PermissionsAndroid.PERMISSIONS.POST_NOTIFICATIONS
        );
        if (granted !== PermissionsAndroid.RESULTS.GRANTED) {
          addLog({ level: 'error', msg: 'Notification permission denied' });
          return;
        }
        addLog({ level: 'info', msg: 'Notification permission granted' });
      }
      
      addLog({ level: 'info', msg: 'Registering for push notifications...', data: { email: email.trim() } });
      await GoMailer.registerForPushNotifications(email.trim());
      addLog({ level: 'info', msg: 'Push registration request sent to backend', data: { email: email.trim() } });
      
      // Poll for token with longer delay to allow Firebase initialization
      addLog({ level: 'info', msg: 'Waiting for Firebase token generation...' });
      setTimeout(async () => {
        try {
          const token = await GoMailer.getDeviceToken?.();
          if (token) {
            setDeviceToken(token);
            addLog({ level: 'info', msg: 'Device token retrieved from Firebase', data: { token: token.substring(0, 50) + '...' } });
            addLog({ level: 'info', msg: 'Token should now be registered on backend', data: { email: email.trim() } });
          } else {
            addLog({ level: 'error', msg: 'No device token available yet - Firebase may need proper configuration' });
            addLog({ level: 'info', msg: 'Note: This demo uses a test google-services.json - replace with your real Firebase config for production' });
          }
        } catch (err) {
          addLog({ level: 'error', msg: 'Device token fetch failed', data: String(err) });
        }
      }, 3000);
    } catch (e) {
      addLog({ level: 'error', msg: 'Push registration failed', data: String(e) });
    }
  };

  useEffect(() => {
    initialize();
    if (GoMailer.addEventListener) {
      listenRef.current = GoMailer.addEventListener('event', (ev: any) => {
        setLastEvent(ev);
        addLog({ level: 'info', msg: 'SDK Event', data: ev });
        if (ev?.type === 'pushToken' && ev?.token) {
          setDeviceToken(ev.token);
        }
      });
    }
    return () => {
      try { listenRef.current?.remove?.(); } catch {}
    };
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const renderLastEvent = () => (
    <View style={styles.card}>
      <Text style={styles.cardTitle}>Last SDK Event</Text>
      {lastEvent ? (
        <Text style={styles.code} selectable>{JSON.stringify(lastEvent, null, 2)}</Text>
      ) : (
        <Text style={styles.muted}>No events yet</Text>
      )}
    </View>
  );

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.headerRow}>
        <Text style={styles.title}>GoMailer Test Screen</Text>
        <TouchableOpacity onPress={onReset} style={styles.resetBtn}>
          <Text style={styles.resetText}>Reset</Text>
        </TouchableOpacity>
      </View>
      <Text style={styles.subtitle}>Environment: {environment}</Text>

      <View style={styles.card}>
        <Text style={styles.cardTitle}>Set User Email</Text>
        <TextInput
          style={styles.input}
          placeholder="Email Address"
          placeholderTextColor="#6b7280"
          value={email}
          onChangeText={setEmail}
          autoCapitalize="none"
          keyboardType="email-address"
        />
        <TouchableOpacity 
          style={[styles.primaryBtn, !email.trim() && styles.disabledBtn]} 
          onPress={handleSetUser}
          disabled={!email.trim()}
        >
          <Text style={styles.primaryBtnText}>Set User</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.card}>
        <Text style={styles.cardTitle}>Push Notifications</Text>
        <Text style={styles.subtitle}>Email is required for push registration</Text>
        <TouchableOpacity 
          style={[styles.secondaryBtn, !email.trim() && styles.disabledBtn]} 
          onPress={registerForPush}
          disabled={!email.trim()}
        >
          <Text style={styles.secondaryBtnText}>Register For Push</Text>
        </TouchableOpacity>
        <TouchableOpacity 
          style={[styles.tertiaryBtn, !email.trim() && styles.disabledBtn]} 
          onPress={() => {
            if (!email.trim()) return;
            const testToken = `test_token_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
            setDeviceToken(testToken);
            addLog({ level: 'info', msg: 'Generated test token for demo purposes', data: { token: testToken } });
            addLog({ level: 'info', msg: 'Note: Replace google-services.json with real Firebase config for actual tokens' });
          }}
          disabled={!email.trim()}
        >
          <Text style={styles.tertiaryBtnText}>Generate Test Token</Text>
        </TouchableOpacity>
        <Text style={styles.tokenLabel}>Device Token</Text>
        <Text style={styles.code} selectable>{deviceToken || '— not acquired —'}</Text>
      </View>

      {renderLastEvent()}

      <View style={styles.card}>
        <Text style={styles.cardTitle}>Logs</Text>
        {logs.length === 0 ? (
          <Text style={styles.muted}>No logs yet</Text>
        ) : (
          logs.slice(0, 30).map(l => (
            <View key={l.id} style={styles.logRow}>
              <Text style={[styles.logLevel, l.level === 'error' && styles.logLevelError]}>{l.level.toUpperCase()}</Text>
              <Text style={styles.logMsg}>{l.msg}</Text>
            </View>
          ))
        )}
      </View>
      <View style={{ height: 40 }} />
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0e1117' },
  content: { padding: 20, paddingBottom: 60 },
  headerRow: { flexDirection: 'row', alignItems: 'center' },
  title: { flex: 1, color: 'white', fontSize: 20, fontWeight: '700' },
  subtitle: { color: '#9ca3af', marginTop: 4, marginBottom: 16 },
  resetBtn: { backgroundColor: '#374151', paddingHorizontal: 12, paddingVertical: 8, borderRadius: 8 },
  resetText: { color: 'white', fontSize: 12, fontWeight: '600' },
  card: { backgroundColor: '#1f242d', borderRadius: 14, padding: 16, marginBottom: 20 },
  cardTitle: { color: 'white', fontSize: 16, fontWeight: '600', marginBottom: 12 },
  input: { backgroundColor: '#111827', borderRadius: 10, padding: 12, color: 'white', marginBottom: 12 },
  primaryBtn: { backgroundColor: '#2563eb', padding: 14, borderRadius: 10, marginTop: 4 },
  primaryBtnText: { color: 'white', textAlign: 'center', fontWeight: '600' },
  secondaryBtn: { backgroundColor: '#374151', padding: 12, borderRadius: 10, marginTop: 4, marginBottom: 8 },
  secondaryBtnText: { color: 'white', textAlign: 'center', fontWeight: '600' },
  tertiaryBtn: { backgroundColor: '#1f2937', padding: 10, borderRadius: 8, marginBottom: 12 },
  tertiaryBtnText: { color: '#9ca3af', textAlign: 'center', fontWeight: '500', fontSize: 12 },
  disabledBtn: { backgroundColor: '#4b5563', opacity: 0.5 },
  tokenLabel: { color: '#9ca3af', fontSize: 12, textTransform: 'uppercase', letterSpacing: 1, marginBottom: 6 },
  code: { color: '#d1d5db', backgroundColor: '#111827', borderRadius: 8, padding: 10, fontSize: 12, fontFamily: 'Menlo' },
  muted: { color: '#6b7280', fontSize: 12 },
  logRow: { flexDirection: 'row', marginBottom: 4 },
  logLevel: { color: '#10b981', fontSize: 10, fontWeight: '700', marginRight: 6 },
  logLevelError: { color: '#ef4444' },
  logMsg: { color: '#d1d5db', fontSize: 12, flex: 1 }
});

export default TestScreen;
