import { API_ENDPOINTS, buildUrl, getDefaultHeaders } from './endpoints';

export interface PushRegistrationPayload {
  deviceToken: string;
  email?: string;
  platform: 'ios' | 'android' | 'flutter' | 'react-native';
  appVersion?: string;
  deviceInfo?: Record<string, any>;
}

export interface PushRegistrationResponse {
  success: boolean;
  message: string;
  registrationId?: string;
  timestamp: string;
}

export class GoMailerAPIClient {
  private baseUrl: string;
  private apiKey: string;

  constructor(baseUrl: string, apiKey: string) {
    this.baseUrl = baseUrl;
    this.apiKey = apiKey;
  }

  /**
   * Register a device token for push notifications
   * @param payload Registration payload including device token and user email
   * @returns Promise with registration response
   */
  async registerPushToken(payload: PushRegistrationPayload): Promise<PushRegistrationResponse> {
    try {
      const url = buildUrl(this.baseUrl, API_ENDPOINTS.PUSH.REGISTER_TOKEN);
      const headers = getDefaultHeaders(this.apiKey);

      // Transform payload to match backend expectations
      const backendPayload = {
        email: payload.email,
        gm_mobi_push: {
          deviceToken: payload.deviceToken,
          platform: payload.platform,
          appVersion: payload.appVersion,
          ...(payload.deviceInfo && { deviceInfo: payload.deviceInfo }),
        },
      };

      const response = await fetch(url, {
        method: 'POST',
        headers,
        body: JSON.stringify(backendPayload),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const result = await response.json();
      return {
        success: true,
        message: 'Device token registered successfully',
        registrationId: result.registrationId,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      console.error('Failed to register push token:', error);
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error occurred',
        timestamp: new Date().toISOString(),
      };
    }
  }

  /**
   * Update an existing push token registration
   * @param payload Updated registration payload
   * @returns Promise with update response
   */
  async updatePushToken(payload: PushRegistrationPayload): Promise<PushRegistrationResponse> {
    try {
      const url = buildUrl(this.baseUrl, API_ENDPOINTS.PUSH.UPDATE_TOKEN);
      const headers = getDefaultHeaders(this.apiKey);

      const response = await fetch(url, {
        method: 'PUT',
        headers,
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const result = await response.json();
      return {
        success: true,
        message: 'Device token updated successfully',
        registrationId: result.registrationId,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      console.error('Failed to update push token:', error);
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error occurred',
        timestamp: new Date().toISOString(),
      };
    }
  }

  /**
   * Unregister a device token
   * @param deviceToken The device token to unregister
   * @param email Optional user email for the unregistration
   * @returns Promise with unregistration response
   */
  async unregisterPushToken(deviceToken: string, email?: string): Promise<PushRegistrationResponse> {
    try {
      const url = buildUrl(this.baseUrl, API_ENDPOINTS.PUSH.UNREGISTER_TOKEN);
      const headers = getDefaultHeaders(this.apiKey);

      const payload = {
        deviceToken,
        ...(email && { email }),
      };

      const response = await fetch(url, {
        method: 'DELETE',
        headers,
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return {
        success: true,
        message: 'Device token unregistered successfully',
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      console.error('Failed to unregister push token:', error);
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error occurred',
        timestamp: new Date().toISOString(),
      };
    }
  }

  /**
   * Send analytics event
   * @param eventName Name of the event
   * @param properties Event properties
   * @param userEmail Optional user email for the event
   * @returns Promise with analytics response
   */
  async trackEvent(
    eventName: string,
    properties?: Record<string, any>,
    userEmail?: string
  ): Promise<{ success: boolean; message: string }> {
    try {
      const url = buildUrl(this.baseUrl, API_ENDPOINTS.ANALYTICS.TRACK_EVENT);
      const headers = getDefaultHeaders(this.apiKey);

      const payload = {
        event: eventName,
        properties: properties || {},
        timestamp: new Date().toISOString(),
        ...(userEmail && { email: userEmail }),
      };

      const response = await fetch(url, {
        method: 'POST',
        headers,
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return {
        success: true,
        message: 'Event tracked successfully',
      };
    } catch (error) {
      console.error('Failed to track event:', error);
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Unknown error occurred',
      };
    }
  }
}

export default GoMailerAPIClient; 