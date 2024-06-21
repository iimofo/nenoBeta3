import SwiftUI

struct MessageView: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading) {
            HStack {
                if isCurrentUser {
                    Spacer()
                }
                VStack{
                    Text(message.content)
                        .padding()
                        .background(isCurrentUser ? Color.blue : Color.green.opacity(0.5))
                        .cornerRadius(10)
                        .foregroundColor(isCurrentUser ? .white : .primary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 5)
                    
                    Text(message.formattedTimestamp)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 5)
                }
                
                if !isCurrentUser {
                    Spacer()
                }
            }
            


        }
    }
}
