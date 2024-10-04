import SwiftUI
import Firebase
import UserNotifications

struct ChatView: View {
    let chat: Chat
    
    @State private var messageText = ""
    @State private var messages: [Message] = []
    @State private var listener: ListenerRegistration?
    @State private var selectedMessageId: String?
    @EnvironmentObject var firestoreService: FirestoreService
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(messages) { message in
                            VStack(alignment: .leading) {
                                MessageView(message: message, isCurrentUser: message.senderId == Auth.auth().currentUser?.uid)
                                    .id(message.id)
                                    .transition(.move(edge: .bottom))
                                    .animation(.snappy, value: messages.count)
                                    .contextMenu {
                                        ForEach(["👍", "😂", "😢", "❤️", "😮", "👏"], id: \.self) { reaction in
                                            Button(action: {
                                                addReaction(to: message, reaction: reaction)
                                            }) {
                                                Text(reaction)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                
                                if !message.reactions.isEmpty {
                                    HStack {
                                        ForEach(message.reactions.keys.sorted(), id: \.self) { userId in
                                            Text(message.reactions[userId] ?? "")
                                                .padding(4)
                                                .background(Color.gray.opacity(0.2))
                                                .cornerRadius(8)
                                        }
                                    }
                                    .padding(message.isSentByCurrentUser ? .trailing : .leading, 2) // Adjust padding based on sender
                                    .frame(maxWidth: .infinity, alignment: message.isSentByCurrentUser ? .trailing : .leading)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    if let lastMessage = messages.last {
                        scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            
            HStack {
                TextField("Type fast...", text: $messageText)
                    .padding(10)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .padding(.top, 5)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                }
                .padding(.trailing, 10)
                
            }
            .padding(.bottom, 10)
            .background(Color(UIColor.systemGray5))
        }
        .navigationBarTitle(chat.otherUser.username, displayMode: .inline)
        .onAppear {
            fetchMessages()
            authorizeNotification()
        }
        .onDisappear {
            listener?.remove()
        }
    }
    
    func authorizeNotification(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification authorization granted.")
            } else if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchMessages() {
        listener = FirestoreService.shared.observeMessages(chatId: chat.id) { messages in
            self.messages = messages
        }
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        FirestoreService.shared.sendMessage(chatId: chat.id, content: messageText) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                messageText = "" // Clear message text field after sending message
            }
        }
    }
    
    func addReaction(to message: Message, reaction: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        FirestoreService.shared.addReaction(chatId: chat.id, messageId: message.id, reaction: reaction, userId: userId) { error in
            if let error = error {
                print("Error adding reaction: \(error.localizedDescription)")
            }
        }
    }
}

struct MessageListView: View {
    var messages: [Message]
    
    var body: some View {
        List(messages) { message in
            MessageView(message: message, isCurrentUser: message.senderId == Auth.auth().currentUser?.uid)
        }
    }
}

//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        let sampleUser = User(
//            documentID: "sampleDocumentID",
//            uid: "sampleUID",
//            username: "Sample User",
//            email: "sampleuser@example.com",
//            profileImageUrl: nil
//        )
//        
//        let sampleChat = Chat(
//            id: "sampleChatId",
//            otherUser: sampleUser
//        )
//        
//        ChatView(chat: sampleChat)
//            .environmentObject(FirestoreService())
//    }
//}
//#Preview {
//    MainView()
//        .environmentObject(FirestoreService())
//}
