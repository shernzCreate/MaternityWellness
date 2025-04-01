import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var moodViewModel = MoodViewModel(userId: "placeholder")
    @StateObject private var resourceViewModel = ResourceViewModel(userId: "placeholder")
    @StateObject private var assessmentViewModel = AssessmentViewModel(userId: "placeholder")
    
    @State private var showingMoodTracker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Section
                    welcomeSection
                    
                    // Mood Tracking Section
                    moodTrackingSection
                    
                    // Assessment Section
                    assessmentSection
                    
                    // Featured Resources
                    featuredResourcesSection
                    
                    // Daily Tip
                    dailyTipSection
                }
                .padding(.bottom)
            }
            .navigationTitle("Home")
            .onAppear {
                // Update view model user IDs when user is available
                if let userId = authViewModel.currentUser?.id {
                    if moodViewModel.userId != userId {
                        moodViewModel.userId = userId
                        moodViewModel.loadMoodData()
                    }
                    
                    if resourceViewModel.userId != userId {
                        resourceViewModel.userId = userId
                        resourceViewModel.loadResources()
                    }
                    
                    if assessmentViewModel.userId != userId {
                        assessmentViewModel.userId = userId
                    }
                }
            }
            .sheet(isPresented: $showingMoodTracker) {
                MoodTrackerView(
                    viewModel: moodViewModel,
                    isPresented: $showingMoodTracker
                )
            }
        }
    }
    
    // MARK: - Welcome Section
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome, \(firstName)")
                .font(.title)
                .fontWeight(.bold)
            
            Text("How are you feeling today?")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var firstName: String {
        authViewModel.currentUser?.fullName.components(separatedBy: " ").first ?? "there"
    }
    
    // MARK: - Mood Tracking Section
    
    private var moodTrackingSection: some View {
        VStack(spacing: 16) {
            sectionHeader(title: "Mood Tracker", icon: "heart.fill")
            
            if let todaysMood = moodViewModel.todaysMood {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Today's Mood")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(todaysMood.mood.emoji)
                                .font(.system(size: 32))
                            
                            Text(todaysMood.mood.rawValue)
                                .font(.headline)
                                .foregroundColor(Color(todaysMood.mood.color))
                        }
                        
                        if let notes = todaysMood.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingMoodTracker = true
                    }) {
                        Text("Update")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color("AccentColor"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color("AccentColor").opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            } else {
                Button(action: {
                    showingMoodTracker = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color("AccentColor"))
                        
                        Text("Track Today's Mood")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AccentColor").opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            // Weekly mood trends (if available)
            if moodViewModel.weeklyMoods.count > 2 {
                weeklyMoodTrends
            }
        }
        .padding(.horizontal)
    }
    
    private var weeklyMoodTrends: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekly Trends")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                ForEach(moodViewModel.weeklyMoods.sorted(by: { $0.date < $1.date }), id: \.id) { mood in
                    VStack {
                        Text(mood.mood.emoji)
                            .font(.system(size: 22))
                        
                        Text(dayOfWeek(from: mood.date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Fill with empty slots if less than 7 days
                if moodViewModel.weeklyMoods.count < 7 {
                    ForEach(0..<(7 - moodViewModel.weeklyMoods.count), id: \.self) { _ in
                        VStack {
                            Text("?")
                                .font(.system(size: 22))
                                .foregroundColor(.gray.opacity(0.3))
                            
                            Text("--")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    // MARK: - Assessment Section
    
    private var assessmentSection: some View {
        VStack(spacing: 16) {
            sectionHeader(title: "Wellness Check-In", icon: "clipboard.fill")
            
            NavigationLink(destination: AssessmentView()) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mental Health Assessment")
                            .font(.headline)
                        
                        Text(getAssessmentPrompt())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            
            if let latestAssessment = assessmentViewModel.getLatestAssessment() {
                latestAssessmentView(assessment: latestAssessment)
            }
        }
        .padding(.horizontal)
    }
    
    private func getAssessmentPrompt() -> String {
        if let latest = assessmentViewModel.getLatestAssessment() {
            let daysSince = Calendar.current.dateComponents([.day], from: latest.date, to: Date()).day ?? 0
            
            if daysSince > 14 {
                return "It's been \(daysSince) days since your last assessment. Consider taking another one."
            } else {
                return "You completed an assessment \(daysSince == 0 ? "today" : "\(daysSince) days ago"). You can retake anytime."
            }
        } else {
            return "Take a quick assessment to check in on your mental health."
        }
    }
    
    private func latestAssessmentView(assessment: AssessmentResult) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Latest Assessment")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(relativeDateFormatter.string(from: assessment.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(assessment.type.rawValue)
                        .font(.headline)
                    
                    Text(assessment.interpretation.severity)
                        .font(.subheadline)
                        .foregroundColor(Color(assessment.interpretation.color))
                }
                
                Spacer()
                
                Text("\(assessment.score)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(assessment.interpretation.color))
                    .padding(10)
                    .background(Color(assessment.interpretation.color).opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Featured Resources Section
    
    private var featuredResourcesSection: some View {
        VStack(spacing: 16) {
            HStack {
                sectionHeader(title: "Featured Resources", icon: "star.fill")
                
                Spacer()
                
                NavigationLink(destination: ResourcesView()) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(Color("AccentColor"))
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(resourceViewModel.featuredResources) { resource in
                        ResourceCardView(resource: resource)
                            .frame(width: 280, height: 180)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Daily Tip Section
    
    private var dailyTipSection: some View {
        VStack(spacing: 16) {
            sectionHeader(title: "Daily Wellness Tip", icon: "sparkles")
            
            VStack(alignment: .leading, spacing: 12) {
                Text(getDailyTip().title)
                    .font(.headline)
                
                Text(getDailyTip().content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal)
    }
    
    private func getDailyTip() -> (title: String, content: String) {
        // Return a tip based on the day of year for consistent daily tips
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 0
        
        let tips = [
            (title: "Practice Self-Compassion", content: "Be kind to yourself today. Speak to yourself as you would to a good friend."),
            (title: "Take Deep Breaths", content: "When feeling overwhelmed, take 5 deep breaths. Inhale for 4 counts, hold for 4, exhale for 6."),
            (title: "Connect with Someone", content: "Send a message to a supportive friend or family member. Social connection is vital for well-being."),
            (title: "Move Your Body", content: "Even 5 minutes of gentle movement can improve your mood and energy levels."),
            (title: "Notice the Good", content: "Try to identify three positive moments throughout your day, no matter how small."),
            (title: "Hydrate Well", content: "Staying hydrated improves energy, mood, and cognitive function, especially in Singapore's climate."),
            (title: "Set Boundaries", content: "It's okay to say no to additional responsibilities when you need to focus on yourself and your baby.")
        ]
        
        return tips[dayOfYear % tips.count]
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color("AccentColor"))
            
            Text(title)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Formatters
    
    private let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthViewModel()
        authViewModel.currentUser = User(username: "testuser", fullName: "Sarah Tan", email: "test@example.com")
        
        return HomeView()
            .environmentObject(authViewModel)
    }
}