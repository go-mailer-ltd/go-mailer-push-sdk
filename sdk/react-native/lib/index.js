"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.GoMailerError = exports.GoMailerLogLevel = void 0;
const react_native_1 = require("react-native");
const GoMailerModule = react_native_1.NativeModules.GoMailerModule;
// Environment endpoints
const ENVIRONMENT_ENDPOINTS = {
    production: 'https://api.go-mailer.com/v1',
    staging: 'https://api.gm-g7.xyz/v1',
    development: 'https://api.gm-g6.xyz/v1',
};
var GoMailerLogLevel;
(function (GoMailerLogLevel) {
    GoMailerLogLevel["DEBUG"] = "debug";
    GoMailerLogLevel["INFO"] = "info";
    GoMailerLogLevel["WARN"] = "warn";
    GoMailerLogLevel["ERROR"] = "error";
})(GoMailerLogLevel = exports.GoMailerLogLevel || (exports.GoMailerLogLevel = {}));
var GoMailerError;
(function (GoMailerError) {
    GoMailerError["NOT_INITIALIZED"] = "NOT_INITIALIZED";
    GoMailerError["INVALID_API_KEY"] = "INVALID_API_KEY";
    GoMailerError["NETWORK_ERROR"] = "NETWORK_ERROR";
    GoMailerError["INVALID_USER"] = "INVALID_USER";
    GoMailerError["PUSH_NOTIFICATION_NOT_AUTHORIZED"] = "PUSH_NOTIFICATION_NOT_AUTHORIZED";
    GoMailerError["DEVICE_TOKEN_NOT_AVAILABLE"] = "DEVICE_TOKEN_NOT_AVAILABLE";
})(GoMailerError = exports.GoMailerError || (exports.GoMailerError = {}));
/**
 * Main Go Mailer SDK class for React Native
 *
 * This SDK provides cross-platform push notification functionality
 * and customer engagement messaging for React Native applications.
 *
 * @version 1.0.0
 */
