//
//  RecentTracksResponse.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 02/02/2023.
//

import Foundation

// MARK: - LFMRecentTracks
struct LFMRecentTracksResponse: Codable {
    let recentTracks: RecentTracks
    
    enum CodingKeys: String, CodingKey {
        case recentTracks = "recenttracks"
    }
}

// MARK: - Recenttracks
struct RecentTracks: Codable {
    let tracks: [RecentTrack]
    let attr: RecentTracksAttr

    enum CodingKeys: String, CodingKey {
        case tracks = "track"
        case attr = "@attr"
    }
}

// MARK: - Attr
struct RecentTracksAttr: Codable {
    let user, totalPages, page, perPage: String
    let total: String
}

// MARK: - Track
struct RecentTrack: Codable, Track {
    let artistObj: Album
    let streamable: String
    let image: [LFMImage]
    let mbid: String
    let album: Album
    let name: String
    let url: URL
    let date: DateClass?
    let attr: RecentTrackAttr?
    
    var artist: String {
        return self.artistObj.text
    }
    
    var actualDate: Date? {
        guard let date = date else { return nil }
        guard let interval = TimeInterval(date.uts) else { return nil }
        return Date(timeIntervalSince1970: interval)
    }
    
    var id: String {
        if let date = actualDate {
            return mbid + date.formatted() + name + artist
        } else {
            return mbid + name + artist
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case streamable, image, mbid, album, name
        case artistObj = "artist"
        case attr = "@attr"
        case url, date
    }
    
    // MARK: - Album
    struct Album: Codable {
        let mbid, text: String
        
        enum CodingKeys: String, CodingKey {
            case mbid
            case text = "#text"
        }
    }
}
// MARK: - RecentTrackAttr
struct RecentTrackAttr: Codable {
    let nowplaying: String?
}
