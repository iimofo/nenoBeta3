import SwiftUI
import Firebase

struct UserProfileView: View {
    let user: User
    @State private var errorMessage: String?
    @State private var navigateToChat: Bool = false
    @State private var chat: Chat?

    var body: some View {
        VStack {
            Text(user.username)
                .font(.largeTitle)
            Text(user.email)
                .font(.subheadline)
            // Add more user details here

            Button(action: {
                startChat(with: user)
            }) {
                Text("Start Chat")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationBarTitle(user.username)
        .background(
            NavigationLink(destination: ChatView(chat: chat ?? Chat(id: "", otherUser: user)), isActive: $navigateToChat) {
                EmptyView()
            }
        )
    }

    func startChat(with user: User) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not logged in."
            return
        }

        Firestore.firestore().collection("chats")
            .whereField("users", arrayContains: currentUserId)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = "Error checking for existing chat: \(error.localizedDescription)"
                    return
                }

                if let existingChat = snapshot?.documents.first(where: { document in
                    let users = document.data()["users"] as? [String] ?? []
                    return users.contains(user.uid)
                }) {
                    // Chat already exists, navigate to ChatView
                    let chatId = existingChat.documentID
                    fetchUser(userId: user.uid) { fetchedUser in
                        if let fetchedUser = fetchedUser {
                            self.chat = Chat(id: chatId, otherUser: fetchedUser)
                            self.navigateToChat = true
                        } else {
                            self.errorMessage = "Error fetching user."
                        }
                    }
                } else {
                    // Chat does not exist, create new chat
                    let chatRef = Firestore.firestore().collection("chats").document()
                    let chatId = chatRef.documentID
                    let chatData: [String: Any] = [
                        "users": [currentUserId, user.uid],
                        "createdAt": Timestamp()
                    ]
                    
                    chatRef.setData(chatData) { error in
                        if let error = error {
                            self.errorMessage = "Error creating chat: \(error.localizedDescription)"
                        } else {
                            fetchUser(userId: user.uid) { fetchedUser in
                                if let fetchedUser = fetchedUser {
                                    self.chat = Chat(id: chatId, otherUser: fetchedUser)
                                    self.navigateToChat = true
                                } else {
                                    self.errorMessage = "Error fetching user."
                                }
                            }
                        }
                    }
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
                user.documentID = snapshot.documentID // Assign the document ID
                completion(user)
            } catch {
                print("Error decoding user: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}
