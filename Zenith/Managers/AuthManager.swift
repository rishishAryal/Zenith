import Foundation
import SwiftUI
import Combine

class AuthManager: ObservableObject {
    @AppStorage("auth_token") var token: String?
    @Published var user: User? = nil
    
    static let shared = AuthManager()
    
    var isAuthenticated: Bool {
        token != nil
    }
    
    private init() {
        if token != nil {
            // Option to fetch user profile here
        }
    }
    
    func setToken(_ token: String) {
        self.token = token
    }
    
    func logout() {
        self.token = nil
        self.user = nil
    }
}

// User model for Auth
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
}
