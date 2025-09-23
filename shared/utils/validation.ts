// Validation utilities for Go Mailer SDK

import { GoMailerConfig, User, Message, MessageType, MessagePriority } from '../api/types';

export class ValidationError extends Error {
  constructor(message: string, public field?: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

export class ValidationManager {
  private static instance: ValidationManager;

  private constructor() {}

  public static getInstance(): ValidationManager {
    if (!ValidationManager.instance) {
      ValidationManager.instance = new ValidationManager();
    }
    return ValidationManager.instance;
  }

  /**
   * Validate API key format
   */
  public validateApiKey(apiKey: string): void {
    if (!apiKey || typeof apiKey !== 'string') {
      throw new ValidationError('API key is required and must be a string');
    }

    if (apiKey.length < 32) {
      throw new ValidationError('API key must be at least 32 characters long');
    }

    if (!/^[a-zA-Z0-9_-]+$/.test(apiKey)) {
      throw new ValidationError('API key contains invalid characters');
    }
  }

  /**
   * Validate SDK configuration
   */
  public validateConfig(config: GoMailerConfig): void {
    this.validateApiKey(config.apiKey);

    if (config.baseUrl && !this.isValidUrl(config.baseUrl)) {
      throw new ValidationError('Invalid base URL format', 'baseUrl');
    }

    if (config.maxRetryAttempts !== undefined && (config.maxRetryAttempts < 0 || config.maxRetryAttempts > 10)) {
      throw new ValidationError('Max retry attempts must be between 0 and 10', 'maxRetryAttempts');
    }

    if (config.retryDelayMs !== undefined && (config.retryDelayMs < 1000 || config.retryDelayMs > 60000)) {
      throw new ValidationError('Retry delay must be between 1000ms and 60000ms', 'retryDelayMs');
    }
  }

  /**
   * Validate user data
   */
  public validateUser(user: Partial<User>): void {
    if (user.email && !this.isValidEmail(user.email)) {
      throw new ValidationError('Invalid email format', 'email');
    }

    if (user.phone && !this.isValidPhone(user.phone)) {
      throw new ValidationError('Invalid phone number format', 'phone');
    }

    if (user.firstName && typeof user.firstName !== 'string') {
      throw new ValidationError('First name must be a string', 'firstName');
    }

    if (user.lastName && typeof user.lastName !== 'string') {
      throw new ValidationError('Last name must be a string', 'lastName');
    }

    if (user.customAttributes && typeof user.customAttributes !== 'object') {
      throw new ValidationError('Custom attributes must be an object', 'customAttributes');
    }

    if (user.tags && !Array.isArray(user.tags)) {
      throw new ValidationError('Tags must be an array', 'tags');
    }

    if (user.tags) {
      user.tags.forEach((tag, index) => {
        if (typeof tag !== 'string') {
          throw new ValidationError(`Tag at index ${index} must be a string`, `tags[${index}]`);
        }
        if (tag.length === 0) {
          throw new ValidationError(`Tag at index ${index} cannot be empty`, `tags[${index}]`);
        }
      });
    }
  }

  /**
   * Validate message data
   */
  public validateMessage(message: Partial<Message>): void {
    if (message.title && typeof message.title !== 'string') {
      throw new ValidationError('Message title must be a string', 'title');
    }

    if (message.title && message.title.length === 0) {
      throw new ValidationError('Message title cannot be empty', 'title');
    }

    if (message.title && message.title.length > 100) {
      throw new ValidationError('Message title cannot exceed 100 characters', 'title');
    }

    if (message.body && typeof message.body !== 'string') {
      throw new ValidationError('Message body must be a string', 'body');
    }

    if (message.body && message.body.length === 0) {
      throw new ValidationError('Message body cannot be empty', 'body');
    }

    if (message.body && message.body.length > 4000) {
      throw new ValidationError('Message body cannot exceed 4000 characters', 'body');
    }

    if (message.type && !Object.values(MessageType).includes(message.type)) {
      throw new ValidationError('Invalid message type', 'type');
    }

    if (message.priority && !Object.values(MessagePriority).includes(message.priority)) {
      throw new ValidationError('Invalid message priority', 'priority');
    }

    if (message.data && typeof message.data !== 'object') {
      throw new ValidationError('Message data must be an object', 'data');
    }

    if (message.media && !Array.isArray(message.media)) {
      throw new ValidationError('Message media must be an array', 'media');
    }

    if (message.actions && !Array.isArray(message.actions)) {
      throw new ValidationError('Message actions must be an array', 'actions');
    }

    if (message.scheduledAt && !(message.scheduledAt instanceof Date)) {
      throw new ValidationError('Scheduled date must be a Date object', 'scheduledAt');
    }

    if (message.expiresAt && !(message.expiresAt instanceof Date)) {
      throw new ValidationError('Expiration date must be a Date object', 'expiresAt');
    }
  }

  /**
   * Validate push notification payload
   */
  public validatePushNotificationPayload(payload: any): void {
    if (!payload.title || typeof payload.title !== 'string') {
      throw new ValidationError('Push notification title is required and must be a string', 'title');
    }

    if (payload.title.length === 0) {
      throw new ValidationError('Push notification title cannot be empty', 'title');
    }

    if (payload.title.length > 50) {
      throw new ValidationError('Push notification title cannot exceed 50 characters', 'title');
    }

    if (!payload.body || typeof payload.body !== 'string') {
      throw new ValidationError('Push notification body is required and must be a string', 'body');
    }

    if (payload.body.length === 0) {
      throw new ValidationError('Push notification body cannot be empty', 'body');
    }

    if (payload.body.length > 200) {
      throw new ValidationError('Push notification body cannot exceed 200 characters', 'body');
    }

    if (payload.badge !== undefined && (typeof payload.badge !== 'number' || payload.badge < 0)) {
      throw new ValidationError('Badge must be a non-negative number', 'badge');
    }

    if (payload.sound && typeof payload.sound !== 'string') {
      throw new ValidationError('Sound must be a string', 'sound');
    }

    if (payload.image && !this.isValidUrl(payload.image)) {
      throw new ValidationError('Invalid image URL format', 'image');
    }

    if (payload.data && typeof payload.data !== 'object') {
      throw new ValidationError('Data must be an object', 'data');
    }
  }

  /**
   * Validate device token
   */
  public validateDeviceToken(token: string): void {
    if (!token || typeof token !== 'string') {
      throw new ValidationError('Device token is required and must be a string');
    }

    if (token.length === 0) {
      throw new ValidationError('Device token cannot be empty');
    }

    if (token.length > 200) {
      throw new ValidationError('Device token cannot exceed 200 characters');
    }
  }

  /**
   * Validate URL format
   */
  public isValidUrl(url: string): boolean {
    try {
      new URL(url);
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Validate email format
   */
  public isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  /**
   * Validate phone number format
   */
  public isValidPhone(phone: string): boolean {
    const phoneRegex = /^\+?[1-9]\d{1,14}$/;
    return phoneRegex.test(phone.replace(/[\s\-\(\)]/g, ''));
  }

  /**
   * Sanitize string input
   */
  public sanitizeString(input: string, maxLength: number = 1000): string {
    if (typeof input !== 'string') {
      return '';
    }
    
    // Remove null bytes and control characters
    let sanitized = input.replace(/[\x00-\x1F\x7F]/g, '');
    
    // Trim whitespace
    sanitized = sanitized.trim();
    
    // Limit length
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    
    return sanitized;
  }

  /**
   * Validate and sanitize object properties
   */
  public sanitizeObject(obj: Record<string, any>): Record<string, any> {
    const sanitized: Record<string, any> = {};
    
    for (const [key, value] of Object.entries(obj)) {
      if (typeof key === 'string' && key.length > 0 && key.length <= 50) {
        if (typeof value === 'string') {
          sanitized[key] = this.sanitizeString(value);
        } else if (typeof value === 'number' && isFinite(value)) {
          sanitized[key] = value;
        } else if (typeof value === 'boolean') {
          sanitized[key] = value;
        } else if (value === null) {
          sanitized[key] = null;
        }
      }
    }
    
    return sanitized;
  }
} 