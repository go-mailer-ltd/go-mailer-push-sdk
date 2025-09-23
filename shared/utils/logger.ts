// Logging utilities for Go Mailer SDK

import { LogLevel, LoggerConfig } from '../api/types';

export interface LogEntry {
  level: LogLevel;
  message: string;
  timestamp: Date;
  context?: Record<string, any>;
  error?: Error;
}

export interface LogFormatter {
  format(entry: LogEntry): string;
}

export class ConsoleLogFormatter implements LogFormatter {
  format(entry: LogEntry): string {
    const timestamp = entry.timestamp.toISOString();
    const level = entry.level.toUpperCase().padEnd(5);
    const context = entry.context ? ` ${JSON.stringify(entry.context)}` : '';
    const error = entry.error ? `\n${entry.error.stack}` : '';
    
    return `[${timestamp}] ${level} ${entry.message}${context}${error}`;
  }
}

export class JsonLogFormatter implements LogFormatter {
  format(entry: LogEntry): string {
    return JSON.stringify({
      timestamp: entry.timestamp.toISOString(),
      level: entry.level,
      message: entry.message,
      context: entry.context,
      error: entry.error ? {
        name: entry.error.name,
        message: entry.error.message,
        stack: entry.error.stack
      } : undefined
    });
  }
}

export class Logger {
  private static instance: Logger;
  private config: LoggerConfig;
  private formatter: LogFormatter;
  private logQueue: LogEntry[] = [];
  private maxQueueSize: number = 1000;

  private constructor(config: LoggerConfig) {
    this.config = config;
    this.formatter = config.enableFile ? new JsonLogFormatter() : new ConsoleLogFormatter();
  }

  public static getInstance(config?: LoggerConfig): Logger {
    if (!Logger.instance) {
      Logger.instance = new Logger(
        config || {
          level: LogLevel.INFO,
          enableConsole: true,
          enableFile: false
        }
      );
    }
    return Logger.instance;
  }

  /**
   * Log a debug message
   */
  public debug(message: string, context?: Record<string, any>): void {
    this.log(LogLevel.DEBUG, message, context);
  }

  /**
   * Log an info message
   */
  public info(message: string, context?: Record<string, any>): void {
    this.log(LogLevel.INFO, message, context);
  }

  /**
   * Log a warning message
   */
  public warn(message: string, context?: Record<string, any>): void {
    this.log(LogLevel.WARN, message, context);
  }

  /**
   * Log an error message
   */
  public error(message: string, error?: Error, context?: Record<string, any>): void {
    this.log(LogLevel.ERROR, message, context, error);
  }

  /**
   * Log a message with the specified level
   */
  private log(level: LogLevel, message: string, context?: Record<string, any>, error?: Error): void {
    if (!this.shouldLog(level)) {
      return;
    }

    const entry: LogEntry = {
      level,
      message,
      timestamp: new Date(),
      context,
      error
    };

    this.logQueue.push(entry);

    // Keep queue size manageable
    if (this.logQueue.length > this.maxQueueSize) {
      this.logQueue.shift();
    }

    this.outputLog(entry);
  }

  /**
   * Check if the log level should be output
   */
  private shouldLog(level: LogLevel): boolean {
    const levels = [LogLevel.DEBUG, LogLevel.INFO, LogLevel.WARN, LogLevel.ERROR];
    const configLevelIndex = levels.indexOf(this.config.level);
    const messageLevelIndex = levels.indexOf(level);
    
    return messageLevelIndex >= configLevelIndex;
  }

  /**
   * Output the log entry
   */
  private outputLog(entry: LogEntry): void {
    const formattedMessage = this.formatter.format(entry);

    if (this.config.enableConsole) {
      this.outputToConsole(entry.level, formattedMessage);
    }

    if (this.config.enableFile) {
      this.outputToFile(formattedMessage);
    }
  }

  /**
   * Output to console with appropriate styling
   */
  private outputToConsole(level: LogLevel, message: string): void {
    const colors = {
      [LogLevel.DEBUG]: '\x1b[36m', // Cyan
      [LogLevel.INFO]: '\x1b[32m',  // Green
      [LogLevel.WARN]: '\x1b[33m',  // Yellow
      [LogLevel.ERROR]: '\x1b[31m'  // Red
    };

    const reset = '\x1b[0m';
    const color = colors[level] || '';
    
    console.log(`${color}${message}${reset}`);
  }

  /**
   * Output to file (placeholder for file logging)
   */
  private outputToFile(message: string): void {
    // In a real implementation, this would write to a log file
    // For now, we'll just append to console
    console.log(`[FILE] ${message}`);
  }

  /**
   * Get recent log entries
   */
  public getRecentLogs(count: number = 100): LogEntry[] {
    return this.logQueue.slice(-count);
  }

  /**
   * Clear the log queue
   */
  public clearLogs(): void {
    this.logQueue = [];
  }

  /**
   * Set the log level
   */
  public setLogLevel(level: LogLevel): void {
    this.config.level = level;
  }

  /**
   * Enable or disable console logging
   */
  public setConsoleLogging(enabled: boolean): void {
    this.config.enableConsole = enabled;
  }

  /**
   * Enable or disable file logging
   */
  public setFileLogging(enabled: boolean): void {
    this.config.enableFile = enabled;
    this.formatter = enabled ? new JsonLogFormatter() : new ConsoleLogFormatter();
  }

  /**
   * Create a child logger with additional context
   */
  public child(context: Record<string, any>): ChildLogger {
    return new ChildLogger(this, context);
  }
}

export class ChildLogger {
  constructor(
    private parent: Logger,
    private context: Record<string, any>
  ) {}

  public debug(message: string, additionalContext?: Record<string, any>): void {
    this.parent.debug(message, { ...this.context, ...additionalContext });
  }

  public info(message: string, additionalContext?: Record<string, any>): void {
    this.parent.info(message, { ...this.context, ...additionalContext });
  }

  public warn(message: string, additionalContext?: Record<string, any>): void {
    this.parent.warn(message, { ...this.context, ...additionalContext });
  }

  public error(message: string, error?: Error, additionalContext?: Record<string, any>): void {
    this.parent.error(message, error, { ...this.context, ...additionalContext });
  }
}

// Utility functions for common logging patterns
export const logApiRequest = (logger: Logger, method: string, url: string, data?: any): void => {
  logger.debug('API Request', {
    method,
    url,
    data: data ? JSON.stringify(data) : undefined
  });
};

export const logApiResponse = (logger: Logger, statusCode: number, responseData?: any): void => {
  logger.debug('API Response', {
    statusCode,
    data: responseData ? JSON.stringify(responseData) : undefined
  });
};

export const logError = (logger: Logger, message: string, error: Error, context?: Record<string, any>): void => {
  logger.error(message, error, {
    errorName: error.name,
    errorMessage: error.message,
    ...context
  });
};

export const logPerformance = (logger: Logger, operation: string, duration: number, context?: Record<string, any>): void => {
  logger.debug('Performance', {
    operation,
    durationMs: duration,
    ...context
  });
};

// Create a default logger instance
export const defaultLogger = Logger.getInstance(); 