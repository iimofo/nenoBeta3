import Firebase

class FirestoreService {
    static let shared = FirestoreService()
    
    private init() {}
    
    func observeMessages(chatId: String, completion: @escaping ([Message]) -> Void) -> ListenerRegistration? {
        return Firestore.firestore().collection("chats").document(chatId).collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents in snapshot")
                    return
                }
                
                let messages = documents.compactMap { doc -> Message? in
                    try? doc.data(as: Message.self)
                }
                
                completion(messages)
            }
    }
    

    func sendMessage(chatId: String, content: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "FirebaseAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let message = Message(id: UUID().uuidString, content: content, senderId: currentUserId, timestamp: Timestamp())
        
        Firestore.firestore().collection("chats").document(chatId).collection("messages").document(message.id).setData(message.asDictionary()) { error in
            completion(error)
        }
    }

}

extension Encodable {
    func asDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else {
            return [:]
        }
        return dictionary
    }
}
