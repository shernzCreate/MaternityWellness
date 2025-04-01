import Foundation

enum ResourceType: String, CaseIterable, Codable {
    case article = "Article"
    case video = "Video"
    case audio = "Audio"
    case infographic = "Infographic"
    case exercise = "Exercise"
    
    var icon: String {
        switch self {
        case .article:
            return "doc.text"
        case .video:
            return "play.rectangle"
        case .audio:
            return "headphones"
        case .infographic:
            return "chart.bar"
        case .exercise:
            return "figure.walk"
        }
    }
}

enum ResourceCategory: String, CaseIterable, Codable {
    case mentalHealth = "Mental Health"
    case physicalHealth = "Physical Health"
    case parenting = "Parenting"
    case relationships = "Relationships"
    case nutrition = "Nutrition"
    case sleep = "Sleep"
    case exercise = "Exercise"
    case emergency = "Emergency"
    case singaporeResources = "Singapore Resources"
    
    var color: String {
        switch self {
        case .mentalHealth:
            return "Purple"
        case .physicalHealth:
            return "Blue"
        case .parenting:
            return "Green"
        case .relationships:
            return "Pink"
        case .nutrition:
            return "Orange"
        case .sleep:
            return "Indigo"
        case .exercise:
            return "Red"
        case .emergency:
            return "Red"
        case .singaporeResources:
            return "AccentColor"
        }
    }
}

struct Resource: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var description: String
    var content: String
    var type: ResourceType
    var category: ResourceCategory
    var author: String?
    var source: String?
    var publishDate: Date?
    var lastUpdated: Date?
    var readTime: Int?
    var videoUrl: String?
    var audioUrl: String?
    var featured: Bool = false
    var tags: [String] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case content
        case type
        case category
        case author
        case source
        case publishDate
        case lastUpdated
        case readTime
        case videoUrl
        case audioUrl
        case featured
        case tags
    }
}