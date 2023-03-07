//
//  ScrobblingAPI.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 07/03/2023.
//

import Foundation
import SpotifyWebAPI
import Alamofire

final class ScrobblingAPI {
    func scrobbleAlbumTracks(tracks: [SpotifyWebAPI.Track], album: SpotifyWebAPI.Album? = nil) async throws {
        guard case let .authorized(session) = AuthController.shared.state else { return print("No sessionkey") }
        
        var params: Parameters = [
            "method": "track.scrobble",
            "format": "json",
            "api_key": LastfmAPI.API_KEY,
            "sk": session.key
        ]
        
        // Sort by track number
        let sorted = tracks.sorted { $0.trackNumber ?? 0 < $1.trackNumber ?? 1 }
        
        // Iterate over each track and add its properties
        // to the parameters list
        for (index, track) in sorted.enumerated() {
            params["artist[\(index)]"] = track.artists?.first?.name
            params["track[\(index)]"] = track.name
            if let album = album {
                params["album[\(index)]"] = album.name
            } else {
                params["album[\(index)]"] = track.album?.name
            }
            params["timestamp[\(index)]"] = calculateDate(tracks: tracks, index: index)
        }
        
        // Sign the call
        params["api_sig"] = LastfmAPI.auth.hashParams(params: params)
        
        let result = try await AF.request(LastfmAPI.BASE, method: .post, parameters: params)
            .serializingString()
            .value

        print("Finished scrobbling")
        print(result)
    }
    
    private func calculateDate(tracks: [SpotifyWebAPI.Track], index: Int) -> Int {
        let now = Date()
        // Create a new array of tracks to be able to mutate it.
        var arr = Array(tracks)
        
        // Remove first <index> items.
        // So for the first track, this would be zero, meaning it
        // wouldn't remove any items.
        arr.removeFirst(index)
        
        // Comabine all durations
        let durations = arr.map { ($0.durationMS ?? 0) / 1000 }
        let total = durations.reduce(0, { $0 + $1 })
        
        // Subtract the total duration from the current time since 1970
        return Int(now.timeIntervalSince1970) - total
    }
}
