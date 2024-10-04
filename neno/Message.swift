import Foundation
import FirebaseFirestore
import Firebase

struct Message: Codable, Identifiable {
    var id: String // Assuming 'id' is a unique identifier for the message
    var content: String
    var senderId: String // Assuming 'senderId' is used instead of 'sender'
    var timestamp: Timestamp // Assuming 'timestamp' is a FirebaseFirestore.Timestamp
    var reactions: [String: String] // Dictionary to store reactions, where key is userId and value is reaction
    var imageUrl: String? // Optional URL for the image
    
    // Computed property to determine if the message is sent by the current user
    var isSentByCurrentUser: Bool {
        return senderId == Auth.auth().currentUser?.uid
    }
    
    // Regular initializer
    init(id: String, content: String, senderId: String, timestamp: Timestamp, reactions: [String: String] = [:], imageUrl: String? = nil) {
        self.id = id
        self.content = content
        self.senderId = senderId
        self.timestamp = timestamp
        self.reactions = reactions
        self.imageUrl = imageUrl
    }
    
    // Function to convert Message to Dictionary for Firestore
    func asDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "content": content,
            "senderId": senderId,
            "timestamp": timestamp,
            "reactions": reactions
        ]
        if let imageUrl = imageUrl {
            dict["imageUrl"] = imageUrl
        }
        return dict
    }

    // Computed property to return formatted timestamp string
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp.dateValue())
    }
}
