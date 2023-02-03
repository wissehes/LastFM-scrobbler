//
//  Scrobbler_for_Last_fmApp.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 01/02/2023.
//

import SwiftUI

@main
struct Scrobbler_for_Last_fmApp: App {
    
    @StateObject var authController = AuthController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authController)
        }.commands {
            CommandGroup(replacing: .appSettings) {
                Button("Log out") {
                    authController.logOut()
                }
            }
        }
    }
}
