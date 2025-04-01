import Foundation

struct Resource: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var content: String
    var category: ResourceCategory
    var type: ResourceType
    var source: String
    var url: URL?
    var readTime: Int // minutes
    var isFeatured: Bool
    var publishDate: Date
    
    init(id: String = UUID().uuidString, title: String, description: String, content: String, category: ResourceCategory, type: ResourceType, source: String, url: URL? = nil, readTime: Int, isFeatured: Bool = false, publishDate: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.content = content
        self.category = category
        self.type = type
        self.source = source
        self.url = url
        self.readTime = readTime
        self.isFeatured = isFeatured
        self.publishDate = publishDate
    }
}

enum ResourceCategory: String, CaseIterable, Codable {
    case mentalHealth = "Mental Health"
    case physicalHealth = "Physical Health"
    case infantCare = "Infant Care"
    case familySupport = "Family Support"
    case selfCare = "Self Care"
    case localSupport = "Singapore Resources"
    
    var icon: String {
        switch self {
        case .mentalHealth: return "brain"
        case .physicalHealth: return "heart.fill"
        case .infantCare: return "figure.and.child.holdinghands"
        case .familySupport: return "person.3.fill"
        case .selfCare: return "figure.mind.and.body"
        case .localSupport: return "mappin.and.ellipse"
        }
    }
    
    var color: String {
        switch self {
        case .mentalHealth: return "purple"
        case .physicalHealth: return "red"
        case .infantCare: return "blue"
        case .familySupport: return "indigo"
        case .selfCare: return "green"
        case .localSupport: return "pink"
        }
    }
}

enum ResourceType: String, CaseIterable, Codable {
    case article = "Article"
    case video = "Video"
    case audio = "Audio"
    case exercise = "Exercise"
    case contact = "Contact Information"
    
    var icon: String {
        switch self {
        case .article: return "doc.text"
        case .video: return "video.fill"
        case .audio: return "headphones"
        case .exercise: return "figure.run"
        case .contact: return "phone.fill"
        }
    }
}