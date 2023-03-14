//
//  LastfmAPI.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 01/02/2023.
//

import Foundation
import Alamofire
import CryptoKit
import Cocoa
import SwiftUI

final class LastfmAPI {
    static var API_KEY: String {
        guard let key = Bundle.main.infoDictionary?["LASTFM_KEY"] as? String else {
//            fatalError("No Last.fm token")
            return ""
        }
        return key
    }
    static var API_SECRET: String {
        guard let key = Bundle.main.infoDictionary?["LASTFM_SECRET"] as? String else {
//            fatalError("No Last.fm secret")
            return ""
        }
        return key
    }
    
    static let username = "wissehes"
    static let BASE = "https://ws.audioscrobbler.com/2.0/"
    
    static let auth = AuthAPI()
    static let scrobble = ScrobblingAPI()
    
    static func getParams(user: String? = nil, method: Method, period: Period? = nil) -> Parameters {
        
        var params: Parameters = [
            "method": method.rawValue,
//            "user": user,
            //            "period": period.rawValue,
            "format": "json",
            "api_key": API_KEY
        ]
        
        
        if case let .authorized(session) = AuthController.shared.state {
            params["user"] = session.name
        } else if let user = user {
            params["user"] = user
        }
        
        if let period = period {
            params["period"] = period.rawValue
        }
        
        return params
    }
    
    static func unLoveTrack(track: some Track) async throws {
        if case let .authorized(session) = AuthController.shared.state {
            var params = getParams(user: session.name, method: .unLoveTrack)
            params["sk"] = session.key
            params["track"] = track.name
            params["artist"] = track.artist
            params["api_sig"] = self.auth.hashParams(params: params)
            
            let _ = try await AF.request(BASE, method: .post, parameters: params)
                .validate()
                .serializingString()
                .value
        }
    }
    
    static func loveTrack(track: some Track) async throws {
        guard case let .authorized(session) = AuthController.shared.state else { return }
        
        var params = getParams(user: session.name, method: .unLoveTrack)
        params["sk"] = session.key
        params["track"] = track.name
        params["artist"] = track.artist
        params["api_sig"] = self.auth.hashParams(params: params)
        
        let _ = try await AF.request(BASE, method: .post, parameters: params)
            .validate()
            .serializingString()
            .value
    }
    
    static func getLovedTracks() async throws -> LovedTracks {
        var params = getParams(user: username, method: .getLovedTracks)
        params["limit"] = 300
        
        let result = try await AF.request(BASE, parameters: params)
            .serializingDecodable(LFMLovedTracksResponse.self)
            .value
        return result.lovedtracks
    }
    
    static func getRecentTracks() async throws -> RecentTracks {
        let params = getParams(user: username, method: .recentTracks)
        
        let result = try await AF.request(BASE, parameters: params)
            .serializingDecodable(LFMRecentTracksResponse.self)
            .value
        return result.recentTracks
    }
    
    static func getTopTracks(period: Period = .overall) async throws -> TopTracks {
        let params = self.getParams(user: username, method: .topTracks, period: period)
        
        let result = try await AF.request(BASE, parameters: params)
            .serializingDecodable(LFMTopTracksResponse.self)
            .value
        
        return result.toptracks
    }
    
    static func getTopAlbums(period: Period = .overall) async throws -> TopAlbums {
        let params = self.getParams(user: username, method: .topAlbums, period: period)
        
        let result = try await AF.request(BASE, parameters: params)
            .serializingDecodable(LFMTopAlbumsResponse.self)
            .value
        
        return result.topalbums
    }
    
    static func getTopArtists(period: Period = .overall) async throws -> TopArtists {
        let params: Parameters = [
            "method": "user.getTopArtists",
            "format": "json",
            "user": username,
            "period": period.rawValue,
            "api_key": API_KEY
        ]
        
        let request = AF.request(BASE, parameters: params)
        
        let result = try await request
            .serializingDecodable(LFMTopArtistsResponse.self)
            .value
        
        return result.topartists
    }
    
    static func getArtistDetail(artist: some Artist) async throws -> ArtistInfo {
        var params = getParams(method: .getArtistInfo)
        params["artist"] = artist.name
        
        let result = try await AF.request(BASE, parameters: params)
            .serializingDecodable(LFMArtistInfoResponse.self)
            .value
        
        return result.artist
    }
    
    static func loadImage(_ url: URL) async throws -> Image? {
        let data = try await AF.request(url)
            .serializingData()
            .value
        
        guard let image = NSImage(data: data) else { return nil }
        
        return Image(nsImage: image)
    }
}

class AuthAPI {
    func getToken() async throws -> GetTokenResponse {
        let params: Parameters = [
            "api_key": LastfmAPI.API_KEY,
            "method": Method.getToken.rawValue,
            "format": "json"
        ]
        
        
        let result = try await AF.request(LastfmAPI.BASE, parameters: params)
            .serializingDecodable(GetTokenResponse.self)
            .value
        
        return result
    }
    
    func getSession(token: String) async throws -> LFMSession {
        var params: Parameters = [
            "api_key": LastfmAPI.API_KEY,
            "method": Method.getSession.rawValue,
            "token": token,
        ]
        params["api_sig"] = hashParams(params: params)
        params["format"] = "json"
        
        let request = AF.request(LastfmAPI.BASE, parameters: params)
        //        print(try await request.serializingString().value)
        
        let result = try await request
            .serializingDecodable(GetSessionResponse.self)
            .value
        
        return result.session
        
    }
    
    func hashParams(params: Parameters) -> String {
        var string = ""
        
        // Sort parameters alphabetically as per Last.fm docs
        for param in params.sorted(by: { $0.key < $1.key }) {
            // Ignore "format" key
            if param.key == "format" {
                continue;
            }
            // Append the params as <key><value>
            string.append(param.key + String(describing: param.value))
        }
        
        // Append the secret
        string.append(LastfmAPI.API_SECRET)
        //        print("String before hashing: \(string)")
        
        // Create a digest
        let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())
        // Turn it into a string
        let hashedString = digest.map {
            String(format: "%02hhx", $0)
        }.joined()
        return hashedString
    }
}

enum Period: String, CaseIterable {
    case week = "7day"
    case month = "1month"
    case quarter = "3month"
    case halfyear = "6month"
    case year = "12month"
    case overall = "overall"
}

extension Period {
    var name: String {
        switch self {
        case .week:
            return "Last 7 days"
        case .month:
            return "Last 30 days"
        case .quarter:
            return "Last 90 days"
        case .halfyear:
            return "Last 180 days"
        case .year:
            return "Last 365 days"
        case .overall:
            return "All time"
        }
    }
}

enum Method: String {
    case topArtists = "user.getTopArtists"
    case topAlbums = "user.getTopAlbums"
    case topTracks = "user.getTopTracks"
    
    case recentTracks = "user.getRecentTracks"
    case getLovedTracks = "user.getLovedTracks"
    
    case unLoveTrack = "track.unlove"
    case loveTrack = "track.love"
    
    case getToken = "auth.getToken"
    case getSession = "auth.getSession"
    
    case getArtistInfo = "artist.getInfo"
}
