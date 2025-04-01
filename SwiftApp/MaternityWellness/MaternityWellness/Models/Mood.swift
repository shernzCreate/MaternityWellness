import SwiftUI

enum MoodType: String, CaseIterable, Codable {
    case great = "Great"
    case good = "Good"
    case okay = "Okay"
    case sad = "Sad"
    case terrible = "Terrible"
    
    var emoji: String {
        switch self {
        case .great: return "😄"
        case .good: return "🙂"
        case .okay: return "😐"
        case .sad: return "😔"
        case .terrible: return "😞"
        }
    }
    
    var color: String {
        switch self {
        case .great: return "GreatMood"
        case .good: return "GoodMood"
        case .okay: return "OkayMood"
        case .sad: return "SadMood"
        case .terrible: return "TerribleMood"
        }
    }
}

struct Mood: Identifiable, Codable {
    let id: Int
    let userId: Int
    let mood: MoodType
    let notes: String?
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case mood
        case notes
        case date
    }
}

// ViewModel for mood tracking
class MoodViewModel: ObservableObject {
    @Published var moods: [Mood] = []
    @Published var todayMood: Mood? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func loadMoods() {
        isLoading = true
        
        // In a real app, this would be an API call
        // For demo purposes, we'll load sample data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.moods = self.getSampleMoods()
            self.todayMood = self.getTodaysMood()
            self.isLoading = false
        }
    }
    
    func saveMood(mood: MoodType, notes: String?) {
        isLoading = true
        
        // In a real app, this would be an API call
        // For demo purposes, we'll just update the local state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Create a new mood or update existing
            if self.todayMood != nil {
                // Update existing mood
                let updatedMood = Mood(
                    id: self.todayMood!.id,
                    userId: 1, // Hardcoded for demo
                    mood: mood,
                    notes: notes,
                    date: Date()
                )
                
                // Find and replace the mood in the array
                if let index = self.moods.firstIndex(where: { $0.id == updatedMood.id }) {
                    self.moods[index] = updatedMood
                }
                
                self.todayMood = updatedMood
            } else {
                // Create new mood
                let newId = (self.moods.map { $0.id }.max() ?? 0) + 1
                let newMood = Mood(
                    id: newId,
                    userId: 1, // Hardcoded for demo
                    mood: mood,
                    notes: notes,
                    date: Date()
                )
                
                self.moods.append(newMood)
                self.todayMood = newMood
            }
            
            self.isLoading = false
        }
    }
    
    func getMoodsForLastWeek() -> [Mood] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let weekAgo = calendar.date(byAdding: .day, value: -6, to: today) else {
            return []
        }
        
        return moods.filter { mood in
            let moodDate = calendar.startOfDay(for: mood.date)
            return moodDate >= weekAgo && moodDate <= today
        }
    }
    
    private func getTodaysMood() -> Mood? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return moods.first { mood in
            calendar.isDate(mood.date, inSameDayAs: today)
        }
    }
    
    // Sample mood data for demonstration purposes
    private func getSampleMoods() -> [Mood] {
        let calendar = Calendar.current
        let today = Date()
        
        var sampleMoods: [Mood] = []
        
        for i in 0..<10 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else {
                continue
            }
            
            // Skip some days to show real-world usage where user might not log every day
            if i != 0 && i % 3 == 0 {
                continue
            }
            
            let moodTypes: [MoodType] = [.great, .good, .okay, .sad, .terrible]
            let randomMood = moodTypes[Int.random(in: 0..<moodTypes.count)]
            let notes = i % 2 == 0 ? "Sample note for day \(i)" : nil
            
            sampleMoods.append(
                Mood(
                    id: i + 1,
                    userId: 1,
                    mood: randomMood,
                    notes: notes,
                    date: date
                )
            )
        }
        
        return sampleMoods
    }
}