//
//  AuthController.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 02/02/2023.
//

import Foundation
import AppKit
import SwiftUI

enum AuthState {
    case loading
    case authorized(LFMSession)
    case notAuthorized
}

final class AuthController: ObservableObject {
    @Published var state: AuthState = .loading
    
    @Published var session: LFMSession?
    
    static let shared = AuthController()
    
    init() {
        self.checkStatus()
    }
    
    func checkStatus() {
        if let session = UserManager.standard.get() {
            self.state = .authorized(session)
        } else {
            self.state = .notAuthorized
        }
    }
    
    func logIn(session: LFMSession) {
        UserManager.standard.save(session)
        withAnimation {
            self.state = .authorized(session)
        }
    }
    
    func logOut() {
        withAnimation {
            self.state = .notAuthorized
        }
    }
    
    func openLogin() async -> String? {
        do {
            let tokenData = try await LastfmAPI.auth.getToken()
            
            var url = URL(string: "http://www.last.fm/api/auth/")!
            url.append(queryItems: [
                URLQueryItem(name: "api_key", value: LastfmAPI.API_KEY),
                URLQueryItem(name: "token", value: tokenData.token)
            ])
            
            NSWorkspace.shared.open(url)
            return tokenData.token
        } catch(let err) {
            print(err)
            return nil
        }
    }
}

final class UserManager {
    private let UDDataKey = "lfmuser"
    
    static let standard = UserManager()
    
    func get() -> LFMSession? {
        guard let data = UserDefaults.standard.data(forKey: UDDataKey) else { return nil }
        guard let decoded = try? JSONDecoder().decode(LFMSession.self, from: data) else { return nil}
        return decoded
    }
    
    func save(_ session: LFMSession) {
        guard let encoded = try? JSONEncoder().encode(session) else { return }
        UserDefaults.standard.set(encoded, forKey: UDDataKey)
    }
}
