//
//  SmallGridWidget.swift
//  WidgetsExtension
//
//  Created by Wisse Hes on 17/03/2023.
//

import SwiftUI

struct SmallGridWidget: View {
//    var type: WidgetType
    var entry: WidgetEntry
    
    let gridItems = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    var body: some View {
        GeometryReader { geo in
            LazyVGrid(columns: gridItems, spacing: 0) {
                ForEach(entry.items, id: \.title, content: itemView(_:))
            }.frame(width: geo.size.width, height: geo.size.height)
        }
    }
    
    func itemView(_ item: CollageImage) -> some View {
        item.image
            .resizable()
            .scaledToFit()
    }
}

struct SmallGridWidget_Previews: PreviewProvider {
    static var previews: some View {
        SmallGridWidget(
            entry: TopArtistsEntry(
                date: .now,
                configuration: ConfigurationIntent(),
                artists: .examples
            )
        )
    }
}
