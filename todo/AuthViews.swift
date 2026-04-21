import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    init() {
        self.currentUser = Auth.auth().currentUser
        self.isAuthenticated = self.currentUser != nil
        
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    func login(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func register(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

struct MainAuthView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        if authViewModel.isAuthenticated, let user = authViewModel.currentUser {
            NavigationView {
                ContentView(userId: user.uid)
                    .environmentObject(authViewModel)
            }
        } else {
            LoginView()
                .environmentObject(authViewModel)
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    isDarkMode ? Color(red: 0.07, green: 0.07, blue: 0.12) : Color(red: 0.95, green: 0.95, blue: 0.97),
                    isDarkMode ? Color(red: 0.11, green: 0.11, blue: 0.18) : Color(red: 0.90, green: 0.91, blue: 0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
                    .padding(.bottom, 20)
                
                // Title
                Text(isRegistering ? "Create Account" : "Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(isDarkMode ? .white : .primary)
                
                Text(isRegistering ? "Sign up to track your tasks" : "Log in to view your tasks")
                    .font(.subheadline)
                    .foregroundColor(isDarkMode ? .gray : .secondary)
                
                // Input Fields
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(isDarkMode ? Color.white.opacity(0.08) : Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .foregroundColor(isDarkMode ? .white : .primary)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(isDarkMode ? Color.white.opacity(0.08) : Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .foregroundColor(isDarkMode ? .white : .primary)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                // Error Message
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Action Button
                Button {
                    if isRegistering {
                        authViewModel.register(email: email, password: password)
                    } else {
                        authViewModel.login(email: email, password: password)
                    }
                } label: {
                    HStack {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(isRegistering ? "Sign Up" : "Log In")
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.4, green: 0.6, blue: 1.0))
                    .cornerRadius(12)
                }
                .disabled(authViewModel.isLoading)
                .padding(.horizontal, 30)
                .padding(.top, 10)
                
                // Toggle mode
                Button {
                    withAnimation {
                        isRegistering.toggle()
                        authViewModel.errorMessage = ""
                    }
                } label: {
                    Text(isRegistering ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
                }
                .padding(.top, 10)
                
                Spacer()
            }
        }
    }
}
