import Foundation

struct User: Codable, Identifiable {
    var id: String { documentID }
    var documentID: String // Store document ID separately
    let uid: String
    var username: String
    var email: String
    // Add other properties as needed

    enum CodingKeys: String, CodingKey {
        case uid
        case username
        case email
        case documentID
    }
}
