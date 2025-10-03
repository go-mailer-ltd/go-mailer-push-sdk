//
//  TestViewController.swift
//  GoMailerExample
//
//  Created by GoMailer Team on 10/03/2025.
//  Copyright © 2025 GoMailer Ltd. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    
    // Configuration Card
    private let configCardView = UIView()
    private let configTitleLabel = UILabel()
    private let apiKeyLabel = UILabel()
    private let environmentLabel = UILabel()
    private let deviceTokenLabel = UILabel()
    private let deviceTokenValueLabel = UILabel()
    
    // Email Input Card
    private let emailCardView = UIView()
    private let emailTitleLabel = UILabel()
    private let emailTextField = UITextField()
    
    // Action Buttons
    private let sendTestButton = UIButton(type: .system)
    private let changeEnvironmentButton = UIButton(type: .system)
    
    // Status Messages
    private let successCardView = UIView()
    private let successIconImageView = UIImageView()
    private let successMessageLabel = UILabel()
    
    private let errorCardView = UIView()
    private let errorIconImageView = UIImageView()
    private let errorMessageLabel = UILabel()
    
    // Activity Logs
    private let logsCardView = UIView()
    private let logsTitleLabel = UILabel()
    private let clearLogsButton = UIButton(type: .system)
    private let logsTextView = UITextView()
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Properties
    
    private let apiKey: String
    private let environment: GoMailerEnvironment
    private var goMailerClient: GoMailerClient
    private var deviceToken: String?
    
    // MARK: - Initialization
    
    init(apiKey: String, environment: GoMailerEnvironment) {
        self.apiKey = apiKey
        self.environment = environment
        self.goMailerClient = GoMailerClient(apiKey: apiKey, environment: environment)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupNotificationObservers()
        updateConfigurationInfo()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        navigationItem.title = "Test Notifications"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        setupHeaderViews()
        setupConfigurationCard()
        setupEmailCard()
        setupActionButtons()
        setupStatusCards()
        setupLogsCard()
    }
    
    private func setupHeaderViews() {
        // Configure logo
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(systemName: "bell.fill")
        logoImageView.tintColor = UIColor.systemBlue
        logoImageView.contentMode = .scaleAspectFit
        contentView.addSubview(logoImageView)
        
        // Configure title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Test Notifications"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.label
        contentView.addSubview(titleLabel)
    }
    
    private func setupConfigurationCard() {
        configCardView.translatesAutoresizingMaskIntoConstraints = false
        configCardView.backgroundColor = UIColor.secondarySystemGroupedBackground
        configCardView.layer.cornerRadius = 12
        configCardView.layer.shadowColor = UIColor.black.cgColor
        configCardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        configCardView.layer.shadowOpacity = 0.1
        configCardView.layer.shadowRadius = 3
        contentView.addSubview(configCardView)
        
        configTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        configTitleLabel.text = "📋 Current Configuration"
        configTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        configTitleLabel.textColor = UIColor.label
        configCardView.addSubview(configTitleLabel)
        
        apiKeyLabel.translatesAutoresizingMaskIntoConstraints = false
        apiKeyLabel.font = UIFont.systemFont(ofSize: 14)
        apiKeyLabel.textColor = UIColor.label
        apiKeyLabel.numberOfLines = 0
        configCardView.addSubview(apiKeyLabel)
        
        environmentLabel.translatesAutoresizingMaskIntoConstraints = false
        environmentLabel.font = UIFont.systemFont(ofSize: 14)
        environmentLabel.textColor = UIColor.label
        configCardView.addSubview(environmentLabel)
        
        deviceTokenLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceTokenLabel.text = "📱 Device Token:"
        deviceTokenLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        deviceTokenLabel.textColor = UIColor.label
        deviceTokenLabel.isHidden = true
        configCardView.addSubview(deviceTokenLabel)
        
        deviceTokenValueLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceTokenValueLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        deviceTokenValueLabel.textColor = UIColor.secondaryLabel
        deviceTokenValueLabel.numberOfLines = 0
        deviceTokenValueLabel.isHidden = true
        configCardView.addSubview(deviceTokenValueLabel)
    }
    
    private func setupEmailCard() {
        emailCardView.translatesAutoresizingMaskIntoConstraints = false
        emailCardView.backgroundColor = UIColor.secondarySystemGroupedBackground
        emailCardView.layer.cornerRadius = 12
        emailCardView.layer.shadowColor = UIColor.black.cgColor
        emailCardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        emailCardView.layer.shadowOpacity = 0.1
        emailCardView.layer.shadowRadius = 3
        contentView.addSubview(emailCardView)
        
        emailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTitleLabel.text = "Recipient Details"
        emailTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        emailTitleLabel.textColor = UIColor.label
        emailCardView.addSubview(emailTitleLabel)
        
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.placeholder = "Enter email address"
        emailTextField.text = "nathan+ios@go-mailer.com"
        emailTextField.borderStyle = .roundedRect
        emailTextField.backgroundColor = UIColor.tertiarySystemGroupedBackground
        emailTextField.font = UIFont.systemFont(ofSize: 16)
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailCardView.addSubview(emailTextField)
    }
    
    private func setupActionButtons() {
        sendTestButton.translatesAutoresizingMaskIntoConstraints = false
        sendTestButton.setTitle("📧 Send Test Notification", for: .normal)
        sendTestButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        sendTestButton.backgroundColor = UIColor.systemBlue
        sendTestButton.setTitleColor(.white, for: .normal)
        sendTestButton.layer.cornerRadius = 12
        contentView.addSubview(sendTestButton)
        
        changeEnvironmentButton.translatesAutoresizingMaskIntoConstraints = false
        changeEnvironmentButton.setTitle("⚙️ Change Environment", for: .normal)
        changeEnvironmentButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        changeEnvironmentButton.setTitleColor(UIColor.systemBlue, for: .normal)
        changeEnvironmentButton.backgroundColor = UIColor.clear
        changeEnvironmentButton.layer.borderWidth = 1
        changeEnvironmentButton.layer.borderColor = UIColor.systemBlue.cgColor
        changeEnvironmentButton.layer.cornerRadius = 12
        contentView.addSubview(changeEnvironmentButton)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        contentView.addSubview(activityIndicator)
    }
    
    private func setupStatusCards() {
        // Success card
        successCardView.translatesAutoresizingMaskIntoConstraints = false
        successCardView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        successCardView.layer.cornerRadius = 12
        successCardView.isHidden = true
        contentView.addSubview(successCardView)
        
        successIconImageView.translatesAutoresizingMaskIntoConstraints = false
        successIconImageView.image = UIImage(systemName: "checkmark.circle.fill")
        successIconImageView.tintColor = UIColor.systemGreen
        successCardView.addSubview(successIconImageView)
        
        successMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        successMessageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        successMessageLabel.textColor = UIColor.systemGreen
        successMessageLabel.numberOfLines = 0
        successCardView.addSubview(successMessageLabel)
        
        // Error card
        errorCardView.translatesAutoresizingMaskIntoConstraints = false
        errorCardView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        errorCardView.layer.cornerRadius = 12
        errorCardView.isHidden = true
        contentView.addSubview(errorCardView)
        
        errorIconImageView.translatesAutoresizingMaskIntoConstraints = false
        errorIconImageView.image = UIImage(systemName: "exclamationmark.circle.fill")
        errorIconImageView.tintColor = UIColor.systemRed
        errorCardView.addSubview(errorIconImageView)
        
        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        errorMessageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        errorMessageLabel.textColor = UIColor.systemRed
        errorMessageLabel.numberOfLines = 0
        errorCardView.addSubview(errorMessageLabel)
    }
    
    private func setupLogsCard() {
        logsCardView.translatesAutoresizingMaskIntoConstraints = false
        logsCardView.backgroundColor = UIColor.secondarySystemGroupedBackground
        logsCardView.layer.cornerRadius = 12
        logsCardView.layer.shadowColor = UIColor.black.cgColor
        logsCardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        logsCardView.layer.shadowOpacity = 0.1
        logsCardView.layer.shadowRadius = 3
        contentView.addSubview(logsCardView)
        
        logsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        logsTitleLabel.text = "Activity Logs"
        logsTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        logsTitleLabel.textColor = UIColor.label
        logsCardView.addSubview(logsTitleLabel)
        
        clearLogsButton.translatesAutoresizingMaskIntoConstraints = false
        clearLogsButton.setTitle("Clear", for: .normal)
        clearLogsButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        clearLogsButton.setTitleColor(.white, for: .normal)
        clearLogsButton.backgroundColor = UIColor.systemRed
        clearLogsButton.layer.cornerRadius = 8
        logsCardView.addSubview(clearLogsButton)
        
        logsTextView.translatesAutoresizingMaskIntoConstraints = false
        logsTextView.backgroundColor = UIColor.tertiarySystemGroupedBackground
        logsTextView.layer.cornerRadius = 8
        logsTextView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        logsTextView.textColor = UIColor.label
        logsTextView.isEditable = false
        logsCardView.addSubview(logsTextView)
    }
    
    // MARK: - Constraints Setup
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Logo
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Configuration card
            configCardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            configCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            configCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            configTitleLabel.topAnchor.constraint(equalTo: configCardView.topAnchor, constant: 16),
            configTitleLabel.leadingAnchor.constraint(equalTo: configCardView.leadingAnchor, constant: 16),
            configTitleLabel.trailingAnchor.constraint(equalTo: configCardView.trailingAnchor, constant: -16),
            
            apiKeyLabel.topAnchor.constraint(equalTo: configTitleLabel.bottomAnchor, constant: 8),
            apiKeyLabel.leadingAnchor.constraint(equalTo: configCardView.leadingAnchor, constant: 16),
            apiKeyLabel.trailingAnchor.constraint(equalTo: configCardView.trailingAnchor, constant: -16),
            
            environmentLabel.topAnchor.constraint(equalTo: apiKeyLabel.bottomAnchor, constant: 4),
            environmentLabel.leadingAnchor.constraint(equalTo: configCardView.leadingAnchor, constant: 16),
            environmentLabel.trailingAnchor.constraint(equalTo: configCardView.trailingAnchor, constant: -16),
            
            deviceTokenLabel.topAnchor.constraint(equalTo: environmentLabel.bottomAnchor, constant: 8),
            deviceTokenLabel.leadingAnchor.constraint(equalTo: configCardView.leadingAnchor, constant: 16),
            deviceTokenLabel.trailingAnchor.constraint(equalTo: configCardView.trailingAnchor, constant: -16),
            
            deviceTokenValueLabel.topAnchor.constraint(equalTo: deviceTokenLabel.bottomAnchor, constant: 4),
            deviceTokenValueLabel.leadingAnchor.constraint(equalTo: configCardView.leadingAnchor, constant: 16),
            deviceTokenValueLabel.trailingAnchor.constraint(equalTo: configCardView.trailingAnchor, constant: -16),
            deviceTokenValueLabel.bottomAnchor.constraint(equalTo: configCardView.bottomAnchor, constant: -16),
            
            // Email card
            emailCardView.topAnchor.constraint(equalTo: configCardView.bottomAnchor, constant: 24),
            emailCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emailCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            emailTitleLabel.topAnchor.constraint(equalTo: emailCardView.topAnchor, constant: 16),
            emailTitleLabel.leadingAnchor.constraint(equalTo: emailCardView.leadingAnchor, constant: 16),
            emailTitleLabel.trailingAnchor.constraint(equalTo: emailCardView.trailingAnchor, constant: -16),
            
            emailTextField.topAnchor.constraint(equalTo: emailTitleLabel.bottomAnchor, constant: 12),
            emailTextField.leadingAnchor.constraint(equalTo: emailCardView.leadingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: emailCardView.trailingAnchor, constant: -16),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            emailTextField.bottomAnchor.constraint(equalTo: emailCardView.bottomAnchor, constant: -16),
            
            // Action buttons
            sendTestButton.topAnchor.constraint(equalTo: emailCardView.bottomAnchor, constant: 24),
            sendTestButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sendTestButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sendTestButton.heightAnchor.constraint(equalToConstant: 56),
            
            changeEnvironmentButton.topAnchor.constraint(equalTo: sendTestButton.bottomAnchor, constant: 12),
            changeEnvironmentButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            changeEnvironmentButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            changeEnvironmentButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: sendTestButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: sendTestButton.centerYAnchor),
            
            // Success card
            successCardView.topAnchor.constraint(equalTo: changeEnvironmentButton.bottomAnchor, constant: 24),
            successCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            successCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            successIconImageView.topAnchor.constraint(equalTo: successCardView.topAnchor, constant: 16),
            successIconImageView.leadingAnchor.constraint(equalTo: successCardView.leadingAnchor, constant: 16),
            successIconImageView.widthAnchor.constraint(equalToConstant: 24),
            successIconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            successMessageLabel.topAnchor.constraint(equalTo: successCardView.topAnchor, constant: 16),
            successMessageLabel.leadingAnchor.constraint(equalTo: successIconImageView.trailingAnchor, constant: 8),
            successMessageLabel.trailingAnchor.constraint(equalTo: successCardView.trailingAnchor, constant: -16),
            successMessageLabel.bottomAnchor.constraint(equalTo: successCardView.bottomAnchor, constant: -16),
            
            // Error card
            errorCardView.topAnchor.constraint(equalTo: changeEnvironmentButton.bottomAnchor, constant: 24),
            errorCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            errorCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            errorIconImageView.topAnchor.constraint(equalTo: errorCardView.topAnchor, constant: 16),
            errorIconImageView.leadingAnchor.constraint(equalTo: errorCardView.leadingAnchor, constant: 16),
            errorIconImageView.widthAnchor.constraint(equalToConstant: 24),
            errorIconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            errorMessageLabel.topAnchor.constraint(equalTo: errorCardView.topAnchor, constant: 16),
            errorMessageLabel.leadingAnchor.constraint(equalTo: errorIconImageView.trailingAnchor, constant: 8),
            errorMessageLabel.trailingAnchor.constraint(equalTo: errorCardView.trailingAnchor, constant: -16),
            errorMessageLabel.bottomAnchor.constraint(equalTo: errorCardView.bottomAnchor, constant: -16),
            
            // Logs card
            logsCardView.topAnchor.constraint(equalTo: successCardView.bottomAnchor, constant: 24),
            logsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            logsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            logsCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            logsTitleLabel.topAnchor.constraint(equalTo: logsCardView.topAnchor, constant: 16),
            logsTitleLabel.leadingAnchor.constraint(equalTo: logsCardView.leadingAnchor, constant: 16),
            
            clearLogsButton.centerYAnchor.constraint(equalTo: logsTitleLabel.centerYAnchor),
            clearLogsButton.trailingAnchor.constraint(equalTo: logsCardView.trailingAnchor, constant: -16),
            clearLogsButton.widthAnchor.constraint(equalToConstant: 60),
            clearLogsButton.heightAnchor.constraint(equalToConstant: 32),
            
            logsTextView.topAnchor.constraint(equalTo: logsTitleLabel.bottomAnchor, constant: 12),
            logsTextView.leadingAnchor.constraint(equalTo: logsCardView.leadingAnchor, constant: 16),
            logsTextView.trailingAnchor.constraint(equalTo: logsCardView.trailingAnchor, constant: -16),
            logsTextView.heightAnchor.constraint(equalToConstant: 200),
            logsTextView.bottomAnchor.constraint(equalTo: logsCardView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Actions Setup
    
    private func setupActions() {
        sendTestButton.addTarget(self, action: #selector(sendTestNotification), for: .touchUpInside)
        changeEnvironmentButton.addTarget(self, action: #selector(changeEnvironment), for: .touchUpInside)
        clearLogsButton.addTarget(self, action: #selector(clearLogs), for: .touchUpInside)
        
        // Dismiss keyboard when tapping elsewhere
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceTokenReceived),
            name: .deviceTokenReceived,
            object: nil
        )
    }
    
    // MARK: - Private Methods
    
    private func updateConfigurationInfo() {
        let maskedKey = String(apiKey.prefix(8)) + "..." + String(apiKey.suffix(8))
        apiKeyLabel.text = "🔑 API Key: \(maskedKey)"
        environmentLabel.text = "🌍 Environment: \(environment.rawValue.capitalized)"
        
        // Check for device token
        if let token = UserDefaults.standard.string(forKey: "FCMToken") {
            deviceToken = token
            updateDeviceTokenDisplay()
        }
        
        addLog("Configuration updated - Environment: \(environment.rawValue)")
    }
    
    private func updateDeviceTokenDisplay() {
        guard let token = deviceToken else {
            deviceTokenLabel.isHidden = true
            deviceTokenValueLabel.isHidden = true
            return
        }
        
        deviceTokenLabel.isHidden = false
        deviceTokenValueLabel.isHidden = false
        deviceTokenValueLabel.text = "\(String(token.prefix(16)))...\(String(token.suffix(16)))"
        addLog("Device token updated: \(String(token.prefix(16)))...")
    }
    
    private func addLog(_ message: String) {
        DispatchQueue.main.async {
            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
            let logEntry = "[\(timestamp)] \(message)\n"
            self.logsTextView.text = logEntry + (self.logsTextView.text ?? "")
        }
    }
    
    private func showSuccess(message: String) {
        DispatchQueue.main.async {
            self.successMessageLabel.text = message
            self.successCardView.isHidden = false
            self.errorCardView.isHidden = true
            
            // Auto-hide after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.successCardView.isHidden = true
            }
        }
    }
    
    private func showError(message: String) {
        DispatchQueue.main.async {
            self.errorMessageLabel.text = message
            self.errorCardView.isHidden = false
            self.successCardView.isHidden = true
            
            // Auto-hide after 10 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                self.errorCardView.isHidden = true
            }
        }
    }
    
    private func setLoading(_ isLoading: Bool) {
        DispatchQueue.main.async {
            if isLoading {
                self.activityIndicator.startAnimating()
                self.sendTestButton.setTitle("", for: .normal)
                self.sendTestButton.isEnabled = false
            } else {
                self.activityIndicator.stopAnimating()
                self.sendTestButton.setTitle("📧 Send Test Notification", for: .normal)
                self.sendTestButton.isEnabled = true
            }
        }
    }
    
    // MARK: - Action Methods
    
    @objc private func sendTestNotification() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showError(message: "Please enter a valid email address")
            addLog("❌ Send test failed: Email is required")
            return
        }
        
        guard let deviceToken = deviceToken else {
            showError(message: "Device token not available. Please ensure push notifications are enabled.")
            addLog("❌ Send test failed: Device token not available")
            return
        }
        
        setLoading(true)
        addLog("📧 Sending test notification to: \(email)")
        
        let testData = [
            "email": email,
            "device_token": deviceToken,
            "platform": "ios",
            "test_type": "manual",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        goMailerClient.sendTestNotification(data: testData) { [weak self] result in
            self?.setLoading(false)
            
            switch result {
            case .success(let response):
                self?.addLog("✅ Test notification sent successfully")
                self?.addLog("📄 Response: \(response)")
                self?.showSuccess(message: "Test notification sent successfully! Check your device.")
                
            case .failure(let error):
                self?.addLog("❌ Send test failed: \(error.localizedDescription)")
                self?.showError(message: "Failed to send test notification: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func changeEnvironment() {
        addLog("⚙️ Navigating back to configuration")
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func clearLogs() {
        logsTextView.text = ""
        addLog("🗑️ Logs cleared")
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func deviceTokenReceived(_ notification: Notification) {
        if let token = notification.object as? String {
            deviceToken = token
            updateDeviceTokenDisplay()
        }
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let deviceTokenReceived = Notification.Name("deviceTokenReceived")
}