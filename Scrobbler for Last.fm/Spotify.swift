//
//  Spotify.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 07/03/2023.
//

import Foundation
import SpotifyWebAPI
import Combine

final class Spotify: ObservableObject {
    static let shared = Spotify()
    
    private var clientId: String
    
    private var clientSecret: String
    
    @Published var client: SpotifyAPI<ClientCredentialsFlowManager>
    @Published var cancellables: Set<AnyCancellable> = []
    
    init() {
        guard let clientId = Bundle.main.infoDictionary?["SPOTIFY_ID"] as? String else {
            fatalError("No Spotify client id")
        }
        guard let clientSecret = Bundle.main.infoDictionary?["SPOTIFY_SECRET"] as? String else {
            fatalError("No Spotify secret")
        }
        
        self.clientId = clientId
        self.clientSecret = clientSecret
        
        self.client = SpotifyAPI(
            authorizationManager: ClientCredentialsFlowManager(clientId: clientId, clientSecret: clientSecret)
        )
        self.authorize()
    }
    
    func authorize() {
        self.client.authorizationManager.authorize()
            .sink(receiveCompletion: {completion in
                switch completion {
                case .finished:
                    print("Successfully authorized")
                case .failure(let error):
                    print("Could not authorize: \(error)")
                }
            })
            .store(in: &cancellables)
    }
}
