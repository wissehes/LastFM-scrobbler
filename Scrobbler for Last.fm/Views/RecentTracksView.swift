//
//  RecentTracksView.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 02/02/2023.
//

import SwiftUI

struct RecentTracksView: View {
    
    @StateObject var vm = RecentTracksViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.data, id: \.id) { item in
                    itemView(item: item)
                }
            }.listStyle(.inset(alternatesRowBackgrounds: true))
                .environment(\.defaultMinListRowHeight, 75)
                .loading(vm.isLoading)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            Task {
                                await vm.load()
                            }
                        } label: {
                            Label("Reload", systemImage: "arrow.clockwise.circle")
                                .disabled(vm.isLoading)
                        }
                    }
                }
                .task {
                    await vm.load()
                }
                .navigationTitle("Recent Tracks")
            
        }
    }
    
    func itemView(item: RecentTrack) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .lineLimit(2)
                Text(item.artist)
                    .font(.title2)
                    .lineLimit(1)
            }.padding(.leading)
            
            Spacer()
            
            HStack {
                if item.attr?.nowplaying != nil {
                    NowPlayingIcon()
//                        .padding(10)
                }
                
                if let relative = item.relativeTime {
                    Text("Played \(relative)")
                        .font(.subheadline)
                }
            }
            
            Link(destination: item.url) {
                Label("View", systemImage: "arrow.up.forward.square")
            }.padding(.trailing)
        }.frame(height: 65)
    }
}

final class RecentTracksViewModel: ObservableObject {
    @Published var data: [RecentTrack] = []
    @Published var isLoading = true
    
    func load() async {
        DispatchQueue.main.async {
            withAnimation {
                self.isLoading = true
            }
        }
        defer {
            DispatchQueue.main.async {
                withAnimation {
                    self.isLoading = false
                }
            }
        }
        
        do {
            let data = try await LastfmAPI.getRecentTracks()
            DispatchQueue.main.async {
                self.data = data.tracks
            }
        } catch(let err) {
            print(err)
        }
    }
}

struct RecentTracksView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RecentTracksView()
        }
    }
}

extension RecentTrack {
    var relativeTime: String? {
        guard let date = self.actualDate else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: .now)
    }
}
