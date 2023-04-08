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

struct TopAlbumsEntry: TimelineEntry, WidgetEntry {
    var date: Date
    let configuration: ConfigurationIntent
    var albums: [CollageImage]
    var username: String?
    var error: Error?
    
    var items: [CollageImage] { return self.albums }
    
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
            MediumGridWidget(type: .albums, entry: entry)
        case .systemLarge:
            LargeGridWidget(type: .albums, entry: entry)
        case .systemSmall:
            SmallGridWidget(entry: entry)
        @unknown default:
            MediumGridWidget(type: .albums, entry: entry)
        }
    }
}
//@main
struct TopAlbumsWidget: Widget {
    let kind = "topalbums"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: TopAlbumsProvider()) { entry in
            TopAlbumsWidgetView(entry: entry)
        }
        //.supportedFamilies([.systemMedium, .systemLarge])
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
