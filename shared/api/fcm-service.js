// FCM Service using Server Key (Node.js)
const https = require('https');

class FCMService {
  constructor(serverKey) {
    this.serverKey = serverKey;
  }

  /**
   * Send push notification to a single device
   * @param {string} deviceToken - FCM device token
   * @param {object} notification - Notification payload
   * @param {object} data - Data payload (optional)
   * @returns {Promise<object>} - FCM response
   */
  async sendNotification(deviceToken, notification, data = {}) {
    const payload = JSON.stringify({
      to: deviceToken,
      notification: {
        title: notification.title,
        body: notification.body,
        sound: notification.sound || 'default',
        icon: notification.icon || 'ic_notification',
      },
      data: {
        ...data,
        click_action: 'FLUTTER_NOTIFICATION_CLICK', // For Flutter
      }
    });

    return new Promise((resolve, reject) => {
      const options = {
        hostname: 'fcm.googleapis.com',
        port: 443,
        path: '/fcm/send',
        method: 'POST',
        headers: {
          'Authorization': `key=${this.serverKey}`,
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(payload)
        }
      };

      const req = https.request(options, (res) => {
        let data = '';
        
        res.on('data', (chunk) => {
          data += chunk;
        });
        
        res.on('end', () => {
          try {
            const response = JSON.parse(data);
            if (res.statusCode === 200 && response.success === 1) {
              resolve({
                success: true,
                messageId: response.results[0].message_id,
                response: response
              });
            } else {
              reject({
                success: false,
                error: response.results?.[0]?.error || 'Unknown error',
                response: response
              });
            }
          } catch (error) {
            reject({
              success: false,
              error: 'Invalid JSON response',
              rawResponse: data
            });
          }
        });
      });

      req.on('error', (error) => {
        reject({
          success: false,
          error: error.message
        });
      });

      req.write(payload);
      req.end();
    });
  }

  /**
   * Send push notification to multiple devices
   * @param {string[]} deviceTokens - Array of FCM device tokens
   * @param {object} notification - Notification payload
   * @param {object} data - Data payload (optional)
   * @returns {Promise<object>} - FCM response
   */
  async sendMulticast(deviceTokens, notification, data = {}) {
    const payload = JSON.stringify({
      registration_ids: deviceTokens,
      notification: {
        title: notification.title,
        body: notification.body,
        sound: notification.sound || 'default',
        icon: notification.icon || 'ic_notification',
      },
      data: {
        ...data,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      }
    });

    return new Promise((resolve, reject) => {
      const options = {
        hostname: 'fcm.googleapis.com',
        port: 443,
        path: '/fcm/send',
        method: 'POST',
        headers: {
          'Authorization': `key=${this.serverKey}`,
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(payload)
        }
      };

      const req = https.request(options, (res) => {
        let data = '';
        
        res.on('data', (chunk) => {
          data += chunk;
        });
        
        res.on('end', () => {
          try {
            const response = JSON.parse(data);
            resolve({
              success: response.success > 0,
              successCount: response.success,
              failureCount: response.failure,
              response: response
            });
          } catch (error) {
            reject({
              success: false,
              error: 'Invalid JSON response',
              rawResponse: data
            });
          }
        });
      });

      req.on('error', (error) => {
        reject({
          success: false,
          error: error.message
        });
      });

      req.write(payload);
      req.end();
    });
  }

  /**
   * Send notification to a topic
   * @param {string} topic - FCM topic name
   * @param {object} notification - Notification payload
   * @param {object} data - Data payload (optional)
   * @returns {Promise<object>} - FCM response
   */
  async sendToTopic(topic, notification, data = {}) {
    const payload = JSON.stringify({
      to: `/topics/${topic}`,
      notification: {
        title: notification.title,
        body: notification.body,
        sound: notification.sound || 'default',
        icon: notification.icon || 'ic_notification',
      },
      data: {
        ...data,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      }
    });

    return new Promise((resolve, reject) => {
      const options = {
        hostname: 'fcm.googleapis.com',
        port: 443,
        path: '/fcm/send',
        method: 'POST',
        headers: {
          'Authorization': `key=${this.serverKey}`,
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(payload)
        }
      };

      const req = https.request(options, (res) => {
        let data = '';
        
        res.on('data', (chunk) => {
          data += chunk;
        });
        
        res.on('end', () => {
          try {
            const response = JSON.parse(data);
            resolve({
              success: res.statusCode === 200,
              messageId: response.message_id,
              response: response
            });
          } catch (error) {
            reject({
              success: false,
              error: 'Invalid JSON response',
              rawResponse: data
            });
          }
        });
      });

      req.on('error', (error) => {
        reject({
          success: false,
          error: error.message
        });
      });

      req.write(payload);
      req.end();
    });
  }
}

module.exports = FCMService;

// Usage example:
/*
const FCMService = require('./fcm-service');

const fcm = new FCMService('YOUR_FCM_SERVER_KEY_HERE');

// Send to single device
fcm.sendNotification(
  'ePaxeXHZRoGyUnWbMXU2...', // device token
  {
    title: 'Hello from Go-Mailer!',
    body: 'Your notification message here',
    sound: 'default'
  },
  {
    campaign_id: 'welcome_campaign',
    user_id: 'user123'
  }
).then(result => {
  console.log('✅ Notification sent:', result);
}).catch(error => {
  console.error('❌ Failed to send:', error);
});
*/
