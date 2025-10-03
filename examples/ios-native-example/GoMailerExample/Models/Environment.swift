//
//  Environment.swift
//  GoMailerExample
//
//  Created by GoMailer Team on 10/03/2025.
//  Copyright © 2025 GoMailer Ltd. All rights reserved.
//

import Foundation

enum GoMailerEnvironment: String, CaseIterable {
    case development = "development"
    case staging = "staging"
    case production = "production"
    
    var displayName: String {
        switch self {
        case .development:
            return "Development"
        case .staging:
            return "Staging"
        case .production:
            return "Production"
        }
    }
    
    var baseURL: String {
        switch self {
        case .development:
            return "https://api.gm-g6.xyz/v1"
        case .staging:
            return "https://api-staging.gomailer.com/v1"
        case .production:
            return "https://api.gomailer.com/v1"
        }
    }
}