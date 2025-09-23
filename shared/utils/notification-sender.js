// Notification Sender for Go-Mailer Backend
const FCMService = require('../api/fcm-service');

class NotificationSender {
  constructor(fcmServerKey) {
    this.fcm = new FCMService(fcmServerKey);
  }

  /**
   * Send welcome notification to new user
   * @param {string} deviceToken - User's FCM token
   * @param {string} email - User's email
   */
  async sendWelcomeNotification(deviceToken, email) {
    try {
      const result = await this.fcm.sendNotification(
        deviceToken,
        {
          title: '🎉 Welcome to Go-Mailer!',
          body: `Hi ${email}! Your account is now set up and ready to go.`,
          sound: 'default'
        },
        {
          notification_type: 'welcome',
          user_email: email,
          campaign_id: 'welcome_campaign'
        }
      );

      console.log('✅ Welcome notification sent:', result);
      return result;
    } catch (error) {
      console.error('❌ Failed to send welcome notification:', error);
      throw error;
    }
  }

  /**
   * Send campaign notification
   * @param {string} deviceToken - User's FCM token
   * @param {object} campaign - Campaign data
   */
  async sendCampaignNotification(deviceToken, campaign) {
    try {
      const result = await this.fcm.sendNotification(
        deviceToken,
        {
          title: campaign.title,
          body: campaign.message,
          sound: 'default'
        },
        {
          notification_type: 'campaign',
          campaign_id: campaign.id,
          campaign_name: campaign.name
        }
      );

      console.log('✅ Campaign notification sent:', result);
      return result;
    } catch (error) {
      console.error('❌ Failed to send campaign notification:', error);
      throw error;
    }
  }

  /**
   * Send bulk notifications to multiple users
   * @param {Array} recipients - Array of {deviceToken, email} objects
   * @param {object} notification - Notification content
   */
  async sendBulkNotifications(recipients, notification) {
    const deviceTokens = recipients.map(r => r.deviceToken);
    
    try {
      const result = await this.fcm.sendMulticast(
        deviceTokens,
        {
          title: notification.title,
          body: notification.body,
          sound: 'default'
        },
        {
          notification_type: 'bulk',
          campaign_id: notification.campaignId || 'bulk_campaign'
        }
      );

      console.log(`✅ Bulk notifications sent: ${result.successCount}/${recipients.length}`);
      return result;
    } catch (error) {
      console.error('❌ Failed to send bulk notifications:', error);
      throw error;
    }
  }

  /**
   * Send notification based on user event
   * @param {string} deviceToken - User's FCM token
   * @param {string} eventType - Type of event (app_opened, button_clicked, etc.)
   * @param {object} eventData - Event data
   */
  async sendEventTriggeredNotification(deviceToken, eventType, eventData) {
    let notification;

    switch (eventType) {
      case 'app_opened':
        notification = {
          title: '👋 Welcome back!',
          body: 'Thanks for using Go-Mailer. Check out what\'s new!',
        };
        break;
      
      case 'user_registered':
        notification = {
          title: '🎉 Registration Complete!',
          body: 'Your Go-Mailer account is ready. Start exploring now!',
        };
        break;
      
      case 'button_clicked':
        notification = {
          title: '🔔 Action Detected',
          body: `You clicked: ${eventData.button}. Here's what happens next...`,
        };
        break;
      
      default:
        console.log(`No notification template for event: ${eventType}`);
        return null;
    }

    try {
      const result = await this.fcm.sendNotification(
        deviceToken,
        {
          ...notification,
          sound: 'default'
        },
        {
          notification_type: 'event_triggered',
          event_type: eventType,
          ...eventData
        }
      );

      console.log(`✅ Event-triggered notification sent for ${eventType}:`, result);
      return result;
    } catch (error) {
      console.error(`❌ Failed to send event notification for ${eventType}:`, error);
      throw error;
    }
  }
}

module.exports = NotificationSender;

// Usage in your backend routes:
/*
const NotificationSender = require('./utils/notification-sender');

// Initialize with your FCM Server Key
const notificationSender = new NotificationSender(process.env.FCM_SERVER_KEY);

// In your contact registration endpoint
app.post('/v1/contacts', async (req, res) => {
  try {
    const { email, deviceToken } = req.body;
    
    // Save contact to database
    await saveContact({ email, deviceToken });
    
    // Send welcome notification
    await notificationSender.sendWelcomeNotification(deviceToken, email);
    
    res.json({ success: true, message: 'Contact registered successfully' });
  } catch (error) {
    console.error('Error registering contact:', error);
    res.status(500).json({ error: 'Failed to register contact' });
  }
});

// In your events endpoint
app.post('/v1/events/push', async (req, res) => {
  try {
    const { eventType, properties, deviceToken } = req.body;
    
    // Save event to database
    await saveEvent({ eventType, properties });
    
    // Send event-triggered notification
    if (deviceToken) {
      await notificationSender.sendEventTriggeredNotification(deviceToken, eventType, properties);
    }
    
    res.json({ success: true, message: 'Event tracked successfully' });
  } catch (error) {
    console.error('Error tracking event:', error);
    res.status(500).json({ error: 'Failed to track event' });
  }
});
*/
