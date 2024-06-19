import SwiftUI
import Firebase

struct SearchView: View {
    @State private var searchText = ""
    @State private var users: [User] = []
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            TextField("Search for users...", text: $searchText, onCommit: searchUsers)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            List(users) { user in
                NavigationLink(destination: UserProfileView(user: user)) {
                    Text(user.username)
                }
            }
        }
        .navigationBarTitle("Search Users", displayMode: .inline)
    }

    func searchUsers() {
        guard !searchText.isEmpty else {
            return
        }

        Firestore.firestore().collection("users")
            .whereField("username", isGreaterThanOrEqualTo: searchText)
            .whereField("username", isLessThanOrEqualTo: searchText + "\u{f8ff}")
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = "Error searching users: \(error.localizedDescription)"
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.errorMessage = "No users found."
                    return
                }

                self.users = documents.compactMap { doc -> User? in
                    try? doc.data(as: User.self)
                }
            }
    }
}
