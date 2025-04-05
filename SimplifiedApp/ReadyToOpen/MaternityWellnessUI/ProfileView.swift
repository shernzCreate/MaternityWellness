import SwiftUI

struct ProfileView: View {
    @State private var fullName = "Sarah Chen"
    @State private var email = "sarah.chen@example.com"
    @State private var birthdate = Date().addingTimeInterval(-30*365*24*60*60) // ~30 years ago
    @State private var babyBirthdate = Date().addingTimeInterval(-4*30*24*60*60) // ~4 months ago
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var dataSharing = true
    @State private var language = "English"
    @State private var isEditingProfile = false
    
    // Available languages
    let languages = ["English", "Chinese", "Malay", "Tamil"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                ZStack(alignment: .bottom) {
                    // Header background with gradient
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "FF9494"),
                                    Color(hex: "FFC371")
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 150)
                        .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                    
                    // Profile picture
                    VStack {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 100, height: 100)
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            
                            Text(String(fullName.prefix(1)))
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(Color(hex: "FF9494"))
                        }
                        
                        Text(fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    .offset(y: 40)
                }
                .padding(.bottom, 40)
                
                // Profile Information
                VStack(spacing: 24) {
                    // Personal Information
                    profileSection(title: "Personal Information") {
                        if isEditingProfile {
                            profileEditField(title: "Full Name", binding: $fullName)
                            profileEditField(title: "Email", binding: $email)
                            
                            VStack(alignment: .leading) {
                                Text("Your Birthday")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                DatePicker("", selection: $birthdate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Baby's Birthday")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                DatePicker("", selection: $babyBirthdate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                            }
                        } else {
                            profileInfoRow(title: "Full Name", value: fullName)
                            profileInfoRow(title: "Email", value: email)
                            profileInfoRow(title: "Your Birthday", value: formattedDate(birthdate))
                            profileInfoRow(title: "Baby's Birthday", value: formattedDate(babyBirthdate))
                        }
                    }
                    
                    // App Settings
                    profileSection(title: "App Settings") {
                        profileToggleRow(title: "Enable Notifications", isOn: $notificationsEnabled)
                        profileToggleRow(title: "Dark Mode", isOn: $darkModeEnabled)
                        profileToggleRow(title: "Share Data for Research", isOn: $dataSharing)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Language")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Picker("Language", selection: $language) {
                                ForEach(languages, id: \.self) { lang in
                                    Text(lang).tag(lang)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .tint(Color(hex: "FF9494"))
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // Care Team
                    profileSection(title: "Care Team") {
                        Button(action: {
                            // Add care provider
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color(hex: "FF9494"))
                                Text("Add Healthcare Provider")
                                    .foregroundColor(Color(hex: "FF9494"))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Account Actions
                    profileSection(title: "Account") {
                        Button(action: {
                            // Edit profile
                            isEditingProfile.toggle()
                        }) {
                            HStack {
                                Image(systemName: isEditingProfile ? "checkmark.circle.fill" : "pencil")
                                    .foregroundColor(Color(hex: "FF9494"))
                                Text(isEditingProfile ? "Save Changes" : "Edit Profile")
                                    .foregroundColor(Color(hex: "FF9494"))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 4)
                        
                        Button(action: {
                            // Export data
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                    .foregroundColor(Color.blue)
                                Text("Export My Data")
                                    .foregroundColor(Color.blue)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 4)
                        
                        Button(action: {
                            // Sign out
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                    .foregroundColor(Color.orange)
                                Text("Sign Out")
                                    .foregroundColor(Color.orange)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 4)
                        
                        Button(action: {
                            // Delete account
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(Color.red)
                                Text("Delete Account")
                                    .foregroundColor(Color.red)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // App Information
                    VStack(spacing: 16) {
                        Image("PPDAPPICON")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)
                        
                        Text("Maternity Wellness")
                            .font(.headline)
                        
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("© 2025 Maternity Wellness Team")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .background(Color(hex: "FAFAFA").edgesIgnoringSafeArea(.all))
    }
    
    // Helper functions
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // UI Components
    @ViewBuilder
    private func profileSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color.primary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                VStack(alignment: .leading, spacing: 12) {
                    content()
                }
                .padding(20)
            }
        }
    }
    
    private func profileInfoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
    
    private func profileToggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color(hex: "FF9494"))
        }
        .padding(.vertical, 4)
    }
    
    private func profileEditField(title: String, binding: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            TextField("", text: binding)
                .padding()
                .background(Color(hex: "F5F5F5"))
                .cornerRadius(8)
        }
    }
}

// Extension for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
