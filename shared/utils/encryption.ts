// Encryption utilities for Go Mailer SDK

export interface EncryptionConfig {
  algorithm: 'AES-256-GCM' | 'AES-256-CBC';
  keySize: 256;
  ivSize: 16;
  tagSize: 16;
}

export class EncryptionManager {
  private static instance: EncryptionManager;
  private config: EncryptionConfig;
  private key: CryptoKey | null = null;

  private constructor(config: EncryptionConfig) {
    this.config = config;
  }

  public static getInstance(config?: EncryptionConfig): EncryptionManager {
    if (!EncryptionManager.instance) {
      EncryptionManager.instance = new EncryptionManager(
        config || {
          algorithm: 'AES-256-GCM',
          keySize: 256,
          ivSize: 16,
          tagSize: 16,
        }
      );
    }
    return EncryptionManager.instance;
  }

  /**
   * Generate a random encryption key
   */
  public async generateKey(): Promise<CryptoKey> {
    const key = await crypto.subtle.generateKey(
      {
        name: 'AES-GCM',
        length: this.config.keySize,
      },
      true,
      ['encrypt', 'decrypt']
    );
    this.key = key;
    return key;
  }

  /**
   * Import an existing key from raw bytes
   */
  public async importKey(keyData: ArrayBuffer): Promise<CryptoKey> {
    const key = await crypto.subtle.importKey(
      'raw',
      keyData,
      {
        name: 'AES-GCM',
        length: this.config.keySize,
      },
      true,
      ['encrypt', 'decrypt']
    );
    this.key = key;
    return key;
  }

  /**
   * Export the current key as raw bytes
   */
  public async exportKey(): Promise<ArrayBuffer> {
    if (!this.key) {
      throw new Error('No key available for export');
    }
    return await crypto.subtle.exportKey('raw', this.key);
  }

  /**
   * Encrypt data
   */
  public async encrypt(data: string): Promise<string> {
    if (!this.key) {
      throw new Error('No encryption key available');
    }

    const encoder = new TextEncoder();
    const encodedData = encoder.encode(data);

    const iv = crypto.getRandomValues(new Uint8Array(this.config.ivSize));

    const encryptedData = await crypto.subtle.encrypt(
      {
        name: 'AES-GCM',
        iv: iv,
        tagLength: this.config.tagSize * 8,
      },
      this.key,
      encodedData
    );

    // Combine IV and encrypted data
    const combined = new Uint8Array(iv.length + encryptedData.byteLength);
    combined.set(iv);
    combined.set(new Uint8Array(encryptedData), iv.length);

    return btoa(String.fromCharCode(...combined));
  }

  /**
   * Decrypt data
   */
  public async decrypt(encryptedData: string): Promise<string> {
    if (!this.key) {
      throw new Error('No encryption key available');
    }

    const combined = new Uint8Array(
      atob(encryptedData).split('').map(char => char.charCodeAt(0))
    );

    const iv = combined.slice(0, this.config.ivSize);
    const data = combined.slice(this.config.ivSize);

    const decryptedData = await crypto.subtle.decrypt(
      {
        name: 'AES-GCM',
        iv: iv,
        tagLength: this.config.tagSize * 8,
      },
      this.key,
      data
    );

    const decoder = new TextDecoder();
    return decoder.decode(decryptedData);
  }

  /**
   * Hash data using SHA-256
   */
  public async hash(data: string): Promise<string> {
    const encoder = new TextEncoder();
    const encodedData = encoder.encode(data);
    
    const hashBuffer = await crypto.subtle.digest('SHA-256', encodedData);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    
    return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  }

  /**
   * Generate a secure random string
   */
  public generateRandomString(length: number): string {
    const charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    const randomValues = crypto.getRandomValues(new Uint8Array(length));
    
    for (let i = 0; i < length; i++) {
      result += charset[randomValues[i] % charset.length];
    }
    
    return result;
  }

  /**
   * Generate a device fingerprint for security
   */
  public async generateDeviceFingerprint(): Promise<string> {
    const components = [
      navigator.userAgent,
      navigator.language,
      screen.width.toString(),
      screen.height.toString(),
      new Date().getTimezoneOffset().toString(),
    ];
    
    const fingerprint = components.join('|');
    return await this.hash(fingerprint);
  }
}

// Utility functions for common encryption tasks
export const encryptMessage = async (message: string, key: CryptoKey): Promise<string> => {
  const encoder = new TextEncoder();
  const encodedMessage = encoder.encode(message);
  
  const iv = crypto.getRandomValues(new Uint8Array(16));
  
  const encryptedData = await crypto.subtle.encrypt(
    {
      name: 'AES-GCM',
      iv: iv,
      tagLength: 128,
    },
    key,
    encodedMessage
  );
  
  const combined = new Uint8Array(iv.length + encryptedData.byteLength);
  combined.set(iv);
  combined.set(new Uint8Array(encryptedData), iv.length);
  
  return btoa(String.fromCharCode(...combined));
};

export const decryptMessage = async (encryptedMessage: string, key: CryptoKey): Promise<string> => {
  const combined = new Uint8Array(
    atob(encryptedMessage).split('').map(char => char.charCodeAt(0))
  );
  
  const iv = combined.slice(0, 16);
  const data = combined.slice(16);
  
  const decryptedData = await crypto.subtle.decrypt(
    {
      name: 'AES-GCM',
      iv: iv,
      tagLength: 128,
    },
    key,
    data
  );
  
  const decoder = new TextDecoder();
  return decoder.decode(decryptedData);
}; 