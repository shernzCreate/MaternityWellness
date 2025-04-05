import SwiftUI

struct HomeView: View {
    @State private var latestMood: String = "😊"
    @State private var lastAssessmentScore: Int = 5
    @State private var lastAssessmentDate: Date = Date().addingTimeInterval(-7*24*60*60) // 7 days ago
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                ZStack {
                    ColorTheme.backgroundGradient
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        // Welcome Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Welcome Back")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(ColorTheme.textGray)
                            
                            Text("How are you feeling today?")
                                .font(.subheadline)
                                .foregroundColor(ColorTheme.textGray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Daily Check-in Card
                        VStack(spacing: 15) {
                            HStack {
                                Text("Daily Check-in")
                                    .font(.headline)
                                    .foregroundColor(ColorTheme.textGray)
                                
                                Spacer()
                                
                                Image(systemName: "heart.fill")
                                    .foregroundColor(ColorTheme.primaryPink)
                            }
                            
                            Divider()
                            
                            HStack(spacing: 20) {
                                ForEach(["😊", "😐", "😢", "😡", "😴"], id: \.self) { emoji in
                                    Button(action: {
                                        latestMood = emoji
                                    }) {
                                        Text(emoji)
                                            .font(.system(size: 35))
                                            .padding(10)
                                            .background(
                                                Circle()
                                                    .fill(latestMood == emoji ? 
                                                          Color.white : Color.clear)
                                                    .shadow(color: latestMood == emoji ? 
                                                            ColorTheme.primaryPink.opacity(0.3) : Color.clear, 
                                                            radius: 5, x: 0, y: 3)
                                            )
                                    }
                                }
                            }
                            
                            Button(action: {
                                // Save the mood action
                            }) {
                                Text("Save Mood")
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(ColorTheme.buttonGradient)
                                    .cornerRadius(15)
                                    .shadow(color: ColorTheme.primaryPink.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        // Quick Access Features
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Quick Access")
                                .font(.headline)
                                .foregroundColor(ColorTheme.textGray)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    // Assessment Card
                                    NavigationLink(destination: AssessmentView()) {
                                        QuickAccessCard(
                                            title: "Assessment",
                                            iconName: "checklist",
                                            description: "Check your mental wellbeing",
                                            color: ColorTheme.primaryPink
                                        )
                                    }
                                    
                                    // Resources Card
                                    NavigationLink(destination: ResourcesView()) {
                                        QuickAccessCard(
                                            title: "Resources",
                                            iconName: "book.fill",
                                            description: "Learn about postpartum care",
                                            color: ColorTheme.primaryPink
                                        )
                                    }
                                    
                                    // Mood History
                                    NavigationLink(destination: MoodTrackerView()) {
                                        QuickAccessCard(
                                            title: "Mood History",
                                            iconName: "chart.line.uptrend.xyaxis",
                                            description: "View your mood patterns",
                                            color: ColorTheme.primaryPink
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Last Assessment Summary
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Your Last Assessment")
                                .font(.headline)
                                .foregroundColor(ColorTheme.textGray)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("EPDS Score: \(lastAssessmentScore)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Text(dateFormatter.string(from: lastAssessmentDate))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Text("Your score is in the low-risk range. Continue to monitor your feelings and check in regularly.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                NavigationLink(destination: AssessmentView()) {
                                    Text("Take New Assessment")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 20)
                                        .background(ColorTheme.buttonGradient)
                                        .cornerRadius(15)
                                        .shadow(color: ColorTheme.primaryPink.opacity(0.3), radius: 5, x: 0, y: 3)
                                }
                                .padding(.top, 5)
                            }
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct QuickAccessCard: View {
    var title: String
    var iconName: String
    var description: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: iconName)
                .font(.title)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .foregroundColor(ColorTheme.textGray)
            
            Text(description)
                .font(.caption)
                .foregroundColor(Color.gray)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(width: 150, height: 150)
        .background(Color.white.opacity(0.8))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
