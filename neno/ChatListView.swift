import SwiftUI
import Firebase
import UserNotifications

struct ChatListView: View {
    @State private var chats: [Chat] = []
    @State private var listener: ListenerRegistration?
    @State private var randomString: String = ""
    
    var body: some View {
        List(chats) { chat in
            NavigationLink(destination: ChatView(chat: chat)) {
                HStack {
                    if let profileImageUrl = chat.otherUser.profileImageUrl, let url = URL(string: profileImageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            case .failure:
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                    }

                    VStack(alignment: .leading) {
                        Text(chat.otherUser.username)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(randomString)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .onAppear {
            fetchChats()
            randomString = generateRandomString(length: 25)
            authorizeNotification()
        }
        .onDisappear {
            listener?.remove()
        }
    }
    
    func fetchChats() {
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        listener = Firestore.firestore().collection("chats")
            .whereField("users", arrayContains: currentUserId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching chats: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents in snapshot")
                    return
                }
                
                var fetchedChats: [Chat] = []
                let dispatchGroup = DispatchGroup()
                
                documents.forEach { document in
                    let chatId = document.documentID
                    let data = document.data()
                    
                    guard let users = data["users"] as? [String] else {
                        print("Users array not found or invalid")
                        return
                    }
                    
                    let otherUserId = users.first { $0 != currentUserId } ?? ""
                    guard !otherUserId.isEmpty else {
                        print("Other user ID is empty")
                        return
                    }
                    
                    dispatchGroup.enter()
                    
                    fetchUser(userId: otherUserId) { user in
                        if let user = user {
                            let chat = Chat(id: chatId, otherUser: user)
                            fetchedChats.append(chat)
                        } else {
                            print("User is nil for userId: \(otherUserId)")
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.chats = fetchedChats
                }
            }
    }
    
    func fetchUser(userId: String, completion: @escaping (User?) -> Void) {
        Firestore.firestore().collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                print("Snapshot does not exist")
                completion(nil)
                return
            }
            
            do {
                var user = try snapshot.data(as: User.self)
                user.documentID = snapshot.documentID
                completion(user)
            } catch {
                print("Error decoding user: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func generateRandomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    func authorizeNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
}
