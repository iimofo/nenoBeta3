import SwiftUI
import Firebase
import Combine

struct addPostView: View {
    @State private var postText = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var userInfo: UserInfo? = nil
    @State private var isAddPostPresentedStatus = false
    @Binding var isAddPostPresented: Bool
    let textLimit = 80 //Your limit

//    var ExpoInfo = ExploreView()
    @EnvironmentObject var firestoreService: FirestoreService

    var body: some View {
        VStack {
            Text("Type you post Otto 😉")
                .padding(.top)
            TextField("type fast...", text: $postText, axis: .vertical)
                .textFieldStyle(MyTextFieldStyle())
                .onReceive(Just(postText)) { _ in limitText(textLimit) }
            
//            Spacer()
            Button(action: createPost) {
                Image(systemName: "square.and.arrow.up.fill")
                    .font(.system(size: 30))
                    .frame(width: UIScreen.main.bounds.width - 50, height: 50)
                    .foregroundColor(.primary)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
            }
            .padding(.trailing, 10)
            Spacer()
        }
        .onAppear {
            fetchUserInfo()
        }
    }

    func fetchUserInfo() {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "No user is signed in."
            self.showError = true
            return
        }

        // Fetch user info from Firebase
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).addSnapshotListener { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.userInfo = UserInfo(
                    name: data?["username"] as? String ?? "No Name",
                    email: data?["email"] as? String ?? "No Email",
                    profileImageUrl: data?["profileImageUrl"] as? String
                )
            } else {
                self.errorMessage = "Error fetching user data: \(error?.localizedDescription ?? "Unknown error")"
                self.showError = true
            }
        }
    }

    func createPost() {
        guard !postText.isEmpty else { return }

        let newPost = Post(
            id: UUID().uuidString,
            username: userInfo?.name ?? "Unknown",
            content: postText,
            timestamp: Date()
        )

        Firestore.firestore().collection("posts").addDocument(data: newPost.toDictionary()) { error in
            if let error = error {
                print("Error adding post: \(error.localizedDescription)")
            } else {
                postText = ""
                isAddPostPresented = false
            }
        }
    }

    func limitText(_ upper: Int) {
        if postText.count > upper {
            postText = String(postText.prefix(upper))
        }
    }
}

struct MyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.gray, lineWidth: 3)
        ).padding()
    }
}

#Preview {
    addPostView(isAddPostPresented: .constant(false))
        .environmentObject(FirestoreService())
}
