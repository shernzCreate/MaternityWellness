import Foundation

struct User: Identifiable, Codable {
    var id: String = UUID().uuidString
    var username: String
    var fullName: String
    var email: String
    var profileImage: String?
    var dateCreated: Date = Date()
    var isVerified: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case fullName
        case email
        case profileImage
        case dateCreated
        case isVerified
    }
}