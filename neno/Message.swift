import Foundation
import FirebaseFirestore

struct Message: Codable, Identifiable {
    var id: String // Assuming 'id' is a unique identifier for the message
    var content: String
    var senderId: String // Assuming 'senderId' is used instead of 'sender'
    var timestamp: Timestamp // Assuming 'timestamp' is a FirebaseFirestore.Timestamp

    // Function to convert Message to Dictionary for Firestore
    func asDictionary() -> [String: Any] {
        return [
            "id": id,
            "content": content,
            "senderId": senderId,
            "timestamp": timestamp
        ]
    }

    // Computed property to return formatted timestamp string
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp.dateValue())
    }
}
