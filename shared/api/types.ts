// Shared types for Go Mailer SDK across all platforms

export interface GoMailerConfig {
  apiKey: string;
  baseUrl?: string;
  enableAnalytics?: boolean;
  enableOfflineQueue?: boolean;
  maxRetryAttempts?: number;
  retryDelayMs?: number;
}

export interface User {
  email?: string;
  phone?: string;
  firstName?: string;
  lastName?: string;
  customAttributes?: Record<string, any>;
  tags?: string[];
  createdAt: Date;
  updatedAt: Date;
}

export interface Message {
  id: string;
  title: string;
  body: string;
  type: MessageType;
  priority: MessagePriority;
  data?: Record<string, any>;
  media?: MediaContent[];
  actions?: MessageAction[];
  scheduledAt?: Date;
  expiresAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export enum MessageType {
  PUSH_NOTIFICATION = 'push_notification',
  IN_APP_MESSAGE = 'in_app_message',
  EMAIL = 'email',
  SMS = 'sms'
}

export enum MessagePriority {
  LOW = 'low',
  NORMAL = 'normal',
  HIGH = 'high',
  URGENT = 'urgent'
}

export interface MediaContent {
  type: MediaType;
  url: string;
  altText?: string;
  width?: number;
  height?: number;
}

export enum MediaType {
  IMAGE = 'image',
  VIDEO = 'video',
  AUDIO = 'audio',
  GIF = 'gif'
}

export interface MessageAction {
  id: string;
  title: string;
  type: ActionType;
  url?: string;
  data?: Record<string, any>;
}

export enum ActionType {
  OPEN_URL = 'open_url',
  DEEP_LINK = 'deep_link',
  CUSTOM_ACTION = 'custom_action',
  DISMISS = 'dismiss'
}

export interface PushNotificationPayload {
  title: string;
  body: string;
  data?: Record<string, any>;
  badge?: number;
  sound?: string;
  image?: string;
  actions?: MessageAction[];
}

export interface AnalyticsEvent {
  eventType: AnalyticsEventType;
  messageId?: string;
  email?: string;
  timestamp: Date;
  data?: Record<string, any>;
}

export enum AnalyticsEventType {
  MESSAGE_RECEIVED = 'message_received',
  MESSAGE_OPENED = 'message_opened',
  MESSAGE_DISMISSED = 'message_dismissed',
  ACTION_CLICKED = 'action_clicked',
  PUSH_TOKEN_REGISTERED = 'push_token_registered',
  PUSH_TOKEN_UPDATED = 'push_token_updated',
  SDK_INITIALIZED = 'sdk_initialized',
  ERROR_OCCURRED = 'error_occurred'
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: ApiError;
  message?: string;
}

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, any>;
}

export interface NetworkRequest {
  method: 'GET' | 'POST' | 'PUT' | 'DELETE';
  url: string;
  headers?: Record<string, string>;
  body?: any;
  timeout?: number;
}

export interface NetworkResponse {
  statusCode: number;
  headers: Record<string, string>;
  body: any;
}

export interface StorageItem {
  key: string;
  value: any;
  timestamp: Date;
  expiresAt?: Date;
}

export interface OfflineMessage {
  id: string;
  message: Message;
  email: string;
  createdAt: Date;
  retryCount: number;
  maxRetries: number;
}

export interface LoggerConfig {
  level: LogLevel;
  enableConsole?: boolean;
  enableFile?: boolean;
  maxFileSize?: number;
  maxFiles?: number;
}

export enum LogLevel {
  DEBUG = 'debug',
  INFO = 'info',
  WARN = 'warn',
  ERROR = 'error'
} 