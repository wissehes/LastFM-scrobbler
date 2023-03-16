//
//  TopArtistsWidget.swift
//  WidgetsExtension
//
//  Created by Wisse Hes on 16/03/2023.
//

import Foundation
import WidgetKit
import SwiftUI
import Intents

struct TopArtistsEntry: TimelineEntry {
    var date: Date
    let configuration: ConfigurationIntent
    var artists: [CollageImage]
    var username: String?
    var error: Error?
    
    init(date: Date, configuration: ConfigurationIntent, artists: [CollageImage], username: String? = nil, error: Error? = nil) {
        self.date = date
        self.configuration = configuration
        self.artists = artists
        self.username = username
        self.error = error
    }
    init(configuration: ConfigurationIntent) {
        self.date = .now
        self.configuration = configuration
        self.artists = []
        self.username = nil
        self.error = nil
    }
}

struct TopArtistsProvider: IntentTimelineProvider {
    typealias Entry = TopArtistsEntry
    typealias Intent = ConfigurationIntent
    
    private func getEntry(configuration: ConfigurationIntent) async throws -> Entry {
        let data = try await LastfmAPI.getTopArtists(period: configuration.Period.period)
        
        var entry = Entry(date: .now, configuration: configuration, artists: [], username: data.attr.user)
        let firstNine = Array(data.artists.prefix(9))
        
        let mapped: [CollageImage] = await firstNine.asyncMap { artist in
            var collageImage = CollageImage(artist)
            
            let artistData = try? await LastfmAPI.getArtistDetail(artist: artist)
            guard let artistData = artistData else {
                collageImage.image = Image(systemName: "music.mic.circle.fill")
                return collageImage
            }

            guard let url = artistData.image.last?.text else { return collageImage }
            let image = try? await LastfmAPI.loadImage(url)
            if let image = image {
                collageImage.image = image
            } else {
                collageImage.image = Image(systemName: "music.mic")
            }
            // Wait 250 ms to try and avoid getting rate-limited by last.fm
            try? await Task.sleep(for: .milliseconds(250))
            return collageImage
        }
        entry.artists = mapped
        return entry
    }
    
    func placeholder(in context: Context) -> TopArtistsEntry {
        Entry(date: .now, configuration: ConfigurationIntent(), artists: .examples)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (TopArtistsEntry) -> Void) {
        let entry = Entry(date: .now, configuration: ConfigurationIntent(), artists: .examples)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<TopArtistsEntry>) -> Void) {
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
                var entry = Entry(configuration: configuration)
                entry.error = error
                let timeline = Timeline(entries: [entry], policy: reloadPolicy)
                print("Timeline error: ", error)
                completion(timeline)
            }
        }
    }
}

struct TopArtistsWidgetView: View {
    var entry: TopArtistsProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var background: some View {
        ContainerRelativeShape()
            .fill(.cyan.gradient)
    }
    
    var body: some View {
        switch family {
        case .systemSmall:
            TopArtistsSmallWidgetView(entry: entry)
        case .systemMedium:
            TopArtistsMediumWidgetView(entry: entry)
        default:
            Text("hi")
        }
    }
}

struct TopArtistsWidget: Widget {
    let kind = "topartists"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: TopArtistsProvider()
        ) { entry in
            TopArtistsWidgetView(entry: entry)
        }.supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
            .configurationDisplayName("Top Artists")
            .description("Shows your most listened artists.")
    }
}
