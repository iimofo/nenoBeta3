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
                        Label("Chat`s", systemImage: "bubble.left.and.text.bubble.right.fill")
                    }
                    
                    NavigationView {
                        ExploreView()
                    }
                    .tabItem {
                        Label("Posts", systemImage: "pc")
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
                        Label("Settings", systemImage: "wrench.adjustable.fill")
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
