// Shared API endpoints for Go Mailer SDK

export const API_ENDPOINTS = {
  // Base URLs
  PRODUCTION: 'https://push.gomailer.com/v1',
  STAGING: 'https://push.gm-g7.xyz/v1',
  TESTING: 'https://push.gm-g6.xyz/v1',
  DEVELOPMENT: 'https://d7e1876f0e1e.ngrok-free.app',

  // Authentication
  AUTH: {
    VALIDATE_API_KEY: '/auth/validate',
    REFRESH_TOKEN: '/auth/refresh',
  },

  // Users
  USERS: {
    CREATE: '/users',
    UPDATE: '/users/:userEmail',
    GET: '/users/:userEmail',
    DELETE: '/users/:userEmail',
    SET_ATTRIBUTES: '/users/:userEmail/attributes',
    ADD_TAGS: '/users/:userEmail/tags',
    REMOVE_TAGS: '/users/:userEmail/tags',
  },

  // Push Notifications
  PUSH: {
    REGISTER_TOKEN: '/push/register',
    UPDATE_TOKEN: '/push/update',
    UNREGISTER_TOKEN: '/push/unregister',
    SEND_MESSAGE: '/push/send',
    BATCH_SEND: '/push/batch-send',
  },

  // Messages
  MESSAGES: {
    SEND: '/messages/send',
    BATCH_SEND: '/messages/batch-send',
    GET_HISTORY: '/messages/history',
    GET_BY_ID: '/messages/:messageId',
    MARK_READ: '/messages/:messageId/read',
    MARK_DELIVERED: '/messages/:messageId/delivered',
  },

  // Analytics
  ANALYTICS: {
    TRACK_EVENT: '/analytics/events',
    BATCH_EVENTS: '/analytics/events/batch',
    GET_USER_STATS: '/analytics/users/:userEmail/stats',
  },

  // Configuration
  CONFIG: {
    GET_SDK_CONFIG: '/config/sdk',
    GET_USER_CONFIG: '/config/users/:userEmail',
  },

  // Health Check
  HEALTH: {
    STATUS: '/health/status',
    PING: '/health/ping',
  },
} as const;

export const buildUrl = (baseUrl: string, endpoint: string, params?: Record<string, string>): string => {
  let url = `${baseUrl}${endpoint}`;
  
  if (params) {
    Object.entries(params).forEach(([key, value]) => {
      url = url.replace(`:${key}`, encodeURIComponent(value));
    });
  }
  
  return url;
};

export const getDefaultHeaders = (apiKey: string): Record<string, string> => ({
  'Content-Type': 'application/json',
  'Authorization': `Bearer ${apiKey}`,
  'User-Agent': 'GoMailer-SDK/1.0.0',
  'Accept': 'application/json',
});

export const getAnalyticsHeaders = (apiKey: string, userEmail?: string): Record<string, string> => ({
  ...getDefaultHeaders(apiKey),
  'X-User-ID': userEmail || '',
  'X-Platform': 'mobile',
  'X-SDK-Version': '1.0.0',
}); 