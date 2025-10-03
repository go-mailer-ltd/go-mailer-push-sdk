//
//  ConfigurationViewController.swift
//  GoMailerExample
//
//  Created by GoMailer Team on 10/03/2025.
//  Copyright © 2025 GoMailer Ltd. All rights reserved.
//

import UIKit

class ConfigurationViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    
    private let configCardView = UIView()
    private let configTitleLabel = UILabel()
    private let apiKeyTextField = UITextField()
    private let environmentSegmentedControl = UISegmentedControl(items: GoMailerEnvironment.allCases.map { $0.displayName })
    
    private let continueButton = UIButton(type: .system)
    
    // MARK: - Properties
    
    private var selectedEnvironment: GoMailerEnvironment = .development
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        navigationItem.title = "GoMailer"
        
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Configure logo
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(systemName: "bell.fill")
        logoImageView.tintColor = UIColor.systemBlue
        logoImageView.contentMode = .scaleAspectFit
        contentView.addSubview(logoImageView)
        
        // Configure title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "GoMailer Configuration"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.label
        contentView.addSubview(titleLabel)
        
        // Configure config card
        configCardView.translatesAutoresizingMaskIntoConstraints = false
        configCardView.backgroundColor = UIColor.secondarySystemGroupedBackground
        configCardView.layer.cornerRadius = 12
        configCardView.layer.shadowColor = UIColor.black.cgColor
        configCardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        configCardView.layer.shadowOpacity = 0.1
        configCardView.layer.shadowRadius = 3
        contentView.addSubview(configCardView)
        
        // Configure config title
        configTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        configTitleLabel.text = "API Configuration"
        configTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        configTitleLabel.textColor = UIColor.label
        configCardView.addSubview(configTitleLabel)
        
        // Configure API key text field
        apiKeyTextField.translatesAutoresizingMaskIntoConstraints = false
        apiKeyTextField.placeholder = "Enter your GoMailer API Key"
        apiKeyTextField.text = "TmF0aGFuLTEyMzQ1Njc4OTA=" // Default API key
        apiKeyTextField.borderStyle = .roundedRect
        apiKeyTextField.backgroundColor = UIColor.tertiarySystemGroupedBackground
        apiKeyTextField.font = UIFont.systemFont(ofSize: 16)
        configCardView.addSubview(apiKeyTextField)
        
        // Configure environment segmented control
        environmentSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        environmentSegmentedControl.selectedSegmentIndex = 0
        environmentSegmentedControl.backgroundColor = UIColor.tertiarySystemGroupedBackground
        configCardView.addSubview(environmentSegmentedControl)
        
        // Configure continue button
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        continueButton.backgroundColor = UIColor.systemBlue
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 12
        contentView.addSubview(continueButton)
    }
    
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
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 48),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 72),
            logoImageView.heightAnchor.constraint(equalToConstant: 72),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Config card
            configCardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 48),
            configCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            configCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Config title
            configTitleLabel.topAnchor.constraint(equalTo: configCardView.topAnchor, constant: 16),
            configTitleLabel.leadingAnchor.constraint(equalTo: configCardView.leadingAnchor, constant: 16),
            configTitleLabel.trailingAnchor.constraint(equalTo: configCardView.trailingAnchor, constant: -16),
            
            // API key text field
            apiKeyTextField.topAnchor.constraint(equalTo: configTitleLabel.bottomAnchor, constant: 16),
            apiKeyTextField.leadingAnchor.constraint(equalTo: configCardView.leadingAnchor, constant: 16),
            apiKeyTextField.trailingAnchor.constraint(equalTo: configCardView.trailingAnchor, constant: -16),
            apiKeyTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Environment segmented control
            environmentSegmentedControl.topAnchor.constraint(equalTo: apiKeyTextField.bottomAnchor, constant: 16),
            environmentSegmentedControl.leadingAnchor.constraint(equalTo: configCardView.leadingAnchor, constant: 16),
            environmentSegmentedControl.trailingAnchor.constraint(equalTo: configCardView.trailingAnchor, constant: -16),
            environmentSegmentedControl.bottomAnchor.constraint(equalTo: configCardView.bottomAnchor, constant: -16),
            environmentSegmentedControl.heightAnchor.constraint(equalToConstant: 32),
            
            // Continue button
            continueButton.topAnchor.constraint(equalTo: configCardView.bottomAnchor, constant: 32),
            continueButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            continueButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            continueButton.heightAnchor.constraint(equalToConstant: 56),
            continueButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    private func setupActions() {
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        environmentSegmentedControl.addTarget(self, action: #selector(environmentChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    @objc private func continueButtonTapped() {
        guard let apiKey = apiKeyTextField.text, !apiKey.isEmpty else {
            showAlert(title: "Error", message: "Please enter an API key")
            return
        }
        
        let testViewController = TestViewController(apiKey: apiKey, environment: selectedEnvironment)
        navigationController?.pushViewController(testViewController, animated: true)
    }
    
    @objc private func environmentChanged() {
        selectedEnvironment = GoMailerEnvironment.allCases[environmentSegmentedControl.selectedSegmentIndex]
    }
    
    // MARK: - Helper Methods
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}