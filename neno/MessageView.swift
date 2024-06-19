import SwiftUI

struct MessageView: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading) {
            Text(message.content)
                .padding()
                .background(isCurrentUser ? Color.blue : Color.green.opacity(0.5))
                .cornerRadius(10)
                .foregroundColor(isCurrentUser ? .white : .primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
            
            
            Text(message.formattedTimestamp)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal, 10)
//                .padding(.bottom, 5)
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
//        .padding(.vertical, 4)
    }
}
