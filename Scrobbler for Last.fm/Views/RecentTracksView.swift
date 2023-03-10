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
                ForEach(Array(zip(vm.data.indices, vm.data)), id: \.1.id) { index, item in
                    itemView(index: index, item: item)
                }
            }.listStyle(.inset(alternatesRowBackgrounds: true))
                .environment(\.defaultMinListRowHeight, 65)
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
    
    func itemView(index: Int, item: RecentTrack) -> some View {
        HStack(alignment: .center) {
            Rank(rank: (index + 1).description)

            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .lineLimit(2)
                Text(item.artist)
                    .font(.title2)
                    .lineLimit(1)
            }
            
            Spacer()
            
            HStack {
                
                if item.attr?.nowplaying != nil {
                    Text("Now playing...")
                        .font(.subheadline)
                        .italic()
                }
                
                if let date = item.actualDate {
                    Text("Played \(date, style: .relative) Ago")
                        .font(.subheadline)
                }
            }
            
            Link(destination: item.url) {
                Label("View", systemImage: "arrow.up.forward.square")
            }.padding(.trailing)
        }
    }
}

final class RecentTracksViewModel: ObservableObject {
    @Published var data: [RecentTrack] = []
    @Published var isLoading = true

    func load() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
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
