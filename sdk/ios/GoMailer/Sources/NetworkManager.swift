import Foundation

/// Network manager for handling HTTP requests to Go Mailer backend
class NetworkManager: NSObject {
    
    // MARK: - Properties
    
    private let config: GoMailerConfig
    weak var delegate: NetworkManagerDelegate?
    
    // MARK: - Initialization
    
    init(config: GoMailerConfig) {
        self.config = config
        super.init()
    }
    
    // MARK: - Public Methods
    
    func sendRequest(endpoint: String, method: String, body: [String: Any], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "\(config.baseURL)\(endpoint)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(NetworkError.serializationError(error)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(NetworkError.networkError(error)))
                    self?.delegate?.networkManager(self!, didFailWithError: error, for: endpoint)
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
                    completion(.success(json))
                    self?.delegate?.networkManager(self!, didReceiveResponse: json, for: endpoint)
                } catch {
                    completion(.failure(NetworkError.serializationError(error)))
                }
            }
        }
        
        task.resume()
    }
}

// MARK: - NetworkManagerDelegate

protocol NetworkManagerDelegate: AnyObject {
    func networkManager(_ manager: NetworkManager, didReceiveResponse response: [String: Any], for request: String)
    func networkManager(_ manager: NetworkManager, didFailWithError error: Error, for request: String)
}

// MARK: - Network Errors

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case networkError(Error)
    case serializationError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serializationError(let error):
            return "Serialization error: \(error.localizedDescription)"
        }
    }
}
