import SwiftUI
import Firebase

struct MainView: View {
    @AppStorage("isSignedIn") var isSignedIn = false
    
    var body: some View {
        NavigationView {
            if isSignedIn {
                TabView {
                    NavigationView {
                        ChatListView()
                    }
                    .tabItem {
                        Label("Chat List", systemImage: "ellipsis.message.fill")
                    }
                    
                    NavigationView {
                        SearchView()
                    }
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    
                    NavigationView {
                        settingView()
                    }
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                }
            } else {
                LoginOrSignupView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            // Check if user is signed in
            isSignedIn = Auth.auth().currentUser != nil
        }
    }
}
