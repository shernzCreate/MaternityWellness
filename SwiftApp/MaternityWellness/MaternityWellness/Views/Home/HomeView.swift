import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var moodViewModel: MoodViewModel
    @EnvironmentObject private var assessmentViewModel: AssessmentViewModel
    @State private var showMoodTracker = false
    @State private var showAssessmentTypePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Greeting section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hello, \(authViewModel.currentUser?.fullName.components(separatedBy: " ").first ?? "there")")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("How are you feeling today?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    // Today's Mood Section
                    VStack {
                        HStack {
                            Text("Today's Mood")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                showMoodTracker = true
                            }) {
                                Text(moodViewModel.todayMood == nil ? "Add" : "Update")
                                    .font(.subheadline)
                                    .foregroundColor(Color("AccentColor"))
                            }
                        }
                        
                        if let todayMood = moodViewModel.todayMood {
                            // Display today's mood
                            HStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .fill(Color(todayMood.mood.color))
                                        .frame(width: 60, height: 60)
                                    
                                    Text(todayMood.mood.emoji)
                                        .font(.system(size: 30))
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(todayMood.mood.rawValue)
                                        .font(.title3)
                                        .fontWeight(.medium)
                                    
                                    if let notes = todayMood.notes {
                                        Text(notes)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        } else {
                            // Prompt to add today's mood
                            Button(action: {
                                showMoodTracker = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle")
                                        .font(.title2)
                                    
                                    Text("How are you feeling today?")
                                        .fontWeight(.medium)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Weekly Mood Chart
                    VStack(alignment: .leading) {
                        Text("Your Week")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        MoodWeekView(moods: moodViewModel.getMoodsForLastWeek())
                            .frame(height: 150)
                            .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    // Assessments Section
                    VStack(alignment: .leading) {
                        Text("Mental Health Check")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        Button(action: {
                            showAssessmentTypePicker = true
                        }) {
                            HStack {
                                Image(systemName: "clipboard.fill")
                                    .font(.title2)
                                    .foregroundColor(Color("AccentColor"))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Take an Assessment")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Check your mental wellbeing")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Recent Assessment Results
                        if !assessmentViewModel.assessmentResults.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Recent Assessments")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 10)
                                
                                ForEach(assessmentViewModel.assessmentResults.prefix(2)) { result in
                                    HStack {
                                        Circle()
                                            .fill(Color(result.severityColor))
                                            .frame(width: 12, height: 12)
                                        
                                        Text(result.type == QuestionnaireType.epds.rawValue ? "EPDS" : "PHQ-9")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Spacer()
                                        
                                        Text("Score: \(result.score)")
                                            .font(.subheadline)
                                        
                                        Text(formatDate(result.date))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 5)
                                }
                                
                                NavigationLink(destination: AssessmentView()) {
                                    Text("View All Results")
                                        .font(.subheadline)
                                        .foregroundColor(Color("AccentColor"))
                                }
                                .padding(.top, 5)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.bottom)
            }
            .navigationTitle("Home")
            .navigationBarItems(trailing: logoutButton)
            .onAppear {
                if moodViewModel.moods.isEmpty {
                    moodViewModel.loadMoods()
                }
                if assessmentViewModel.assessmentResults.isEmpty {
                    assessmentViewModel.loadPreviousAssessments()
                }
            }
            .sheet(isPresented: $showMoodTracker) {
                MoodTrackerView(isPresented: $showMoodTracker)
                    .environmentObject(moodViewModel)
            }
            .actionSheet(isPresented: $showAssessmentTypePicker) {
                ActionSheet(
                    title: Text("Choose an Assessment"),
                    message: Text("Select the type of assessment you would like to take"),
                    buttons: [
                        .default(Text("Edinburgh Postnatal Depression Scale (EPDS)")) {
                            startAssessment(type: .epds)
                        },
                        .default(Text("Patient Health Questionnaire (PHQ-9)")) {
                            startAssessment(type: .phq9)
                        },
                        .cancel()
                    ]
                )
            }
        }
    }
    
    private var logoutButton: some View {
        Button(action: {
            authViewModel.logout()
        }) {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .imageScale(.large)
        }
    }
    
    private func startAssessment(type: QuestionnaireType) {
        assessmentViewModel.startAssessment(type: type)
        // Navigate to the assessment view
        // In a real app, you'd use a NavigationLink or other navigation method
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

struct MoodWeekView: View {
    let moods: [Mood]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(0..<7, id: \.self) { index in
                let dayMood = getMoodForDay(index)
                
                VStack {
                    if let mood = dayMood {
                        Text(mood.mood.emoji)
                            .font(.system(size: 20))
                    } else {
                        Text("🔘")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(dayMood != nil ? Color(dayMood!.mood.color) : Color.gray.opacity(0.3))
                        .frame(width: 20, height: getBarHeight(for: dayMood?.mood))
                    
                    Text(getDayLabel(for: index))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func getMoodForDay(_ daysAgo: Int) -> Mood? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let targetDate = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
            return nil
        }
        
        return moods.first { mood in
            calendar.isDate(mood.date, inSameDayAs: targetDate)
        }
    }
    
    private func getBarHeight(for mood: MoodType?) -> CGFloat {
        guard let mood = mood else { return 20 }
        
        switch mood {
        case .great: return 90
        case .good: return 70
        case .okay: return 50
        case .sad: return 30
        case .terrible: return 20
        }
    }
    
    private func getDayLabel(for daysAgo: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        
        guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter.string(from: date)
    }
}