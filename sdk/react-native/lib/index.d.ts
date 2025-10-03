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
export interface GoMailerUser {
    email?: string;
    phone?: string;
    firstName?: string;
    lastName?: string;
    customAttributes?: Record<string, any>;
    tags?: string[];
}
export declare enum GoMailerLogLevel {
    DEBUG = "debug",
    INFO = "info",
    WARN = "warn",
    ERROR = "error"
}
export declare enum GoMailerError {
    NOT_INITIALIZED = "NOT_INITIALIZED",
    INVALID_API_KEY = "INVALID_API_KEY",
    NETWORK_ERROR = "NETWORK_ERROR",
    INVALID_USER = "INVALID_USER",
    PUSH_NOTIFICATION_NOT_AUTHORIZED = "PUSH_NOTIFICATION_NOT_AUTHORIZED",
    DEVICE_TOKEN_NOT_AVAILABLE = "DEVICE_TOKEN_NOT_AVAILABLE"
}
/**
 * Main Go Mailer SDK class for React Native
 *
 * This SDK provides cross-platform push notification functionality
 * and customer engagement messaging for React Native applications.
 *
 * @version 1.0.0
 */
declare class GoMailer {
    private static instance;
    private isInitialized;
    private eventEmitter;
    private logLevel;
    /** SDK Version */
    static readonly VERSION = "1.3.0";
    constructor();
    /**
     * Get the singleton instance of Go Mailer
     */
    static getInstance(): GoMailer;
    /**
     * Initialize the Go Mailer SDK
     * @param config Configuration object
     * @throws {Error} If initialization fails or native module is not found
     */
    initialize(config: GoMailerConfig): Promise<void>;
    /**
     * Register for push notifications
     * @param email User's email address that will be sent to the backend along with the device token
     */
    registerForPushNotifications(email?: string): Promise<void>;
    /**
     * Set the current user
     * @param user User information
     */
    setUser(user: GoMailerUser): Promise<void>;
    /**
     * Track an analytics event
     * @param eventName Name of the event
     * @param properties Event properties
     */
    trackEvent(eventName: string, properties?: Record<string, any>): Promise<void>;
    /**
     * Get the current device token
     * @returns Promise with device token
     */
    getDeviceToken(): Promise<string | null>;
    /**
     * Track notification click event
     * This method should be called when the app is opened from a notification
     * @param notificationId The notification ID (from server or auto-generated)
     * @param title The notification title
     * @param body The notification body
     * @param email The user's email address
     */
    trackNotificationClick(notificationId: string, title: string, body: string, email?: string): Promise<void>;
    /**
     * Set custom attributes for the current user
     * @param attributes Dictionary of attributes
     */
    setUserAttributes(attributes: Record<string, any>): Promise<void>;
    /**
     * Add tags to the current user
     * @param tags Array of tags to add
     */
    addUserTags(tags: string[]): Promise<void>;
    /**
     * Remove tags from the current user
     * @param tags Array of tags to remove
     */
    removeUserTags(tags: string[]): Promise<void>;
    /**
     * Enable or disable analytics
     * @param enabled Whether analytics should be enabled
     */
    setAnalyticsEnabled(enabled: boolean): Promise<void>;
    /**
     * Set the log level
     * @param level Log level to set
     */
    setLogLevel(level: GoMailerLogLevel): Promise<void>;
    /**
     * Listen to push notification events
     * @param callback Callback function for push notification events
     * @returns Subscription object
     */
    onPushNotification(callback: (event: Record<string, any>) => void): import("react-native").EmitterSubscription;
    /**
     * Listen to analytics events
     * @param callback Callback function for analytics events
     * @returns Subscription object
     */
    onAnalytics(callback: (event: Record<string, any>) => void): import("react-native").EmitterSubscription;
    /**
     * Check if SDK is initialized
     */
    private checkInitialization;
    /**
     * Get environment from baseUrl (for debugging/info purposes)
     */
    static getEnvironmentFromUrl(baseUrl: string): GoMailerEnvironment | 'custom';
    /**
     * Internal logging method
     * @param message Log message
     * @param level Log level
     */
    private log;
    /**
     * Check if should log based on current log level
     * @param level Log level to check
     * @returns Whether should log
     */
    private shouldLog;
}
declare const _default: GoMailer;
export default _default;
//# sourceMappingURL=index.d.ts.map