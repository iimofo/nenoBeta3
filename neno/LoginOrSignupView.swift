//
//  LoginOrSignupView.swift
//  neno
//
//  Created by Mustafa Hashim on 14.06.2024.
//

import SwiftUI

struct LoginOrSignupView: View {
    var body: some View {
        TabView {
            LoginView()
                .tabItem {
                    Label("Login", systemImage: "person.fill")
                }
                .tag(0)

            RegisterView()
                .tabItem {
                    Label("Sign Up", systemImage: "person.badge.plus.fill")
                }
                .tag(1)
        }
        .padding()
    }
}

#Preview {
    LoginOrSignupView()
}
