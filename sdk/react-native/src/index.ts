import { NativeModules, NativeEventEmitter } from 'react-native';

const GoMailerModule = NativeModules.GoMailerModule;

export type GoMailerEnvironment = 'production' | 'staging' | 'development';

export interface GoMailerConfig {
  apiKey: string;
  baseUrl?: string;
  environment?: GoMailerEnvironment;
  enableAnalytics?: boolean;
  enableOfflineQueue?: boolean;
  maxRetryAttempts?: number;
  retryDelayMs?: number;
  logLevel?: GoMailerLogLevel;
}

// Environment endpoints
const ENVIRONMENT_ENDPOINTS: Record<GoMailerEnvironment, string> = {
  production: 'https://api.go-mailer.com/v1',
  staging: 'https://api.gm-g7.xyz/v1',
  development: 'https://api.gm-g6.xyz/v1',
};

export interface GoMailerUser {
  email?: string;
  phone?: string;
  firstName?: string;
  lastName?: string;
  customAttributes?: Record<string, any>;
  tags?: string[];
}

export enum GoMailerLogLevel {
  DEBUG = 'debug',
  INFO = 'info',
  WARN = 'warn',
  ERROR = 'error'
}

export enum GoMailerError {
  NOT_INITIALIZED = 'NOT_INITIALIZED',
  INVALID_API_KEY = 'INVALID_API_KEY',
  NETWORK_ERROR = 'NETWORK_ERROR',
  INVALID_USER = 'INVALID_USER',
  PUSH_NOTIFICATION_NOT_AUTHORIZED = 'PUSH_NOTIFICATION_NOT_AUTHORIZED',
  DEVICE_TOKEN_NOT_AVAILABLE = 'DEVICE_TOKEN_NOT_AVAILABLE'
}

/**
 * Main Go Mailer SDK class for React Native
 * 
 * This SDK provides cross-platform push notification functionality
 * and customer engagement messaging for React Native applications.
 * 
 * @version 1.0.0
 */
class GoMailer {
  private static instance: GoMailer;
  private isInitialized = false;
  private eventEmitter: NativeEventEmitter;
  private logLevel: GoMailerLogLevel = GoMailerLogLevel.INFO;

  /** SDK Version */
  public static readonly VERSION = '1.0.0';

  constructor() {
    this.log('Initializing Go Mailer SDK...', GoMailerLogLevel.DEBUG);
    console.log('🔍 Go Mailer: GoMailerModule:', GoMailerModule);
    console.log('🔍 Go Mailer: GoMailerModule methods:', GoMailerModule ? Object.keys(GoMailerModule) : 'null');
    
    if (!GoMailerModule) {
      console.warn('Go Mailer: Native module not found. Make sure the native module is properly linked.');
      console.warn('Go Mailer: Available modules:', Object.keys(NativeModules));
      // Create a dummy event emitter to prevent crashes
      this.eventEmitter = new NativeEventEmitter({} as any);
    } else {
      console.log('✅ Go Mailer: Native module found!');
      console.log('✅ Go Mailer: Module methods:', Object.keys(GoMailerModule));
      this.eventEmitter = new NativeEventEmitter(GoMailerModule);
    }
  }

  /**
   * Get the singleton instance of Go Mailer
   */
  static getInstance(): GoMailer {
    if (!GoMailer.instance) {
      GoMailer.instance = new GoMailer();
    }
    return GoMailer.instance;
  }

