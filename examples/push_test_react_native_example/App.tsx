/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, {useState, useEffect} from 'react';
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
  Alert,
  Platform,
  PermissionsAndroid,
} from 'react-native';
import {NativeModules} from 'react-native';
import GoMailer, { GoMailerEnvironment } from 'go-mailer-push-sdk';
import EnvironmentSelector from './EnvironmentSelector';

function App(): React.JSX.Element {
  const [email, setEmail] = useState('');
  const [status, setStatus] = useState('Ready');
  const [deviceToken, setDeviceToken] = useState('');
  const [currentEnvironment, setCurrentEnvironment] = useState<GoMailerEnvironment>('production');

  useEffect(() => {
    // Test if the native module is available
    console.log('🔍 Testing native module availability...');
    console.log('🔍 NativeModules:', Object.keys(NativeModules));
    
    if (NativeModules.GoMailerModule) {
      console.log('✅ GoMailerModule found in NativeModules!');
      setStatus('GoMailerModule found!');
    } else {
      console.log('❌ GoMailerModule not found in NativeModules');
      setStatus('GoMailerModule not found');
    }

    // Request notification permission on app start
    requestNotificationPermission();
  }, []);

  const requestNotificationPermission = async () => {
    if (Platform.OS === 'android') {
      try {
        if (Platform.Version >= 33) {
          const granted = await PermissionsAndroid.request(
            PermissionsAndroid.PERMISSIONS.POST_NOTIFICATIONS,
            {
              title: 'Notification Permission',
              message: 'Go Mailer needs permission to send you notifications',
              buttonNeutral: 'Ask Me Later',
              buttonNegative: 'Cancel',
              buttonPositive: 'OK',
            }
          );
          
          if (granted === PermissionsAndroid.RESULTS.GRANTED) {
            console.log('✅ Notification permission granted');
            setStatus('Notification permission granted');
          } else {
            console.log('❌ Notification permission denied');
            setStatus('Notification permission denied');
            Alert.alert(
              'Permission Required',
              'Please enable notifications in Settings to receive push notifications.',
              [
                { text: 'Cancel', style: 'cancel' },
                { text: 'Open Settings', onPress: () => console.log('Open settings') }
              ]
            );
          }
        } else {
          console.log('✅ Android < 13, permission not required');
          setStatus('Notification permission not required');
        }
      } catch (err) {
        console.warn('Error requesting notification permission:', err);
      }
    }
  };

  const initializeSDK = async () => {
    try {
      setStatus('Initializing...');
      await GoMailer.initialize({
        apiKey: 'TmF0aGFuLTg5NzI3NDY2NDgzMy42MzI2LTE=',
        environment: currentEnvironment,
      });
      setStatus(`SDK initialized successfully (${currentEnvironment})`);
    } catch (error) {
      console.error('Failed to initialize SDK:', error);
      setStatus('Failed to initialize SDK');
      Alert.alert('Error', 'Failed to initialize Go Mailer SDK');
    }
  };

  const handleEnvironmentChange = (newEnvironment: GoMailerEnvironment) => {
    setCurrentEnvironment(newEnvironment);
    setStatus(`Environment changed to ${newEnvironment}. Please reinitialize.`);
  };

  const setUser = async () => {
    if (!email.trim()) {
      Alert.alert('Error', 'Please enter an email address');
      return;
    }

    try {
      setStatus('Setting user...');
      await GoMailer.setUser({email: email.trim()});
      setStatus('User set successfully');
    } catch (error) {
      console.error('Failed to set user:', error);
      setStatus('Failed to set user');
      Alert.alert('Error', 'Failed to set user');
    }
  };

  const registerForPushNotifications = async () => {
    try {
      setStatus('Registering for push notifications...');
      await GoMailer.registerForPushNotifications(email.trim());
      setStatus('Push notification registration initiated');
    } catch (error) {
      console.error('Failed to register for push notifications:', error);
      setStatus('Failed to register for push notifications');
      Alert.alert('Error', 'Failed to register for push notifications');
    }
  };

  const getDeviceToken = async () => {
    try {
      setStatus('Getting device token...');
      const result = await GoMailer.getDeviceToken();
      if (result) {
        setDeviceToken(result);
        setStatus('Device token retrieved');
      } else {
        setStatus('No device token available');
      }
    } catch (error) {
      console.error('Failed to get device token:', error);
      setStatus('Failed to get device token');
      Alert.alert('Error', 'Failed to get device token');
    }
  };

  const trackSampleEvents = async () => {
    try {
      setStatus('Tracking sample events...');
      
      // Track app opened event
      await GoMailer.trackEvent('app_opened', {
        source: 'react_native_example',
        timestamp: new Date().toISOString()
      });
      
      // Track button clicked event
      await GoMailer.trackEvent('button_clicked', {
        button: 'track_sample_events',
        source: 'react_native_example'
      });
      
      // Track user registered event
      await GoMailer.trackEvent('user_registered', {
        email: email.trim(),
        platform: 'react_native_ios'
      });
      
      // Track notification interaction ready event
      await GoMailer.trackEvent('notification_interaction_ready', {
        platform: 'react_native_ios',
        sdk_version: '1.0.0'
      });
      
      setStatus('Sample events tracked successfully');
    } catch (error) {
      console.error('Failed to track sample events:', error);
      setStatus('Failed to track sample events');
      Alert.alert('Error', 'Failed to track sample events');
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="#f8f9fa" />
      <ScrollView contentInsetAdjustmentBehavior="automatic">
        <View style={styles.content}>
          <Text style={styles.title}>Go Mailer SDK Test</Text>
          
          <EnvironmentSelector 
            currentEnvironment={currentEnvironment}
            onEnvironmentChange={handleEnvironmentChange}
          />
          
          <View style={styles.statusContainer}>
            <Text style={styles.statusLabel}>Status:</Text>
            <Text style={styles.statusText}>{status}</Text>
          </View>

          <View style={styles.inputContainer}>
            <Text style={styles.label}>Email Address:</Text>
            <TextInput
              style={styles.input}
              value={email}
              onChangeText={setEmail}
              placeholder="Enter your email"
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
            />
          </View>

          <View style={styles.buttonContainer}>
            <TouchableOpacity style={styles.button} onPress={requestNotificationPermission}>
              <Text style={styles.buttonText}>🔔 Request Notification Permission</Text>
            </TouchableOpacity>

            <TouchableOpacity style={styles.button} onPress={initializeSDK}>
              <Text style={styles.buttonText}>Initialize SDK</Text>
            </TouchableOpacity>

            <TouchableOpacity style={styles.button} onPress={setUser}>
              <Text style={styles.buttonText}>Set User</Text>
            </TouchableOpacity>

            <TouchableOpacity style={styles.button} onPress={registerForPushNotifications}>
              <Text style={styles.buttonText}>Register for Push Notifications</Text>
            </TouchableOpacity>

            <TouchableOpacity style={styles.button} onPress={getDeviceToken}>
              <Text style={styles.buttonText}>Get Device Token</Text>
            </TouchableOpacity>

            <TouchableOpacity style={styles.button} onPress={trackSampleEvents}>
              <Text style={styles.buttonText}>Track Sample Events</Text>
            </TouchableOpacity>
          </View>

          {deviceToken ? (
            <View style={styles.tokenContainer}>
              <Text style={styles.tokenLabel}>Device Token:</Text>
              <Text style={styles.tokenText}>{deviceToken}</Text>
            </View>
          ) : null}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  content: {
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 20,
    color: '#333',
  },
  statusContainer: {
    backgroundColor: '#e9ecef',
    padding: 15,
    borderRadius: 8,
    marginBottom: 20,
  },
  statusLabel: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#495057',
    marginBottom: 5,
  },
  statusText: {
    fontSize: 14,
    color: '#6c757d',
  },
  inputContainer: {
    marginBottom: 20,
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    color: '#495057',
    marginBottom: 8,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ced4da',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    backgroundColor: '#fff',
  },
  buttonContainer: {
    gap: 12,
  },
  button: {
    backgroundColor: '#007bff',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  tokenContainer: {
    marginTop: 20,
    backgroundColor: '#e9ecef',
    padding: 15,
    borderRadius: 8,
  },
  tokenLabel: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#495057',
    marginBottom: 5,
  },
  tokenText: {
    fontSize: 12,
    color: '#6c757d',
    fontFamily: 'monospace',
  },
});

export default App;
