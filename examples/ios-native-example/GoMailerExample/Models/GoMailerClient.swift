//
//  GoMailerClient.swift
//  GoMailerExample
//
//  Created by GoMailer Team on 10/03/2025.
//  Copyright © 2025 GoMailer Ltd. All rights reserved.
//

import Foundation

class GoMailerClient {
    private let apiKey: String
    private let baseURL: String
    private let session: URLSession
    
    init(apiKey: String, environment: GoMailerEnvironment) {
        self.apiKey = apiKey
        self.baseURL = environment.baseURL
        self.session = URLSession.shared
    }
    
    // MARK: - API Methods
    
    func setUser(email: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let endpoint = "\(baseURL)/users"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(GoMailerError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body = ["email": email]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(GoMailerError.invalidResponse))
                    return
                }
                
                let success = (200...299).contains(httpResponse.statusCode)
                completion(.success(success))
            }
        }.resume()
    }
    
    func registerDeviceToken(_ deviceToken: String, email: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let endpoint = "\(baseURL)/devices/register"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(GoMailerError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "device_token": deviceToken,
            "email": email,
            "platform": "ios"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(GoMailerError.invalidResponse))
                    return
                }
                
                let success = (200...299).contains(httpResponse.statusCode)
                completion(.success(success))
            }
        }.resume()
    }
    
    func sendTestNotification(data: [String: Any], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let endpoint = "\(baseURL)/send"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(GoMailerError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data)
        } catch {
            completion(.failure(error))
            return
        }
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(GoMailerError.invalidResponse))
                    return
                }
                
                var result: [String: Any] = [:]
                
                if let data = data {
                    do {
                        if let jsonResult = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            result = jsonResult
                        }
                    } catch {
                        // If JSON parsing fails, just use status code
                    }
                }
                
                result["statusCode"] = httpResponse.statusCode
                result["success"] = (200...299).contains(httpResponse.statusCode)
                
                completion(.success(result))
            }
        }.resume()
    }
}

// MARK: - GoMailer Errors

enum GoMailerError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noDeviceToken
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .noDeviceToken:
            return "No device token available"
        }
    }
}