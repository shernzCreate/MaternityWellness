import Foundation

struct User: Identifiable, Codable {
    var id: String
    var email: String
    var name: String
    var joinDate: Date
    
    init(id: String = UUID().uuidString, email: String, name: String, joinDate: Date = Date()) {
        self.id = id
        self.email = email
        self.name = name
        self.joinDate = joinDate
    }
}