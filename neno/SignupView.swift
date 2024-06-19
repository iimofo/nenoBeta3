import SwiftUI
import Firebase

struct RegisterView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: register) {
                Text("Register")
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
        .padding()
        .navigationBarTitle("Register")
    }

    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }

            guard let user = authResult?.user else {
                self.errorMessage = "User registration failed."
                return
            }

            // Save user info to Firestore
            let userInfo = User(documentID: user.uid, uid: user.uid, username: username, email: email)
            saveUserToFirestore(userInfo)
        }
    }

    func saveUserToFirestore(_ user: User) {
        let db = Firestore.firestore()
        do {
            try db.collection("users").document(user.uid).setData(from: user) { error in
                if let error = error {
                    self.errorMessage = "Failed to save user data: \(error.localizedDescription)"
                } else {
                    // Navigate to the next view or indicate success
                    self.errorMessage = nil
                }
            }
        } catch {
            self.errorMessage = "Failed to encode user data: \(error.localizedDescription)"
        }
    }
}
