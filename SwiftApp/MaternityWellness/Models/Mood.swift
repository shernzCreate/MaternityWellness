import Foundation

enum MoodType: String, CaseIterable, Codable {
    case great = "Great"
    case good = "Good"
    case okay = "Okay"
    case sad = "Sad"
    case anxious = "Anxious"
    case exhausted = "Exhausted"
    
    var emoji: String {
        switch self {
        case .great:
            return "😄"
        case .good:
            return "🙂"
        case .okay:
            return "😐"
        case .sad:
            return "😞"
        case .anxious:
            return "😰"
        case .exhausted:
            return "😫"
        }
    }
    
    var color: String {
        switch self {
        case .great:
            return "Green"
        case .good:
            return "LightGreen"
        case .okay:
            return "Yellow"
        case .sad:
            return "Orange"
        case .anxious:
            return "Purple"
        case .exhausted:
            return "Red"
        }
    }
}

struct MoodEntry: Identifiable, Codable {
    var id: String = UUID().uuidString
    var userId: String
    var date: Date = Date()
    var mood: MoodType
    var notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case date
        case mood
        case notes
    }
}