class GoMailer {
    constructor() {
        this.isInitialized = false;
        this.logLevel = GoMailerLogLevel.INFO;
        this.log('Initializing Go Mailer SDK...', GoMailerLogLevel.DEBUG);
        console.log('🔍 Go Mailer: GoMailerModule:', GoMailerModule);
        console.log('🔍 Go Mailer: GoMailerModule methods:', GoMailerModule ? Object.keys(GoMailerModule) : 'null');
        if (!GoMailerModule) {
            console.warn('Go Mailer: Native module not found. Make sure the native module is properly linked.');
            console.warn('Go Mailer: Available modules:', Object.keys(react_native_1.NativeModules));
            // Create a dummy event emitter to prevent crashes
            this.eventEmitter = new react_native_1.NativeEventEmitter({});
        }
        else {
            console.log('✅ Go Mailer: Native module found!');
            console.log('✅ Go Mailer: Module methods:', Object.keys(GoMailerModule));
            this.eventEmitter = new react_native_1.NativeEventEmitter(GoMailerModule);
        }
    }
    /**
     * Get the singleton instance of Go Mailer
     */
    static getInstance() {
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
    initialize(config) {
        return __awaiter(this, void 0, void 0, function* () {
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
                const finalConfig = Object.assign(Object.assign({ enableAnalytics: true, enableOfflineQueue: true, maxRetryAttempts: 3, retryDelayMs: 1000, logLevel: GoMailerLogLevel.INFO }, config), { // User config overrides defaults
                    baseUrl });
                this.logLevel = finalConfig.logLevel || GoMailerLogLevel.INFO;
                yield GoMailerModule.initialize(finalConfig);
                this.isInitialized = true;
                this.log(`SDK initialized successfully with version ${GoMailer.VERSION}`, GoMailerLogLevel.INFO);
            }
            catch (error) {
                this.log(`Failed to initialize SDK: ${error}`, GoMailerLogLevel.ERROR);
                throw new Error(`Go Mailer: Failed to initialize SDK: ${error}`);
            }
        });
    }
    /**
     * Register for push notifications
     * @param email User's email address that will be sent to the backend along with the device token
     */
    registerForPushNotifications(email) {
        return __awaiter(this, void 0, void 0, function* () {
            this.checkInitialization();
            try {
                yield GoMailerModule.registerForPushNotifications({ email });
            }
            catch (error) {
                console.error('Go Mailer: Failed to register for push notifications:', error);
                throw error;
            }
        });
    }
    /**
     * Set the current user
     * @param user User information
     */
    setUser(user) {
        return __awaiter(this, void 0, void 0, function* () {
            this.checkInitialization();
            try {
                yield GoMailerModule.setUser(user);
            }
            catch (error) {
                console.error('Go Mailer: Failed to set user:', error);
                throw error;
            }
        });
    }
    /**
     * Track an analytics event
     * @param eventName Name of the event
     * @param properties Event properties
     */
    trackEvent(eventName, properties) {
        return __awaiter(this, void 0, void 0, function* () {
            this.checkInitialization();
            try {
                yield GoMailerModule.trackEvent({ eventName, properties });
            }
            catch (error) {
                console.error('Go Mailer: Failed to track event:', error);
            }
        });
    }
    /**
     * Get the current device token
     * @returns Promise with device token
     */
    getDeviceToken() {
        return __awaiter(this, void 0, void 0, function* () {
            this.checkInitialization();
            try {
                const result = yield GoMailerModule.getDeviceToken();
                return (result === null || result === void 0 ? void 0 : result.token) || null;
            }
            catch (error) {
                console.error('Go Mailer: Failed to get device token:', error);
                return null;
            }
        });
    }
    /**
     * Track notification click event
     * This method should be called when the app is opened from a notification
     * @param notificationId The notification ID (from server or auto-generated)
     * @param title The notification title
     * @param body The notification body
     * @param email The user's email address
     */
    trackNotificationClick(notificationId, title, body, email) {
        return __awaiter(this, void 0, void 0, function* () {
            this.checkInitialization();
            try {
                yield GoMailerModule.trackNotificationClick({
                    notificationId,
                    title,
                    body,
                    email
                });
                this.log(`Notification click tracked: ${notificationId}`, GoMailerLogLevel.DEBUG);
            }
            catch (error) {
                this.log(`Failed to track notification click: ${error}`, GoMailerLogLevel.ERROR);
                throw error;
            }
        });
    }
    /**
     * Set custom attributes for the current user
     * @param attributes Dictionary of attributes
     */
    setUserAttributes(attributes) {
        return __awaiter(this, void 0, void 0, function* () {
            this.checkInitialization();
            try {
                yield GoMailerModule.setUserAttributes(attributes);
            }
            catch (error) {
                console.error('Go Mailer: Failed to set user attributes:', error);
                throw error;
            }
        });
    }
    /**
     * Add tags to the current user
     * @param tags Array of tags to add
     */
    addUserTags(tags) {
        return __awaiter(this, void 0, void 0, function* () {
            this.checkInitialization();
            try {
                yield GoMailerModule.addUserTags(tags);
            }
            catch (error) {
                console.error('Go Mailer: Failed to add user tags:', error);
                throw error;
            }
        });
    }
    /**
     * Remove tags from the current user
     * @param tags Array of tags to remove
     */
    removeUserTags(tags) {
        return __awaiter(this, void 0, void 0, function* () {
            this.checkInitialization();
            try {
                yield GoMailerModule.removeUserTags(tags);
            }
            catch (error) {
                console.error('Go Mailer: Failed to remove user tags:', error);
                throw error;
            }
        });
    }
    /**
     * Enable or disable analytics
     * @param enabled Whether analytics should be enabled
     */
    setAnalyticsEnabled(enabled) {
        return __awaiter(this, void 0, void 0, function* () {
            this.checkInitialization();
            try {
                yield GoMailerModule.setAnalyticsEnabled(enabled);
            }
            catch (error) {
                console.error('Go Mailer: Failed to set analytics enabled:', error);
                throw error;
            }
        });
    }
    /**
     * Set the log level
     * @param level Log level to set
     */
    setLogLevel(level) {
        return __awaiter(this, void 0, void 0, function* () {
            this.checkInitialization();
            try {
                yield GoMailerModule.setLogLevel(level);
            }
            catch (error) {
                console.error('Go Mailer: Failed to set log level:', error);
                throw error;
            }
        });
    }
    /**
     * Listen to push notification events
     * @param callback Callback function for push notification events
     * @returns Subscription object
     */
    onPushNotification(callback) {
        return this.eventEmitter.addListener('pushNotification', callback);
    }
    /**
     * Listen to analytics events
     * @param callback Callback function for analytics events
     * @returns Subscription object
     */
    onAnalytics(callback) {
        return this.eventEmitter.addListener('analytics', callback);
    }
    /**
     * Check if SDK is initialized
     */
    checkInitialization() {
        if (!this.isInitialized) {
            throw new Error('Go Mailer SDK not initialized. Call initialize() first.');
        }
    }
    /**
     * Get environment from baseUrl (for debugging/info purposes)
     */
    static getEnvironmentFromUrl(baseUrl) {
        if (baseUrl.includes('go-mailer.com'))
            return 'production';
        if (baseUrl.includes('gm-g7.xyz'))
            return 'staging';
        if (baseUrl.includes('gm-g6.xyz'))
            return 'development';
        return 'custom';
    }
    /**
     * Internal logging method
     * @param message Log message
     * @param level Log level
     */
    log(message, level) {
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
    shouldLog(level) {
        const levels = [GoMailerLogLevel.DEBUG, GoMailerLogLevel.INFO, GoMailerLogLevel.WARN, GoMailerLogLevel.ERROR];
        return levels.indexOf(level) >= levels.indexOf(this.logLevel);
    }
}
/** SDK Version */
GoMailer.VERSION = '1.3.0';
// Export the singleton instance
exports.default = GoMailer.getInstance();
//# sourceMappingURL=index.js.map