  /**
   * Initialize the Go Mailer SDK
   * @param config Configuration object
   * @throws {Error} If initialization fails or native module is not found
   */
  async initialize(config: GoMailerConfig): Promise<void> {
    if (this.isInitialized) {
      this.log('SDK already initialized', GoMailerLogLevel.DEBUG);
      return;
    }

    if (!config.apiKey || config.apiKey.trim() === '') {
      throw new Error('Go Mailer: API key is required');
    }

    if (!GoMailerModule) {
      throw new Error('Go Mailer: Native module not found. Make sure the native module is properly linked.');
    }

    try {
      // Determine baseUrl from environment or explicit baseUrl
      let baseUrl = config.baseUrl;
      if (!baseUrl && config.environment) {
        baseUrl = ENVIRONMENT_ENDPOINTS[config.environment];
      }
      if (!baseUrl) {
        baseUrl = 'https://api.go-mailer.com/v1'; // Default to production
      }

      // Set production defaults
      const finalConfig: GoMailerConfig = {
        baseUrl,
        enableAnalytics: true,
        enableOfflineQueue: true,
        maxRetryAttempts: 3,
        retryDelayMs: 1000,
        logLevel: GoMailerLogLevel.INFO,
        ...config, // User config overrides defaults
        baseUrl, // Ensure computed baseUrl is used
      };

      this.logLevel = finalConfig.logLevel || GoMailerLogLevel.INFO;

      await GoMailerModule.initialize(finalConfig);
      this.isInitialized = true;
      this.log(`SDK initialized successfully with version ${GoMailer.VERSION}`, GoMailerLogLevel.INFO);
    } catch (error) {
      this.log(`Failed to initialize SDK: ${error}`, GoMailerLogLevel.ERROR);
      throw new Error(`Go Mailer: Failed to initialize SDK: ${error}`);
    }
  }

  /**
   * Register for push notifications
   * @param email User's email address that will be sent to the backend along with the device token
   */
  async registerForPushNotifications(email?: string): Promise<void> {
    this.checkInitialization();
    try {
      await GoMailerModule.registerForPushNotifications({ email });
    } catch (error) {
      console.error('Go Mailer: Failed to register for push notifications:', error);
      throw error;
    }
  }

  /**
   * Set the current user
   * @param user User information
   */
  async setUser(user: GoMailerUser): Promise<void> {
    this.checkInitialization();
    try {
      await GoMailerModule.setUser(user);
    } catch (error) {
      console.error('Go Mailer: Failed to set user:', error);
      throw error;
    }
  }

  /**
   * Track an analytics event
   * @param eventName Name of the event
   * @param properties Event properties
   */
  async trackEvent(eventName: string, properties?: Record<string, any>): Promise<void> {
    this.checkInitialization();
    try {
      await GoMailerModule.trackEvent({ eventName, properties });
    } catch (error) {
      console.error('Go Mailer: Failed to track event:', error);
    }
  }

  /**
   * Get the current device token
   * @returns Promise with device token
   */
  async getDeviceToken(): Promise<string | null> {
    this.checkInitialization();
    try {
      const result = await GoMailerModule.getDeviceToken();
      return result?.token || null;
    } catch (error) {
      console.error('Go Mailer: Failed to get device token:', error);
      return null;
    }
  }

  /**
   * Track notification click event
   * This method should be called when the app is opened from a notification
   * @param notificationId The notification ID (from server or auto-generated)
   * @param title The notification title
   * @param body The notification body
   * @param email The user's email address
   */
  async trackNotificationClick(notificationId: string, title: string, body: string, email?: string): Promise<void> {
    this.checkInitialization();
    try {
      await GoMailerModule.trackNotificationClick({ 
        notificationId, 
        title, 
        body, 
        email 
      });
      this.log(`Notification click tracked: ${notificationId}`, GoMailerLogLevel.DEBUG);
    } catch (error) {
      this.log(`Failed to track notification click: ${error}`, GoMailerLogLevel.ERROR);
      throw error;
    }
  }

  /**
   * Set custom attributes for the current user
   * @param attributes Dictionary of attributes
   */
  async setUserAttributes(attributes: Record<string, any>): Promise<void> {
    this.checkInitialization();
    try {
      await GoMailerModule.setUserAttributes(attributes);
    } catch (error) {
      console.error('Go Mailer: Failed to set user attributes:', error);
      throw error;
    }
  }

