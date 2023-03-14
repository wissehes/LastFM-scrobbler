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
    var error: Error?
    
    init(date: Date, configuration: ConfigurationIntent, albums: [CollageImage], error: Error? = nil) {
        self.date = date
        self.configuration = configuration
        self.albums = albums
        self.error = error
    }
    
    init(configuration: ConfigurationIntent) {
        self.date = .now
        self.configuration = configuration
        self.albums = []
        self.error = nil
    }
}

struct TopAlbumsProvider: IntentTimelineProvider {
    typealias Entry = TopAlbumsEntry
//    typealias Intent = ConfigurationIntent
    
    
    func getEntry(configuration: ConfigurationIntent) async throws -> Entry {
        let data = try await LastfmAPI.getTopAlbums(period: configuration.Period.period)
        
        var entry = TopAlbumsEntry(date: .now, configuration: configuration, albums: [])
        
        let mapped: [CollageImage] = try await data.albums.asyncMap { album in
            var collageImage = CollageImage(album)
            
            guard let url = album.image.first?.text else { return collageImage }
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
//        Task {
//            do {
//                let entry = try await getEntry(configuration: configuration)
//                completion(entry)
//            } catch {
//                var entry = TopAlbumsEntry(configuration: configuration)
//                entry.error = error
//                completion(entry)
//            }
//        }
        let entry = Entry(date: .now, configuration: ConfigurationIntent(), albums: .examples)
        completion(entry)
    }
    
    // Called when
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let afterDate = Calendar.current.date(byAdding: .hour, value: 12, to: .now)!
        let reloadPolicy: TimelineReloadPolicy = .after(afterDate)
        print("Getting timeline...")
        print("lastfm: ", Bundle.main.infoDictionary)
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
    
    var body: some View {
        ZStack {
            Color.cyan
            
            VStack {
                HStack {
                    ForEach(entry.albums, id: \.title) { item in
                        Text(item.title)
                    }
                }
                Text(entry.error?.localizedDescription ?? "")
            }
        }
    }
}
//@main
struct TopAlbumsWidget: Widget {
    let kind = "topalbums"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: TopAlbumsProvider()) { entry in
            TopAlbumsWidgetView(entry: entry)
        }//.supportedFamilies([.systemMedium])
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

extension LFMPeriod {
    var period: Period {
        switch self {
        case .unknown:
            return .overall
        case .week:
            return .week
        case .month:
            return .month
        case .quarter:
            return .quarter
        case .halfyear:
            return .halfyear
        case .year:
            return .year
        case .overall:
            return .overall
        }
    }
}
