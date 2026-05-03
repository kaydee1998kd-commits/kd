import Foundation

// MARK: - Translation Service

/// Calls the translation API to convert Chinese text to English.
/// The API can be self-hosted (Next.js backend) or any translation API.
class TranslationService {
    
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Text Translation
    
    func translate(text: String, completion: @escaping (Result<TranslationResult, Error>) -> Void) {
        guard let url = URL(string: AppConfig.translateTextEndpoint) else {
            completion(.failure(TranslationError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["text": text]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(TranslationError.noData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(TranslationResult.self, from: data)
                completion(.success(result))
            } catch {
                // Try to extract error message from response
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMsg = json["error"] as? String {
                    completion(.failure(TranslationError.apiError(errorMsg)))
                } else {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // MARK: - Image Translation
    
    func translateImage(base64: String, completion: @escaping (Result<TranslationResult, Error>) -> Void) {
        guard let url = URL(string: AppConfig.translateImageEndpoint) else {
            completion(.failure(TranslationError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["image": base64]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(TranslationError.noData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(TranslationResult.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Translation Errors

enum TranslationError: LocalizedError {
    case invalidURL
    case noData
    case apiError(String)
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL. Check AppConfig.translationAPIBaseURL"
        case .noData:
            return "No data received from server"
        case .apiError(let message):
            return message
        case .networkError:
            return "Network error. Make sure the server is running."
        }
    }
}
