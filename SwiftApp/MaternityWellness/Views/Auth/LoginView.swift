import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Form fields
            VStack(spacing: 15) {
                TextField("Username", text: $username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                // Remember me checkbox
                HStack {
                    Button(action: {
                        rememberMe.toggle()
                    }) {
                        HStack {
                            Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                .foregroundColor(rememberMe ? Color("AccentColor") : .gray)
                            
                            Text("Remember me")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Button(action: {
                        // Handle forgot password
                    }) {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .foregroundColor(Color("AccentColor"))
                    }
                }
                .padding(.vertical, 5)
            }
            .padding(.horizontal, 20)
            
            // Login button
            Button(action: {
                authViewModel.login(username: username, password: password)
            }) {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Log In")
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("AccentColor"))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .disabled(username.isEmpty || password.isEmpty || authViewModel.isLoading)
            .opacity((username.isEmpty || password.isEmpty || authViewModel.isLoading) ? 0.6 : 1.0)
            
            // Login with other methods
            VStack(spacing: 15) {
                Text("Or continue with")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 20) {
                    socialLoginButton(imageName: "applelogo", backgroundColor: .black)
                    socialLoginButton(imageName: "g.circle.fill", backgroundColor: .red)
                    socialLoginButton(imageName: "f.circle.fill", backgroundColor: .blue)
                }
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding(.top, 20)
    }
    
    private func socialLoginButton(imageName: String, backgroundColor: Color) -> some View {
        Button(action: {
            // Handle social login
        }) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding()
                .background(backgroundColor)
                .clipShape(Circle())
                .foregroundColor(.white)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}