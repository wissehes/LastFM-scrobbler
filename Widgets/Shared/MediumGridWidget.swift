//
//  MediumGridWidget.swift
//  WidgetsExtension
//
//  Created by Wisse Hes on 16/03/2023.
//

import SwiftUI
import WidgetKit

struct MediumGridWidget: View {
    var type: WidgetType
    var entry: WidgetEntry
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.pink.gradient)
            
            VStack(alignment: .center, spacing: 5) {
                Text(entry.usernameText(type))
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.top, 10)
                
                Spacer()
            }
            GeometryReader { geo in
                HStack(alignment: .center, spacing: 5) {
                    ForEach(entry.items.prefix(3), id: \.title) { item in
                        itemView(item)
                    }
                }.padding()
            }
            
            if let error = entry.error {
                Text(error.localizedDescription)
            }
        }
    }
    
    func itemView(_ item: CollageImage) -> some View {
        GeometryReader { geo in
            ZStack {
                item.image
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(
                        width: geo.size.width,
                        height: geo.size.width
                    )
                
                VStack {
                    Spacer()
                    if type == .artists {
                        Text(item.title)
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                            .padding(.leading, 3)
                            .padding(.trailing, 3)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    Text("\(item.scrobbles) plays")
                        .font(.system(.caption, design: .rounded))
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .padding(.leading, 3)
                        .padding(.trailing, 3)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(.bottom, 5)
                }
            }
        }
    }
}

struct MediumGridWidget_Previews: PreviewProvider {
    static var previews: some View {
        MediumGridWidget(
            type: .artists,
            entry: TopArtistsEntry(
                date: .now,
                configuration: ConfigurationIntent(),
                artists: .examples
            )
        )
    }
}
