import Firebase
import FirebaseStorage

class FirestoreService: ObservableObject {
    static let shared = FirestoreService()
    let db = Firestore.firestore()
    
    init() {}
    
    func updateUserPhoto(userId: String, photoData: Data, completion: @escaping (Result<URL, Error>) -> Void) {
        let storageRef = Storage.storage().reference().child("users/\(userId)/profilePhoto.jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(photoData, metadata: metadata) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url))
                }
            }
        }
    }
    
    func updateUserProfile(userId: String, username: String, completion: @escaping (Error?) -> Void) {
        let userRef = db.collection("users").document(userId)
        
        userRef.updateData([
            "username": username
        ]) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func addReaction(chatId: String, messageId: String, reaction: String, userId: String, completion: @escaping (Error?) -> Void) {
        let messageRef = Firestore.firestore().collection("chats").document(chatId).collection("messages").document(messageId)
        messageRef.updateData(["reactions.\(userId)": reaction], completion: completion)
    }
    
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
    
    func observeTypingStatus(chatId: String, completion: @escaping (Bool) -> Void) -> ListenerRegistration? {
        return Firestore.firestore().collection("chats").document(chatId)
            .addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    print("Error observing typing status: \(error.localizedDescription)")
                    return
                }
                guard let document = documentSnapshot else { return }
                let isTyping = document.get("typing") as? Bool ?? false
                completion(isTyping)
            }
    }
    
    func markMessageAsRead(chatId: String, messageId: String) {
        Firestore.firestore().collection("chats").document(chatId).collection("messages").document(messageId)
            .updateData(["isRead": true])
    }
    
    func sendImageMessage(chatId: String, image: UIImage, completion: @escaping (Error?) -> Void) {
        let storageRef = Storage.storage().reference().child("chat_images/\(UUID().uuidString).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(NSError(domain: "ImageConversion", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG"]))
            return
        }
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(error)
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(error)
                    return
                }
                if let url = url {
                    self.sendMessage(chatId: chatId, content: "", imageUrl: url.absoluteString, completion: completion)
                }
            }
        }
    }
    
    func sendMessage(chatId: String, content: String, imageUrl: String? = nil, completion: @escaping (Error?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "FirebaseAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let message = Message(id: UUID().uuidString, content: content, senderId: currentUserId, timestamp: Timestamp(), imageUrl: imageUrl)
        
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
