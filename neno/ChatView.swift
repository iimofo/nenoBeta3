import SwiftUI
import Firebase

struct ChatView: View {
    let chat: Chat
    
    @State private var messageText = ""
    @State private var messages: [Message] = []
    @State private var listener: ListenerRegistration?
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(messages) { message in
                            MessageView(message: message, isCurrentUser: message.senderId == Auth.auth().currentUser?.uid)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let lastMessage = messages.last {
                        scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            
            HStack {
                TextField("Type your message...", text: $messageText)
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
        }
        .onDisappear {
            listener?.remove()
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
}
