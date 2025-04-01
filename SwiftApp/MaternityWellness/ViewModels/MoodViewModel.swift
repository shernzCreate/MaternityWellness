import Foundation

class MoodViewModel: ObservableObject {
    @Published var userId: String
    @Published var todaysMood: MoodEntry?
    @Published var weeklyMoods: [MoodEntry] = []
    @Published var monthlyMoods: [MoodEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(userId: String) {
        self.userId = userId
        loadMoodData()
    }
    
    func loadMoodData() {
        isLoading = true
        errorMessage = nil
        
        // In a real implementation, would fetch from API or local database
        // For demo purposes, we'll simulate some mood data
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Generate some sample data for demo purposes
            self.generateSampleMoodData()
            self.isLoading = false
        }
    }
    
    func saveMoodEntry(mood: MoodType, notes: String?) {
        isLoading = true
        errorMessage = nil
        
        // Create the new mood entry
        let moodEntry = MoodEntry(
            userId: userId,
            mood: mood,
            notes: notes
        )
        
        // In a real implementation, would save to API or local database
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Update local state
            self.todaysMood = moodEntry
            
            // If updating an existing mood for today, replace it
            if let index = self.weeklyMoods.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: Date()) }) {
                self.weeklyMoods[index] = moodEntry
            } else {
                // Otherwise add to weekly moods
                self.weeklyMoods.append(moodEntry)
            }
            
            // Same for monthly moods
            if let index = self.monthlyMoods.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: Date()) }) {
                self.monthlyMoods[index] = moodEntry
            } else {
                self.monthlyMoods.append(moodEntry)
            }
            
            self.isLoading = false
        }
    }
    
    func getMoodTrend() -> String {
        guard !weeklyMoods.isEmpty else { return "Not enough data to show trend" }
        
        // This is a simple analysis - in a real app, this would be more sophisticated
        let sortedMoods = weeklyMoods.sorted { $0.date < $1.date }
        let moodValues = sortedMoods.map { mapMoodToValue($0.mood) }
        
        if moodValues.count < 3 {
            return "Track your mood for a few more days to see trends"
        }
        
        // Check last 3 moods for trend
        let recentMoods = Array(moodValues.suffix(3))
        if recentMoods[0] < recentMoods[1] && recentMoods[1] < recentMoods[2] {
            return "Your mood appears to be improving"
        } else if recentMoods[0] > recentMoods[1] && recentMoods[1] > recentMoods[2] {
            return "Your mood appears to be declining"
        } else {
            return "Your mood has been fluctuating"
        }
    }
    
    // Helper function to map mood to numerical value for trend analysis
    private func mapMoodToValue(_ mood: MoodType) -> Int {
        switch mood {
        case .great: return 5
        case .good: return 4
        case .okay: return 3
        case .sad: return 2
        case .anxious: return 1
        case .exhausted: return 0
        }
    }
    
    // For demo purposes only - generate sample mood data
    private func generateSampleMoodData() {
        // Clear existing data
        weeklyMoods = []
        monthlyMoods = []
        
        // Generate moods for the past week
        let calendar = Calendar.current
        let today = Date()
        
        // Today's mood (50% chance of having one)
        if Bool.random() {
            let todayMood = MoodEntry(
                userId: userId,
                mood: MoodType.allCases.randomElement()!,
                notes: "Sample mood for today"
            )
            todaysMood = todayMood
            weeklyMoods.append(todayMood)
            monthlyMoods.append(todayMood)
        }
        
        // Past 6 days
        for i in 1...6 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                // 70% chance of having recorded a mood each day
                if Double.random(in: 0...1) < 0.7 {
                    let entry = MoodEntry(
                        userId: userId,
                        date: date,
                        mood: MoodType.allCases.randomElement()!,
                        notes: Bool.random() ? "Sample mood note" : nil
                    )
                    weeklyMoods.append(entry)
                    monthlyMoods.append(entry)
                }
            }
        }
        
        // Add a few more entries for the rest of the month
        for i in 7...30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                // 50% chance of having recorded a mood each day
                if Double.random(in: 0...1) < 0.5 {
                    let entry = MoodEntry(
                        userId: userId,
                        date: date,
                        mood: MoodType.allCases.randomElement()!,
                        notes: Bool.random() ? "Sample mood note" : nil
                    )
                    monthlyMoods.append(entry)
                }
            }
        }
    }
}