//
//  LargeGridWidget.swift
//  WidgetsExtension
//
//  Created by Wisse Hes on 16/03/2023.
//

import SwiftUI
import WidgetKit

struct LargeGridWidget: View {
    var type: WidgetType
    var entry: WidgetEntry
    
    let gridItems: [GridItem] = [
        .init(.flexible(), spacing: 10, alignment: .center),
        .init(.flexible(), spacing: 10, alignment: .center),
        .init(.flexible(), spacing: 10, alignment: .center)
    ]
    
    var background: some View {
        ContainerRelativeShape()
            .fill(.cyan.gradient)
    }
    
    var body: some View {
        ZStack {
            background
            
            VStack(alignment: .center, spacing: 0) {
                Text(entry.usernameText(type))
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.top, 10)
                    .padding(.bottom, 0)
                Text(entry.configuration.Period.period.subtitle)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
                
                GeometryReader { geo in
                    LazyVGrid(columns: gridItems, spacing: 10) {
                        ForEach(Array(entry.items.enumerated()), id: \.element.title) { index, item in
                            itemView(item, index: index, geo: geo)
                        }
                    }
                }.padding([.bottom, .horizontal], 30)
            }
        }
    }
    
    private func itemView(_ item: CollageImage, index: Int, geo: GeometryProxy) -> some View {
        ZStack {
            item.image
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(
                    width: geo.size.width / 3 - 5,
                    height: geo.size.width / 3 - 5
                )
            
            Text("\(index + 1)")
                .font(.system(.caption2, design: .rounded))
                .fontWeight(.bold)
                .lineLimit(1)
                .pillbackground()
                .frame(maxWidth: 150, maxHeight: 150, alignment: .topLeading)
                .padding([.leading, .top], 5)
            
            VStack {
                Spacer()
                
                Text(item.title)
                    .headerStyle()
                    .scaledToFit()
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: geo.size.width)
                
                Text("\(item.scrobbles) plays")
                    .subheaderStyle()
            }.padding(.bottom, 2.5)
        }
    }
}

struct LargeGridWidget_Previews: PreviewProvider {
    static var previews: some View {
        LargeGridWidget(
            type: .artists,
            entry: TopArtistsEntry(
                date: .now,
                configuration: ConfigurationIntent(),
                artists: .examples
            )
        )
    }
}