  /**
   * Add tags to the current user
   * @param tags Array of tags to add
   */
  async addUserTags(tags: string[]): Promise<void> {
    this.checkInitialization();
    try {
      await GoMailerModule.addUserTags(tags);
    } catch (error) {
      console.error('Go Mailer: Failed to add user tags:', error);
      throw error;
    }
  }

  /**
   * Remove tags from the current user
   * @param tags Array of tags to remove
   */
  async removeUserTags(tags: string[]): Promise<void> {
    this.checkInitialization();
    try {
      await GoMailerModule.removeUserTags(tags);
    } catch (error) {
      console.error('Go Mailer: Failed to remove user tags:', error);
      throw error;
    }
  }

  /**
   * Enable or disable analytics
   * @param enabled Whether analytics should be enabled
   */
  async setAnalyticsEnabled(enabled: boolean): Promise<void> {
    this.checkInitialization();
    try {
      await GoMailerModule.setAnalyticsEnabled(enabled);
    } catch (error) {
      console.error('Go Mailer: Failed to set analytics enabled:', error);
      throw error;
    }
  }

  /**
   * Set the log level
   * @param level Log level to set
   */
  async setLogLevel(level: GoMailerLogLevel): Promise<void> {
    this.checkInitialization();
    try {
      await GoMailerModule.setLogLevel(level);
    } catch (error) {
      console.error('Go Mailer: Failed to set log level:', error);
      throw error;
    }
  }

  /**
   * Listen to push notification events
   * @param callback Callback function for push notification events
   * @returns Subscription object
   */
  onPushNotification(callback: (event: Record<string, any>) => void) {
    return this.eventEmitter.addListener('pushNotification', callback);
  }

  /**
   * Listen to analytics events
   * @param callback Callback function for analytics events
   * @returns Subscription object
   */
  onAnalytics(callback: (event: Record<string, any>) => void) {
    return this.eventEmitter.addListener('analytics', callback);
  }

  /**
   * Check if SDK is initialized
   */
  private checkInitialization(): void {
    if (!this.isInitialized) {
      throw new Error('Go Mailer SDK not initialized. Call initialize() first.');
    }
  }

  /**
   * Get environment from baseUrl (for debugging/info purposes)
   */
  static getEnvironmentFromUrl(baseUrl: string): GoMailerEnvironment | 'custom' {
    if (baseUrl.includes('go-mailer.com')) return 'production';
    if (baseUrl.includes('gm-g7.xyz')) return 'staging';
    if (baseUrl.includes('gm-g6.xyz')) return 'development';
    return 'custom';
  }

  /**
   * Internal logging method
   * @param message Log message
   * @param level Log level
   */
  private log(message: string, level: GoMailerLogLevel): void {
    const shouldLog = this.shouldLog(level);
    
    if (shouldLog) {
      const prefix = level === GoMailerLogLevel.ERROR ? '❌' : 
                    level === GoMailerLogLevel.WARN ? '⚠️' : 
                    level === GoMailerLogLevel.DEBUG ? '🔍' : '📱';
      
      const logMessage = `Go Mailer ${prefix}: ${message}`;
      
      switch (level) {
        case GoMailerLogLevel.ERROR:
          console.error(logMessage);
          break;
        case GoMailerLogLevel.WARN:
          console.warn(logMessage);
          break;
        case GoMailerLogLevel.DEBUG:
          console.debug(logMessage);
          break;
        default:
          console.log(logMessage);
      }
    }
  }

  /**
   * Check if should log based on current log level
   * @param level Log level to check
   * @returns Whether should log
   */
  private shouldLog(level: GoMailerLogLevel): boolean {
    const levels = [GoMailerLogLevel.DEBUG, GoMailerLogLevel.INFO, GoMailerLogLevel.WARN, GoMailerLogLevel.ERROR];
    return levels.indexOf(level) >= levels.indexOf(this.logLevel);
  }
}

// Export the singleton instance
export default GoMailer.getInstance(); 