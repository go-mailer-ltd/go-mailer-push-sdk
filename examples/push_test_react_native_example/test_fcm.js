#!/usr/bin/env node

// Quick FCM test script
// Usage: node test_fcm.js YOUR_SERVER_KEY YOUR_FCM_TOKEN

const https = require('https');

const serverKey = process.argv[2];
const fcmToken = process.argv[3];

if (!serverKey || !fcmToken) {
  console.log('❌ Usage: node test_fcm.js YOUR_SERVER_KEY YOUR_FCM_TOKEN');
  console.log('');
  console.log('📋 Get your Server Key from:');
  console.log('   Firebase Console → Project Settings → Cloud Messaging → Server key');
  console.log('');
  console.log('📱 Get your FCM Token from the Android app logs:');
  console.log('   Look for: "✅ FCM token: ePaxeXHZRoGyUnWbMXU2..."');
  process.exit(1);
}

const payload = JSON.stringify({
  to: fcmToken,
  notification: {
    title: "🚀 Test from Go-Mailer!",
    body: "FCM working on Android emulator! 📱✨",
    sound: "default"
  },
  data: {
    notification_id: "test_123",
    campaign_id: "emulator_test",
    source: "fcm_test_script"
  }
});

const options = {
  hostname: 'fcm.googleapis.com',
  port: 443,
  path: '/fcm/send',
  method: 'POST',
  headers: {
    'Authorization': `key=${serverKey}`,
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(payload)
  }
};

console.log('📤 Sending FCM notification...');
console.log('🎯 Token:', fcmToken.substring(0, 20) + '...');

const req = https.request(options, (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('📨 Response Status:', res.statusCode);
    console.log('📨 Response Body:', data);
    
    if (res.statusCode === 200) {
      const response = JSON.parse(data);
      if (response.success === 1) {
        console.log('✅ Notification sent successfully!');
        console.log('📱 Check your Android emulator for the notification');
      } else {
        console.log('❌ Failed to send notification');
        console.log('🔍 Response:', response);
      }
    } else {
      console.log('❌ HTTP Error:', res.statusCode);
    }
  });
});

req.on('error', (error) => {
  console.error('❌ Request failed:', error);
});

req.write(payload);
req.end();
