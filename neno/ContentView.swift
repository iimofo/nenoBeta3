import SwiftUI
import Firebase

struct ContentView: View {
    @AppStorage("isSignedIn") var isSignedIn = false

    var body: some View {
        NavigationView {
            VStack {
                if isSignedIn {
//                    NavigationLink(destination: ChatListView()) {
//                        Text("Chat List")
//                            .padding()
//                    }
//
//                    NavigationLink(destination: SearchView()) {
//                        Text("Search Users")
//                            .padding()
//                    }
//
//                    Button(action: signOut) {
//                        Text("Logout")
//                            .foregroundColor(.red)
//                            .padding()
//                    }
                } else {
                    LoginOrSignupView()
                }
            }
            .navigationBarTitle("Chat App")
        }
        .onAppear {
            // Check if user is signed in
            isSignedIn = Auth.auth().currentUser != nil
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            isSignedIn = false
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}
