//
//  Shared.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 01/02/2023.
//

import Foundation

// MARK: - Image
struct LFMImage: Codable {
    let size: Size
    let text: URL?

    enum CodingKeys: String, CodingKey {
        case size
        case text = "#text"
    }
    
    enum Size: String, Codable {
        case empty = ""
        case extralarge = "extralarge"
        case large = "large"
        case medium = "medium"
        case mega = "mega"
        case small = "small"
    }
}

// MARK: - SimpleArtist
struct SimpleArtist: Codable, Artist {
    let url: String
    let name, mbid: String
}

// MARK: - DateClass
struct DateClass: Codable {
    let uts, text: String

    enum CodingKeys: String, CodingKey {
        case uts
        case text = "#text"
    }
}

protocol Track {
    var artist: String { get }
    var name: String { get }
}

protocol Artist {
    var name: String { get }
}
