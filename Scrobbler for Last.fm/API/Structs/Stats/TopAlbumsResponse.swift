//
//  TopAlbumsResponse.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 01/02/2023.
//

import Foundation

// MARK: - LFMTopAlbums
struct LFMTopAlbumsResponse: Codable {
    let topalbums: TopAlbums
}

// MARK: - TopAlbums
struct TopAlbums: Codable {
    let albums: [Album]
    let attr: TopalbumsAttr

    enum CodingKeys: String, CodingKey {
        case albums = "album"
        case attr = "@attr"
    }
}

// MARK: - Album
struct Album: Codable {
    let artist: AlbumArtist
    let image: [LFMImage]
    let mbid: String
    let url: URL
    let playcount: String
    let attr: AlbumAttr
    let name: String
    
    var id: String {
        return mbid + playcount + name
    }
    
    var playcountInt: Int? {
        Int(playcount)
    }
    
    var scrobbles: String {
        if let int = playcountInt {
            return int.formatted(.number)
        } else {
            return playcount
        }
    }

    enum CodingKeys: String, CodingKey {
        case artist, image, mbid, url, playcount
        case attr = "@attr"
        case name
    }
    
    // MARK: - Artist
    struct AlbumArtist: Codable, Artist {
        let url: String
        let name, mbid: String
    }
}

// MARK: - AlbumAttr
struct AlbumAttr: Codable {
    let rank: String
}

// MARK: - TopalbumsAttr
struct TopalbumsAttr: Codable {
    let user, totalPages, page, perPage: String
    let total: String
}
