import SwiftUI
import Firebase
import PhotosUI
import FirebaseStorage

struct settingView: View {
    @AppStorage("isSignedIn") var isSignedIn = false
    @AppStorage("isDarkMode") var isDarkMode = false
    
    @State private var userInfo: UserInfo? = nil
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage? = nil
    @State private var uploadProgress: Double = 0.0
    @EnvironmentObject var firestoreService: FirestoreService

    var body: some View {
        ScrollView {
            VStack() {
                if let userInfo = userInfo {
                    // Display user info
                    HStack {
                        if let profileImageUrl = userInfo.profileImageUrl, let url = URL(string: profileImageUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
//                                        .scaledToFit()
                                        .scaledToFill()
                                        .frame(width: 75, height: 75)
                                        .clipShape(Circle())
                                case .failure:
                                    Image(systemName: "person.circle")
                                        .resizable()
                                        .frame(width: 75, height: 75)
                                        .foregroundColor(.blue)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 75, height: 75)
                                .foregroundColor(.blue)
                        }
                        VStack(alignment: .leading) {
                            Text(userInfo.name)
                                .font(.title)
                                .fontWeight(.bold)
                            Text(userInfo.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: {
                            isImagePickerPresented = true
                        }) {
                            Text("Change")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                       Spacer()
                    }
                    .padding(.top,1)
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
            .sheet(isPresented: $isImagePickerPresented, onDismiss: uploadProfilePhoto) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
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
                    email: data?["email"] as? String ?? "No Email",
                    profileImageUrl: data?["profileImageUrl"] as? String
                )
            } else {
                self.errorMessage = "Error fetching user data: \(error?.localizedDescription ?? "Unknown error")"
                self.showError = true
            }
        }
    }
    
    func uploadProfilePhoto() {
        guard let selectedImage = selectedImage, let user = Auth.auth().currentUser else { return }
        
        let storageRef = Storage.storage().reference().child("profile_photos/\(user.uid).jpg")
        if let imageData = selectedImage.jpegData(compressionQuality: 0.75) {
            let uploadTask = storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    self.errorMessage = "Error uploading profile photo: \(error.localizedDescription)"
                    self.showError = true
                    return
                }
                
                storageRef.downloadURL { url, error in
                    if let error = error {
                        self.errorMessage = "Error getting download URL: \(error.localizedDescription)"
                        self.showError = true
                        return
                    }
                    
                    guard let downloadURL = url else { return }
                    
                    let db = Firestore.firestore()
                    db.collection("users").document(user.uid).updateData([
                        "profileImageUrl": downloadURL.absoluteString
                    ]) { error in
                        if let error = error {
                            self.errorMessage = "Error updating user data: \(error.localizedDescription)"
                            self.showError = true
                            return
                        }
                        
                        self.fetchUserInfo() // Refresh user info to show updated profile photo
                    }
                }
            }
            
            uploadTask.observe(.progress) { snapshot in
                self.uploadProgress = Double(snapshot.progress?.fractionCompleted ?? 0)
            }
        }
    }
}

struct UserInfo {
    var name: String
    var email: String
    var profileImageUrl: String?
}

struct ImagePicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    self.parent.selectedImage = image as? UIImage
                }
            }
        }
    }

    @Binding var selectedImage: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}


#Preview {
    settingView()
        .environmentObject(FirestoreService())
}
