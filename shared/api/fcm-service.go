// FCM Service using Server Key (Go)
package api

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type FCMService struct {
	ServerKey string
	Client    *http.Client
}

type FCMNotification struct {
	Title string `json:"title"`
	Body  string `json:"body"`
	Sound string `json:"sound,omitempty"`
	Icon  string `json:"icon,omitempty"`
}

type FCMMessage struct {
	To           string          `json:"to,omitempty"`
	Tokens       []string        `json:"registration_ids,omitempty"`
	Topic        string          `json:"to,omitempty"` // For topics, use "/topics/topic_name"
	Notification FCMNotification `json:"notification"`
	Data         map[string]string `json:"data,omitempty"`
}

type FCMResponse struct {
	MulticastID  int64 `json:"multicast_id"`
	Success      int   `json:"success"`
	Failure      int   `json:"failure"`
	CanonicalIDs int   `json:"canonical_ids"`
	Results      []struct {
		MessageID string `json:"message_id,omitempty"`
		Error     string `json:"error,omitempty"`
	} `json:"results,omitempty"`
	MessageID int64  `json:"message_id,omitempty"`
	Error     string `json:"error,omitempty"`
}

// NewFCMService creates a new FCM service instance
func NewFCMService(serverKey string) *FCMService {
	return &FCMService{
		ServerKey: serverKey,
		Client:    &http.Client{},
	}
}

// SendNotification sends a push notification to a single device
func (f *FCMService) SendNotification(deviceToken string, notification FCMNotification, data map[string]string) (*FCMResponse, error) {
	message := FCMMessage{
		To:           deviceToken,
		Notification: notification,
		Data:         data,
	}

	if message.Data == nil {
		message.Data = make(map[string]string)
	}
	message.Data["click_action"] = "FLUTTER_NOTIFICATION_CLICK"

	return f.sendMessage(message)
}

// SendMulticast sends a push notification to multiple devices
func (f *FCMService) SendMulticast(deviceTokens []string, notification FCMNotification, data map[string]string) (*FCMResponse, error) {
	message := FCMMessage{
		Tokens:       deviceTokens,
		Notification: notification,
		Data:         data,
	}

	if message.Data == nil {
		message.Data = make(map[string]string)
	}
	message.Data["click_action"] = "FLUTTER_NOTIFICATION_CLICK"

	return f.sendMessage(message)
}

// SendToTopic sends a push notification to a topic
func (f *FCMService) SendToTopic(topic string, notification FCMNotification, data map[string]string) (*FCMResponse, error) {
	message := FCMMessage{
		Topic:        fmt.Sprintf("/topics/%s", topic),
		Notification: notification,
		Data:         data,
	}

	if message.Data == nil {
		message.Data = make(map[string]string)
	}
	message.Data["click_action"] = "FLUTTER_NOTIFICATION_CLICK"

	return f.sendMessage(message)
}

// sendMessage sends the FCM message
func (f *FCMService) sendMessage(message FCMMessage) (*FCMResponse, error) {
	// Set default values
	if message.Notification.Sound == "" {
		message.Notification.Sound = "default"
	}
	if message.Notification.Icon == "" {
		message.Notification.Icon = "ic_notification"
	}

	// Convert message to JSON
	jsonData, err := json.Marshal(message)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal FCM message: %w", err)
	}

	// Create HTTP request
	req, err := http.NewRequest("POST", "https://fcm.googleapis.com/fcm/send", bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("failed to create HTTP request: %w", err)
	}

	// Set headers
	req.Header.Set("Authorization", fmt.Sprintf("key=%s", f.ServerKey))
	req.Header.Set("Content-Type", "application/json")

	// Send request
	resp, err := f.Client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to send FCM request: %w", err)
	}
	defer resp.Body.Close()

	// Read response
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read FCM response: %w", err)
	}

	// Parse response
	var fcmResp FCMResponse
	if err := json.Unmarshal(body, &fcmResp); err != nil {
		return nil, fmt.Errorf("failed to unmarshal FCM response: %w", err)
	}

	// Check for errors
	if resp.StatusCode != http.StatusOK {
		return &fcmResp, fmt.Errorf("FCM request failed with status %d: %s", resp.StatusCode, string(body))
	}

	return &fcmResp, nil
}

// Usage example:
/*
package main

import (
	"fmt"
	"log"
)

func main() {
	// Initialize FCM service
	fcm := NewFCMService("YOUR_FCM_SERVER_KEY_HERE")

	// Send notification to single device
	resp, err := fcm.SendNotification(
		"ePaxeXHZRoGyUnWbMXU2...", // device token
		FCMNotification{
			Title: "Hello from Go-Mailer!",
			Body:  "Your notification message here",
			Sound: "default",
		},
		map[string]string{
			"campaign_id": "welcome_campaign",
			"user_id":     "user123",
		},
	)

	if err != nil {
		log.Printf("❌ Failed to send notification: %v", err)
		return
	}

	if resp.Success > 0 {
		fmt.Printf("✅ Notification sent successfully! Message ID: %v\n", resp.Results[0].MessageID)
	} else {
		fmt.Printf("❌ Failed to send notification: %s\n", resp.Results[0].Error)
	}
}
*/
