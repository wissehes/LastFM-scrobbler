//
//  CollageView.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 11/03/2023.
//

import SwiftUI

struct CollageView: View {
//    var topAlbums: [Album]
    var items: [CollageImage]
    var size: Double = 150
    
    init(items: [CollageImage], size: Double = 150) {
        self.items = items
        self.size = size
    }
    init(items: [Album]) {
        self.items = items.map { CollageImage($0) }
    }
    
    let gridItems = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    var body: some View {
        grid
    }
    
    var grid: some View {
        LazyVGrid(columns: gridItems, spacing: 0) {
            ForEach(items, id: \.albumName, content: imageItem(_:))
        }.frame(width: size * 3, height: size * 3)
    }
    
    func imageItem(_ item: CollageImage) -> some View {
        ZStack {
            item.image
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(item.albumName)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
//                    .font(.system(size: 10))
                    .font(.system(size: size * 0.065, weight: .bold, design: .rounded))
                    .lineLimit(2)
//                    .padding(2.5)
                    .padding(size * 0.0125)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
//                    .padding(.horizontal, 2.5)
                    .padding(.horizontal, size * 0.0125)
                    
                
                Text(item.scrobbles.formatted() + " Plays")
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
//                    .font(.system(size: 8))
                    .font(.system(size: size * 0.045, weight: .medium, design: .monospaced))
                    .lineLimit(2)
//                    .padding(2.5)
                    .padding(size * 0.0125)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
//                    .padding(.bottom, 2.5)
                    .padding(.bottom, size * 0.0125)
//                    .padding(.horizontal, 2.5)
                    .padding(.horizontal, size * 0.0125)
            }.frame(height: size, alignment: .bottom)
                .frame(width: size, alignment: .leading)
        }.frame(width: size, height: size)
    }
}

struct CollageView_Previews: PreviewProvider {
    static var data: [Album] = {
        let path = Bundle.main.path(forResource: "topalbums", ofType: "json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        let decoded = try? JSONDecoder().decode([Album].self, from: data!)
        return decoded!
    }()
    
    static var previews: some View {
        CollageView(items: data)
//        CreateCollageView()
    }
}
