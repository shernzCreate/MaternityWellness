import SwiftUI

struct ProgressView: View {
    @State private var assessmentHistory: [AssessmentEntry] = [
        AssessmentEntry(date: Date().addingTimeInterval(-30*24*60*60), score: 14, type: "EPDS"),
        AssessmentEntry(date: Date().addingTimeInterval(-20*24*60*60), score: 12, type: "EPDS"),
        AssessmentEntry(date: Date().addingTimeInterval(-10*24*60*60), score: 9, type: "EPDS"),
        AssessmentEntry(date: Date(), score: 7, type: "EPDS")
    ]
    
    @State private var moodHistory: [MoodEntry] = [
        MoodEntry(date: Date().addingTimeInterval(-6*24*60*60), level: 2),
        MoodEntry(date: Date().addingTimeInterval(-5*24*60*60), level: 3),
        MoodEntry(date: Date().addingTimeInterval(-4*24*60*60), level: 2),
        MoodEntry(date: Date().addingTimeInterval(-3*24*60*60), level: 4),
        MoodEntry(date: Date().addingTimeInterval(-2*24*60*60), level: 3),
        MoodEntry(date: Date().addingTimeInterval(-1*24*60*60), level: 4),
        MoodEntry(date: Date(), level: 5)
    ]
    
    @State private var goalProgress: [GoalEntry] = [
        GoalEntry(title: "Daily meditation", completed: 15, total: 30),
        GoalEntry(title: "Sleep 7+ hours", completed: 22, total: 30),
        GoalEntry(title: "Connect with friend", completed: 8, total: 12)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text("Your Progress")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("AccentColor"))
                
                // Assessment Progress
                VStack(alignment: .leading, spacing: 12) {
                    Text("Assessment History")
                        .font(.headline)
                        .foregroundColor(Color.primary)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("EPDS Scores Over Time")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.gray)
                            
                            // Chart
                            HStack(alignment: .bottom, spacing: 8) {
                                ForEach(assessmentHistory, id: \.date) { entry in
                                    VStack {
                                        Text("\(entry.score)")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 6)
                                            .background(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(hex: "FF9494"),
                                                        Color(hex: "FFC371")
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .cornerRadius(8)
                                        
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(hex: "FF9494"),
                                                        Color(hex: "FFC371")
                                                    ]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .frame(width: 24, height: CGFloat(entry.score) * 5)
                                        
                                        Text(formattedDate(entry.date))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .rotationEffect(.degrees(-45))
                                            .offset(y: 10)
                                    }
                                }
                            }
                            .frame(height: 160)
                            .padding(.bottom, 30)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Most Recent:")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    if let latest = assessmentHistory.last {
                                        HStack(alignment: .firstTextBaseline) {
                                            Text("\(latest.score)")
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .foregroundColor(scoreColor(latest.score))
                                            
                                            Text("/ 30")
                                                .font(.headline)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Text(interpretScore(latest.score))
                                            .font(.subheadline)
                                            .foregroundColor(scoreColor(latest.score))
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    // Take new assessment
                                }) {
                                    Text("Take New Assessment")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(hex: "FF9494"),
                                                    Color(hex: "FFC371")
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(25)
                                }
                            }
                        }
                        .padding(20)
                    }
                }
                
                // Mood Tracking
                VStack(alignment: .leading, spacing: 12) {
                    Text("Mood History")
                        .font(.headline)
                        .foregroundColor(Color.primary)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Last 7 Days")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.gray)
                            
                            HStack(alignment: .bottom, spacing: 12) {
                                ForEach(moodHistory, id: \.date) { entry in
                                    VStack {
                                        Text(moodEmoji(entry.level))
                                            .font(.system(size: 20))
                                        
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: moodGradient(entry.level)),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .frame(width: 24, height: CGFloat(entry.level) * 15)
                                        
                                        Text(formattedDayOfWeek(entry.date))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .frame(height: 140)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Current Streak:")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    Text("7 Days")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex: "FF9494"))
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    // Log today's mood
                                }) {
                                    Text("Log Today's Mood")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(hex: "FF9494"),
                                                    Color(hex: "FFC371")
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(25)
                                }
                            }
                        }
                        .padding(20)
                    }
                }
                
                // Goal Progress
                VStack(alignment: .leading, spacing: 12) {
                    Text("Goal Progress")
                        .font(.headline)
                        .foregroundColor(Color.primary)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(goalProgress, id: \.title) { goal in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(goal.title)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Spacer()
                                        
                                        Text("\(goal.completed)/\(goal.total)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color(hex: "F5F5F5"))
                                                .frame(height: 10)
                                            
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color(hex: "FF9494"),
                                                            Color(hex: "FFC371")
                                                        ]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(width: (CGFloat(goal.completed) / CGFloat(goal.total)) * geometry.size.width, height: 10)
                                        }
                                    }
                                    .frame(height: 10)
                                }
                            }
                            
                            Button(action: {
                                // Add new goal
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add New Goal")
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: "FF9494"))
                                .padding(.top, 8)
                            }
                        }
                        .padding(20)
                    }
                }
                
                // Weekly insights
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "FF9494").opacity(0.1),
                                    Color(hex: "FFC371").opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Insight")
                            .font(.headline)
                            .foregroundColor(Color.primary)
                        
                        Text("Your mood has been improving steadily over the past week. Keep doing what's working - your regular sleep schedule and daily walks appear to be helping.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                // View detailed insights
                            }) {
                                Text("View Details")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(hex: "FF9494"))
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .padding()
        }
        .background(Color(hex: "FAFAFA").edgesIgnoringSafeArea(.all))
    }
    
    // Helper functions
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    private func formattedDayOfWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    private func scoreColor(_ score: Int) -> Color {
        if score >= 13 {
            return Color.red
        } else if score >= 10 {
            return Color.orange
        } else {
            return Color.green
        }
    }
    
    private func interpretScore(_ score: Int) -> String {
        if score >= 13 {
            return "Possible depression"
        } else if score >= 10 {
            return "Mild symptoms"
        } else {
            return "Minimal risk"
        }
    }
    
    private func moodEmoji(_ level: Int) -> String {
        switch level {
        case 1: return "😢"
        case 2: return "😔"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😄"
        default: return "😐"
        }
    }
    
    private func moodGradient(_ level: Int) -> [Color] {
        switch level {
        case 1, 2:
            return [Color(hex: "7CB9E8"), Color(hex: "B6D0E2")] // Blue for sad
        case 3:
            return [Color(hex: "B6B6B6"), Color(hex: "D0D0D0")] // Gray for neutral
        case 4, 5:
            return [Color(hex: "FF9494"), Color(hex: "FFC371")] // Pink-yellow for happy
        default:
            return [Color(hex: "B6B6B6"), Color(hex: "D0D0D0")]
        }
    }
}

// Model structures
struct AssessmentEntry {
    let date: Date
    let score: Int
    let type: String
}

struct MoodEntry {
    let date: Date
    let level: Int // 1-5 where 1 is sad, 5 is happy
}

struct GoalEntry {
    let title: String
    let completed: Int
    let total: Int
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
    }
}
