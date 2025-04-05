import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentMood: String? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Welcome section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hello, \(authViewModel.currentUser?.name.components(separatedBy: " ").first ?? "there")")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("How are you feeling today?")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Mood tracker
                    MoodTrackerView(selectedMood: $currentMood)
                        .padding(.horizontal)
                    
                    // Recent assessment
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your assessment")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Recent assessment card
                        recentAssessmentCard
                    }
                    
                    // Action cards
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick actions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                actionCard(
                                    title: "New Assessment",
                                    description: "Complete a mental health check",
                                    icon: "list.clipboard",
                                    color: Color.blue
                                )
                                
                                actionCard(
                                    title: "Resources",
                                    description: "Learn about PPD",
                                    icon: "book.fill",
                                    color: Color.purple
                                )
                                
                                actionCard(
                                    title: "Singapore Helplines",
                                    description: "Get immediate support",
                                    icon: "phone.fill",
                                    color: Color.green
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Singapore-specific resources
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Singapore Resources")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        sgResourceCard(
                            title: "KK Women's and Children's Hospital",
                            description: "Mental Wellness Service",
                            link: "https://www.kkh.com.sg"
                        )
                        
                        sgResourceCard(
                            title: "National University Hospital",
                            description: "Women's Mental Health Clinic",
                            link: "https://www.nuh.com.sg"
                        )
                        
                        sgResourceCard(
                            title: "Ministry of Health Singapore",
                            description: "Maternal Mental Health",
                            link: "https://www.moh.gov.sg"
                        )
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitle("Home", displayMode: .inline)
            .navigationBarItems(trailing: 
                Button(action: {
                    authViewModel.logout()
                }) {
                    Text("Log out")
                }
            )
        }
    }
    
    // Recent assessment card
    private var recentAssessmentCard: some View {
        // This would typically display the most recent assessment result
        // For now, show a placeholder or prompt to take an assessment
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
            
            VStack(alignment: .leading, spacing: 12) {
                Text("No recent assessments")
                    .font(.headline)
                
                Text("Complete a screening questionnaire to check your mental wellbeing.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    // Navigate to assessment
                }) {
                    Text("Take Assessment")
                        .fontWeight(.semibold)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .frame(height: 150)
        .padding(.horizontal)
    }
    
    // Action card
    private func actionCard(title: String, description: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 150, height: 150)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Singapore resource card
    private func sgResourceCard(title: String, description: String, link: String) -> some View {
        Button(action: {
            // Open link to resource
            if let url = URL(string: link) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
}