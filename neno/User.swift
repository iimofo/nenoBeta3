import Foundation

struct User: Codable, Identifiable {
    var id: String { documentID }
    var documentID: String // Store document ID separately
    let uid: String
    var username: String
    var email: String
    var profileImageUrl: String? // Add this property

    enum CodingKeys: String, CodingKey {
        case uid
        case username
        case email
        case documentID
        case profileImageUrl // Add this key
    }
}

