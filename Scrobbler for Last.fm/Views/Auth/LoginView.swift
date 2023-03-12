//
//  LoginView.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 02/02/2023.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authController: AuthController
    
    @StateObject var vm = LoginViewModel()
    
    var body: some View {
        
        VStack {
            Text("Welcome to Scrobbler for Last.fm")
                .font(.title)
            Text("Click the `login` button to log in with Last.fm")
            
            Button("Log in") {
                Task { await vm.openLogin() }
            }.disabled(vm.token != nil)
                .padding()
            if vm.token != nil {
                HStack(spacing: 10) {
                    Text("Loading...")
                        .font(.headline)
                    ProgressView()
                }
            }
        }.task(id: vm.repeating) {
            await vm.load()
        }
    }
}

final class LoginViewModel: ObservableObject {
    @Published var repeating: Int = 0
    @Published var session: LFMSession?
    @Published var token: String?
    
    
    init() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            self.repeating += 1
        }
    }
    
    func openLogin() async {
        let token = await AuthController.shared.openLogin()
        DispatchQueue.main.async {
            self.token = token
        }
    }
    
    func load() async {
        guard let token = self.token else { return }
        do {
            let data = try await LastfmAPI.auth.getSession(token: token)
            
            DispatchQueue.main.async {
                self.session = data
                AuthController.shared.logIn(session: data)
            }
        } catch(let err) {
            print(err)
        }
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
