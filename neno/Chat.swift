import Foundation

struct Chat: Identifiable {
    let id: String // Chat document ID in Firestore
    let otherUser: User // User model representing the other participant in the chat
}
