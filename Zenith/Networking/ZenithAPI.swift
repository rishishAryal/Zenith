import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(String)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The endpoint URL is invalid."
        case .noData: return "The server returned no data."
        case .decodingError(let details): return "Data decoding failed: \(details)"
        case .serverError(let message): return message
        }
    }
}

class ZenithAPI {
    static let shared = ZenithAPI()
    
    // Switch to your IP for local dev on device.
    private let baseURL = "https://dramatic-tailless-ruthe.ngrok-free.dev/api" 
    
    private init() {}
    
    private var token: String? {
        AuthManager.shared.token
    }
    
    func request<T: Codable>(_ endpoint: String, method: String = "GET", body: Data? = nil) async throws -> T {
        let urlString = "\(baseURL)/\(endpoint)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "\(baseURL)/\(endpoint)"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid server response")
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown Error"
            print("API Error [\(httpResponse.statusCode)]: \(errorMsg)")
            throw NetworkError.serverError(errorMsg)
        }
        
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let formatters = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ", // with 6 sub-seconds
                "yyyy-MM-dd'T'HH:mm:ss.SSSZ",    // with 3 sub-seconds
                "yyyy-MM-dd'T'HH:mm:ssZ",         // no sub-seconds
                "yyyy-MM-dd HH:mm:ss"            // standard SQL format
            ]
            
            for format in formatters {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                formatter.locale = Locale(identifier: "en_US_POSIX")
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            
            let isoFormatter = ISO8601DateFormatter()
            if let date = isoFormatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateString)")
        }
        
        if data.isEmpty {
            let emptyData = "{}".data(using: .utf8)!
            return try decoder.decode(T.self, from: emptyData)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding Error: \(error)")
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
    
    // Auth helpers - don't use shared request since they return token
    func login(credentials: [String: String]) async throws -> (token: String, user: User) {
        guard let url = URL(string: "\(baseURL)/login") else { throw NetworkError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(credentials)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let res = response as? HTTPURLResponse, res.statusCode >= 400 {
            throw NetworkError.serverError("Login failed")
        }
        
        struct LoginResponse: Codable {
            let accessToken: String
            let user: User
            
            enum CodingKeys: String, CodingKey {
                case accessToken = "access_token"
                case user
            }
        }
        
        let res = try JSONDecoder().decode(LoginResponse.self, from: data)
        return (res.accessToken, res.user)
    }
    
    func register(userData: [String: String]) async throws -> (token: String, user: User) {
        guard let url = URL(string: "\(baseURL)/register") else { throw NetworkError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(userData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let res = response as? HTTPURLResponse, res.statusCode >= 400 {
            throw NetworkError.serverError("Registration failed")
        }
        
        struct RegisterResponse: Codable {
            let accessToken: String
            let user: User
            
            enum CodingKeys: String, CodingKey {
                case accessToken = "access_token"
                case user
            }
        }
        
        let res = try JSONDecoder().decode(RegisterResponse.self, from: data)
        return (res.accessToken, res.user)
    }
}
