//
//  CollageImage.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 11/03/2023.
//

import Foundation
import SwiftUI

struct CollageImage {
    let title: String
    let scrobbles: Int
    var image: Image = Image(systemName: "opticaldisc.fill")
    
    init(albumName: String, scrobbles: Int, image: Image? = nil) {
        self.title = albumName
        self.scrobbles = scrobbles
        if let image = image {
            self.image = image
        }
    }
    
    init(_ from: Album) {
        self.title = from.name
        self.scrobbles = from.playcountInt ?? 0
    }
    
    init(_ from: TopArtist) {
        self.title = from.name
        self.scrobbles = from.playcountInt ?? 0
    }
}

extension Array where Element == CollageImage {
    static var examples: [CollageImage] {
        var array: [CollageImage] = []
        
        for i in 1...9 {
            array.append(.init(albumName: "Album \(i)", scrobbles: 1000 - i * 100))
        }
        return array
    }
}
