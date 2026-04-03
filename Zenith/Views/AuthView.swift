import SwiftUI

struct AuthView: View {
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ZStack {
            LivingBackground()
            
            VStack(spacing: 30) {
                VStack(spacing: 12) {
                    Text(isLogin ? "Welcome Back" : "Create Account")
                        .font(Font.headline(size: 32, weight: .black))
                        .foregroundStyle(AppTheme.primaryGradient)
                    
                    Text(isLogin ? "Sign in to manage your wealth" : "Start your journey with Zenith")
                        .font(Font.bodyText(size: 16))
                        .foregroundColor(AppTheme.onSurfaceVariant)
                }
                .padding(.top, 50)
                
                VStack(spacing: 20) {
                    if !isLogin {
                        CustomTextField(icon: "person.fill", placeholder: "Full Name", text: $name)
                    }
                    
                    CustomTextField(icon: "envelope.fill", placeholder: "Email Address", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    CustomSecureField(icon: "lock.fill", placeholder: "Password", text: $password)
                }
                .padding(.horizontal, 30)
                
                if let error = errorMessage {
                    Text(error)
                        .font(Font.bodyText(size: 14))
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Button(action: handleAuth) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(isLogin ? "Sign In" : "Sign Up")
                            .font(Font.headline(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(AppTheme.primaryGradient)
                            .clipShape(Capsule())
                            .shadow(color: AppTheme.primary.opacity(0.3), radius: 10, y: 5)
                    }
                }
                .disabled(isLoading)
                .padding(.horizontal, 30)
                
                Button(action: { withAnimation { isLogin.toggle() } }) {
                    Text(isLogin ? "Don't have an account? Sign Up" : "Already have an account? Sign In")
                        .font(Font.bodyText(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.onSurfaceVariant)
                }
                
                Spacer()
            }
        }
    }
    
    private func handleAuth() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if isLogin {
                    let (token, user) = try await ZenithAPI.shared.login(credentials: ["email": email, "password": password])
                    authManager.setToken(token)
                    authManager.user = user
                } else {
                    let (token, user) = try await ZenithAPI.shared.register(userData: ["name": name, "email": email, "password": password, "password_confirmation": password])
                    authManager.setToken(token)
                    authManager.user = user
                }
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.primary)
                .frame(width: 20)
            
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(AppTheme.onSurfaceVariant.opacity(0.5)))
                .foregroundColor(.white)
        }
        .padding()
        .background(AppTheme.surfaceContainer.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(AppTheme.onSurfaceVariant.opacity(0.1), lineWidth: 1))
    }
}

struct CustomSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.primary)
                .frame(width: 20)
            
            SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(AppTheme.onSurfaceVariant.opacity(0.5)))
                .foregroundColor(.white)
        }
        .padding()
        .background(AppTheme.surfaceContainer.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(AppTheme.onSurfaceVariant.opacity(0.1), lineWidth: 1))
    }
}
