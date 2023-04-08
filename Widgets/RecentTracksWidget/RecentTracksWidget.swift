//
//  RecentTracksWidget.swift
//  WidgetsExtension
//
//  Created by Wisse Hes on 20/03/2023.
//

import Foundation
import SwiftUI
import WidgetKit

struct RecentTracksEntry: TimelineEntry {
    var date: Date
    var tracks: [RecentTrack]
    var username: String?
    var error: Error?
}

struct RecentTracksProvider: TimelineProvider {
    typealias Entry = RecentTracksEntry
    
    private func getEntry() async throws -> Entry {
        let data = try await LastfmAPI.getRecentTracks()
        
        var entry = Entry(date: .now, tracks: [])
        entry.tracks = Array(data.tracks.prefix(5))
        entry.username = data.attr.user
        
        return entry
    }

    func placeholder(in context: Context) -> Entry {
        Entry(date: .now, tracks: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let entry = Entry(date: .now, tracks: [])
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let afterDate = Calendar.current.date(byAdding: .hour, value: 2, to: .now)!
        let reloadPolicy: TimelineReloadPolicy = .after(afterDate)
        
        Task {
            do {
                let entry = try await self.getEntry()
                let timeline = Timeline(entries: [entry], policy: reloadPolicy)
                completion(timeline)
            } catch {
                var entry = Entry(date: .now, tracks: [])
                entry.error = error
                let timeline = Timeline(entries: [entry], policy: reloadPolicy)
                completion(timeline)
            }
        }
    }
}

struct RecentTracksWidgetView: View {
    var entry: RecentTracksProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var background: some View {
        ContainerRelativeShape()
            .fill(.cyan.gradient)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(Array(entry.tracks.enumerated()), id: \.element.id) { track in
                HStack(alignment: .center, spacing: 20) {
                    Text("\(track.offset + 1)")
                    VStack(alignment: .leading) {
                        Text(track.element.name)
                            .lineLimit(1)
                        Text(track.element.artist)
                            .font(.subheadline)
                    }.multilineTextAlignment(.leading)
                }.padding([.leading, .trailing])
                Divider()
            }
        }
    }
}

struct RecentTracksWidget: Widget {
    let kind = "recenttracks"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: RecentTracksProvider()
        ) { entry in
            RecentTracksWidgetView(entry: entry)
        }.supportedFamilies([.systemMedium, .systemLarge])
            .configurationDisplayName("Recent Tracks")
            .description("Shows your recent tracks")
    }
}
