import SwiftUI
import Combine

class MoodViewModel: ObservableObject {
    @Published var moods: [Mood] = []
    @Published var todayMood: Mood?
    @Published var isLoading = false
    
    init() {
        loadMoods()
    }
    
    func loadMoods() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // In a real app, this would fetch from backend/storage
            // For demo, we're creating sample data if empty
            if self.moods.isEmpty {
                let calendar = Calendar.current
                
                // Create sample data for the past week
                var sampleMoods: [Mood] = []
                
                for day in 0..<7 {
                    if let date = calendar.date(byAdding: .day, value: -day, to: Date()) {
                        // Skip today as we'll handle it separately
                        if day > 0 {
                            let moodTypes: [MoodType] = [.great, .good, .okay, .sad, .terrible]
                            let randomMood = moodTypes.randomElement() ?? .okay
                            
                            sampleMoods.append(
                                Mood(
                                    id: UUID().uuidString,
                                    userId: "current-user-id", // In real app, get from auth
                                    mood: randomMood,
                                    notes: "Sample mood for testing",
                                    date: date
                                )
                            )
                        }
                    }
                }
                
                self.moods = sampleMoods.sorted(by: { $0.date > $1.date })
            }
            
            // Check if we have a mood entry for today
            let today = Calendar.current.startOfDay(for: Date())
            self.todayMood = self.moods.first(where: { 
                Calendar.current.isDate($0.date, inSameDayAs: today)
            })
            
            self.isLoading = false
        }
    }
    
    func saveMood(mood: MoodType, notes: String?) {
        isLoading = true
        
        let newMood = Mood(
            id: UUID().uuidString,
            userId: "current-user-id", // In real app, get from auth
            mood: mood,
            notes: notes,
            date: Date()
        )
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Remove existing mood for today if exists
            if let existingMood = self.todayMood {
                self.moods.removeAll(where: { $0.id == existingMood.id })
            }
            
            // Add new mood
            self.moods.insert(newMood, at: 0)
            self.todayMood = newMood
            
            self.isLoading = false
        }
    }
    
    func getMoodsForLastWeek() -> [Mood] {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return moods.filter { $0.date >= oneWeekAgo }
            .sorted(by: { $0.date < $1.date })
    }
    
    func getMoodCount(for mood: MoodType, in moods: [Mood]) -> Int {
        return moods.filter { $0.mood == mood }.count
    }
}