//
//  TopAlbumsWidget.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 13/03/2023.
//

import Foundation
import WidgetKit
import SwiftUI
import Intents

struct TopAlbumsEntry: TimelineEntry {
    var date: Date
    let configuration: ConfigurationIntent
    var albums: [CollageImage]
    var username: String?
    var error: Error?
    
    init(date: Date, configuration: ConfigurationIntent, albums: [CollageImage], username: String? = nil, error: Error? = nil) {
        self.date = date
        self.configuration = configuration
        self.albums = albums
        self.username = username
        self.error = error
    }

    init(configuration: ConfigurationIntent) {
        self.date = .now
        self.configuration = configuration
        self.albums = []
        self.username = nil
        self.error = nil
    }
}

struct TopAlbumsProvider: IntentTimelineProvider {
    typealias Entry = TopAlbumsEntry
    //    typealias Intent = ConfigurationIntent
    
    func getEntry(configuration: ConfigurationIntent, family: WidgetFamily = .systemMedium) async throws -> Entry {
        let data = try await LastfmAPI.getTopAlbums(period: configuration.Period.period)
        
        var entry = TopAlbumsEntry(date: .now, configuration: configuration, albums: [], username: data.attr.user)
        let firstThree = Array(data.albums.prefix(9))
        let mapped: [CollageImage] = try await firstThree.asyncMap { album in
            var collageImage = CollageImage(album)
            
            guard let url = album.image.last?.text else { return collageImage }
            let image = try await LastfmAPI.loadImage(url)
            if let image = image {
                collageImage.image = image
            }
            return collageImage
        }
        entry.albums = mapped
        
        return entry
    }
    
    
    // Called when getting the placeholder when choosing widgets
    func placeholder(in context: Context) -> Entry {
        Entry(date: .now, configuration: ConfigurationIntent(), albums: .examples)
    }
    
    // Called when
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> Void) {
        let entry = Entry(date: .now, configuration: ConfigurationIntent(), albums: .examples)
        completion(entry)
    }
    
    // Called when
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let afterDate = Calendar.current.date(byAdding: .hour, value: 12, to: .now)!
        let reloadPolicy: TimelineReloadPolicy = .after(afterDate)
        
        Task {
            do {
                let entry = try await getEntry(configuration: configuration)
                // Create a date which is 12 hours in the future
                let timeline = Timeline(entries: [entry], policy: reloadPolicy)
                print("Timeline success!")
                completion(timeline)
            } catch {
                var entry = TopAlbumsEntry(configuration: configuration)
                entry.error = error
                let timeline = Timeline(entries: [entry], policy: reloadPolicy)
                print("Timeline error: ", error)
                completion(timeline)
            }
        }
    }
}

struct TopAlbumsWidgetView: View {
    var entry: TopAlbumsProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var background: some View {
        ContainerRelativeShape()
            .fill(.cyan.gradient)
    }
    
    var body: some View {
        switch family {
        case .systemMedium:
            medium
        case .systemLarge:
            large
        @unknown default:
            medium
        }
    }
    
    var medium: some View {
        ZStack {
            //            LinearGradient(colors: [colors], startPoint: .bottomLeading, endPoint: .topTrailing)
            ContainerRelativeShape()
                .fill(.cyan.gradient)
            
            VStack(alignment: .center, spacing: 5) {
                usernameText(text: entry.username)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.top, 10)
                
                Spacer()
            }
            GeometryReader { geo in
                HStack(alignment: .center, spacing: 5) {
                    ForEach(entry.albums.prefix(3), id: \.title) { item in
                        newItemView(item)
                    }
                }.padding()
            }
        }
    }
    
    let gridItems: [GridItem] = [
        .init(.flexible(), spacing: 10, alignment: .center),
        .init(.flexible(), spacing: 10, alignment: .center),
        .init(.flexible(), spacing: 10, alignment: .center)
    ]
    
    var large: some View {
        ZStack {
            background
            
            VStack(alignment: .center, spacing: 0) {
                usernameText(text: entry.username)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                    .padding(.bottom, 0)
                Text(entry.configuration.Period.period.subtitle)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 5)
                
                GeometryReader { geo in
                    LazyVGrid(columns: gridItems, spacing: 10) {
                        ForEach(Array(entry.albums.enumerated()), id: \.element.title) { index, item in
                            largeItemView(item, index: index, geo: geo)
                        }
                    }
                }.padding([.bottom, .horizontal], 30)
            }
        }
    }
    
    func largeItemView(_ item: CollageImage, index: Int, geo: GeometryProxy) -> some View {
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
                .multilineTextAlignment(.center)
                .padding(.leading, 4)
                .padding(.trailing, 4)
                .background(.thinMaterial)
                .clipShape(Circle())
                .frame(maxWidth: 150, maxHeight: 150, alignment: .topLeading)
                .padding([.leading, .top], 5)
            
            VStack {
                Spacer()
                
                Text("\(item.scrobbles) plays")
                    .font(.system(.caption2, design: .rounded))
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .padding(.leading, 3)
                    .padding(.trailing, 3)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }.padding(.bottom, 2.5)
        }
    }
    
    func newItemView(_ item: CollageImage) -> some View {
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
                    
                    Text("\(item.scrobbles) plays")
                        .font(.system(.caption2, design: .rounded))
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .padding(.leading, 3)
                        .padding(.trailing, 3)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(.bottom, 10)
                }
            }
        }
    }
    
    @ViewBuilder
    func usernameText(text: String?) -> some View {
        if let text = text {
            Text("\(text)'s most listened albums")
        } else {
            Text("Your most listened albums")
        }
    }
}
//@main
struct TopAlbumsWidget: Widget {
    let kind = "topalbums"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: TopAlbumsProvider()) { entry in
            TopAlbumsWidgetView(entry: entry)
        }.supportedFamilies([.systemMedium, .systemLarge])
        .configurationDisplayName("Top Albums")
        .description("Shows your most listened albums.")
    }
}

struct TopAlbumsWidget_Previews: PreviewProvider {
    static var previews: some View {
        TopAlbumsWidgetView(
            entry: .init(date: .now, configuration: ConfigurationIntent(), albums: .examples)
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
