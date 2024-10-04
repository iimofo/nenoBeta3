import SwiftUI
import Firebase

struct ExploreView: View {
    @State private var posts: [Post] = []
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var userInfo: UserInfo? = nil
    @State private var isAddPostPresented: Bool = false

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(posts) { post in
                        HStack {
                            VStack(alignment: .leading) {
                                
                                Text("@" + post.username)
                                    .font(.headline)
                                    .padding(.bottom, 2)
                                
                                Text(post.content)
                                    .multilineTextAlignment(.leading)
                                    .font(.body)
                                    .padding()
                                    .frame(width: UIScreen.main.bounds.width - 50, alignment: .leading)
                                    
//                                    .background(Color(UIColor.systemGray6))
//                                    .cornerRadius(10)
                                    
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                            Spacer()
                        }
                        Divider()
                    }
                    
                    .padding(.bottom, 5)
                    
                }
                
                .padding(.leading, 10)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Post") {
                    isAddPostPresented.toggle()
                }
            }
        }
        .sheet(isPresented: $isAddPostPresented, onDismiss: didDismiss, content: {
            addPostView(isAddPostPresented: $isAddPostPresented)
        })
        .onAppear {
            fetchPosts()
        }
    }

    func didDismiss() {
        isAddPostPresented = false
    }

    func fetchPosts() {
        Firestore.firestore().collection("posts")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching posts: \(error.localizedDescription)")
                } else {
                    if let snapshot = snapshot {
                        posts = snapshot.documents.compactMap { doc -> Post? in
                            try? doc.data(as: Post.self)
                        }
                    }
                }
            }
    }
}

struct Post: Identifiable, Codable {
    var id: String
    var username: String
    var content: String
    var timestamp: Date

    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "username": username,
            "content": content,
            "timestamp": timestamp
        ]
    }
}


#Preview {
    ExploreView()
        .environmentObject(FirestoreService())
}
