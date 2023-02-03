//
//  LoginView.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 02/02/2023.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authController: AuthController
    
    @State var token: String?
    @State var session: LFMSession?
    
    @StateObject var vm = LoginViewModel()
    
    var body: some View {
        if let token = token {
            waitView(token)
        } else {
            buttonView
        }
    }
    
    func waitView(_ token: String) -> some View {
        VStack {
            Text("Waiting...")
            ProgressView()
            
            Button("Load") {
                Task {
                    await vm.load(token: token)
                }
            }
            
            if let session = session {
                Text("Session key: \(session.key)")
            }
        }.task(id: vm.repeating) {
            await vm.load(token: token)
        }
    }
    
    var buttonView: some View {
        VStack {
            Text("Welcome")
            
            Button("Open login") {
                Task {
                    let token = await authController.openLogin()
                    DispatchQueue.main.async {
                        self.token = token
                    }
                }
            }.padding()
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
    
    func load(token: String) async {
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
