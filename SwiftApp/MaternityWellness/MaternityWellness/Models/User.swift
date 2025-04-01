import Foundation

struct User: Identifiable, Codable {
    let id: Int
    let username: String
    let email: String
    let fullName: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case fullName = "full_name"
        case createdAt = "created_at"
    }
}