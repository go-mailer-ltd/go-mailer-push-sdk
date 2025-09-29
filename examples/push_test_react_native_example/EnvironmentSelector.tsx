import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Modal,
  Alert,
} from 'react-native';
import GoMailer, { GoMailerEnvironment } from 'go-mailer-push-sdk';

interface EnvironmentOption {
  name: string;
  environment: GoMailerEnvironment;
  endpoint: string;
  description: string;
}

const ENVIRONMENTS: EnvironmentOption[] = [
  {
    name: 'Production',
    environment: 'production',
    endpoint: 'https://api.go-mailer.com/v1',
    description: 'Live production environment',
  },
  {
    name: 'Staging',
    environment: 'staging',
    endpoint: 'https://api.gm-g7.xyz/v1',
    description: 'Pre-production testing',
  },
  {
    name: 'Development',
    environment: 'development',
    endpoint: 'https://api.gm-g6.xyz/v1',
    description: 'Development testing',
  },
];

// API Keys for each environment
export const API_KEYS = {
  production: 'R28tTWFpbGVyLTQ5NTExMjgwOTU1OC41NDI4LTQw',
  staging: 'R2FtYm8tMTU2Mjc3Njc2Mjg2My43ODI1LTI=',
  development: 'R2FtYm8tODAwNDQwMDcwNzc0LjI1NjUtMjcw',
} as const;

interface Props {
  currentEnvironment: GoMailerEnvironment;
  onEnvironmentChange: (env: GoMailerEnvironment) => void;
}

export default function EnvironmentSelector({ currentEnvironment, onEnvironmentChange }: Props) {
  const [modalVisible, setModalVisible] = useState(false);

  const handleEnvironmentSelect = (env: GoMailerEnvironment) => {
    if (env === currentEnvironment) {
      setModalVisible(false);
      return;
    }

    Alert.alert(
      'Switch Environment',
      `Switch to ${ENVIRONMENTS.find(e => e.environment === env)?.name}?\n\nThis will reinitialize the SDK.`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Switch',
          onPress: () => {
            onEnvironmentChange(env);
            setModalVisible(false);
          },
        },
      ]
    );
  };

  const currentEnv = ENVIRONMENTS.find(e => e.environment === currentEnvironment);

  return (
    <>
      <TouchableOpacity style={styles.selector} onPress={() => setModalVisible(true)}>
        <Text style={styles.label}>Environment:</Text>
        <View style={styles.currentEnv}>
          <Text style={styles.envName}>{currentEnv?.name}</Text>
          <Text style={styles.envEndpoint}>{currentEnv?.endpoint}</Text>
        </View>
        <Text style={styles.arrow}>▼</Text>
      </TouchableOpacity>

      <Modal
        animationType="slide"
        transparent={true}
        visible={modalVisible}
        onRequestClose={() => setModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Select Environment</Text>
            
            {ENVIRONMENTS.map((env) => (
              <TouchableOpacity
                key={env.environment}
                style={[
                  styles.envOption,
                  env.environment === currentEnvironment && styles.selectedEnv
                ]}
                onPress={() => handleEnvironmentSelect(env.environment)}
              >
                <View style={styles.envHeader}>
                  <Text style={[
                    styles.envOptionName,
                    env.environment === currentEnvironment && styles.selectedText
                  ]}>
                    {env.name}
                    {env.environment === currentEnvironment && ' ✓'}
                  </Text>
                  <Text style={[
                    styles.envOptionEndpoint,
                    env.environment === currentEnvironment && styles.selectedText
                  ]}>
                    {env.endpoint}
                  </Text>
                </View>
                <Text style={[
                  styles.envDescription,
                  env.environment === currentEnvironment && styles.selectedText
                ]}>
                  {env.description}
                </Text>
              </TouchableOpacity>
            ))}

            <TouchableOpacity
              style={styles.cancelButton}
              onPress={() => setModalVisible(false)}
            >
              <Text style={styles.cancelButtonText}>Cancel</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </>
  );
}

const styles = StyleSheet.create({
  selector: {
    backgroundColor: '#e9ecef',
    padding: 12,
    borderRadius: 8,
    marginBottom: 16,
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#ced4da',
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: '#495057',
    marginRight: 8,
  },
  currentEnv: {
    flex: 1,
  },
  envName: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#007bff',
  },
  envEndpoint: {
    fontSize: 12,
    color: '#6c757d',
    fontFamily: 'monospace',
  },
  arrow: {
    fontSize: 12,
    color: '#6c757d',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContent: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 20,
    margin: 20,
    maxWidth: 400,
    width: '90%',
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 20,
    color: '#333',
  },
  envOption: {
    padding: 16,
    borderRadius: 8,
    marginBottom: 8,
    borderWidth: 1,
    borderColor: '#dee2e6',
  },
  selectedEnv: {
    backgroundColor: '#e3f2fd',
    borderColor: '#007bff',
  },
  envHeader: {
    marginBottom: 4,
  },
  envOptionName: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
  envOptionEndpoint: {
    fontSize: 12,
    color: '#6c757d',
    fontFamily: 'monospace',
  },
  envDescription: {
    fontSize: 14,
    color: '#6c757d',
  },
  selectedText: {
    color: '#007bff',
  },
  cancelButton: {
    backgroundColor: '#6c757d',
    padding: 12,
    borderRadius: 8,
    marginTop: 12,
  },
  cancelButtonText: {
    color: 'white',
    textAlign: 'center',
    fontSize: 16,
    fontWeight: '600',
  },
});
