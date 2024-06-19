import SwiftUI
import Firebase

struct settingView: View {
    @AppStorage("isSignedIn") var isSignedIn = false
    @AppStorage("isDarkMode") var isDarkMode = false
    
    @State private var userInfo: UserInfo? = nil
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let userInfo = userInfo {
                        // Display user info
                        HStack {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text(userInfo.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text(userInfo.email)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                    } else {
                        // Loading or error state
                        if showError {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                        } else {
                            ProgressView()
                        }
                    }
                    
                    Toggle(isOn: $isDarkMode) {
                        Text("Dark Mode")
                            .font(.headline)
                    }
                    .padding()
                    
                    Spacer()
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Logout") {
                            print("Pressed")
                            signOut()
                        }
                    }
                }
                .alert(isPresented: $showError) {
                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
                .onAppear {
                    fetchUserInfo()
                }
            }
        }
        .navigationTitle("Settings")
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isSignedIn = false
        } catch let signOutError as NSError {
            errorMessage = "Error signing out: \(signOutError.localizedDescription)"
            showError = true
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
        db.collection("users").document(user.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.userInfo = UserInfo(
                    name: data?["username"] as? String ?? "No Name",
                    email: data?["email"] as? String ?? "No Email"
                )
            } else {
                self.errorMessage = "Error fetching user data: \(error?.localizedDescription ?? "Unknown error")"
                self.showError = true
            }
        }
    }
}

struct UserInfo {
    var name: String
    var email: String
}

#Preview {
    settingView()
}
