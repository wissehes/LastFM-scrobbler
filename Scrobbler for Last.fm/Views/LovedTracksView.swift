//
//  LovedTracksView.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 02/02/2023.
//

import SwiftUI

struct LovedTracksView: View {
    
    @StateObject var vm = LovedTracksViewModel()
    
    var body: some View {
        List {
            ForEach(Array(zip(vm.data.indices, vm.data)), id: \.1.id) { index, item in
                itemView(index: index, item: item)
            }
        }.listStyle(.inset(alternatesRowBackgrounds: true))
            .task {
                await vm.load()
            }.navigationTitle("Loved Tracks")
    }
    
    func itemView(index: Int, item: LovedTrack) -> some View {
        HStack(alignment: .center) {
            Rank(rank: (index + 1).description)
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .lineLimit(2)
                Text(item.artist)
                    .font(.title2)
                    .lineLimit(2)
            }
            
            Spacer()
            
            HStack {
                
                if let date = item.actualDate {
                    Text("Added on \(date, style: .date)")
                        .font(.subheadline)
                }
            }
            
            Button {
                Task {
                    await vm.unlove(track: item)
                }
            } label: {
                Label("Unlove", systemImage: "heart.slash.fill")
            }
            
            Link(destination: item.url) {
                Label("View", systemImage: "arrow.up.forward.square")
            }
            .padding(.trailing)
                
        }

    }
}

final class LovedTracksViewModel: ObservableObject {
    @Published var data: [LovedTrack] = []
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
            let data = try await LastfmAPI.getLovedTracks()
            DispatchQueue.main.async {
                self.data = data.tracks
            }
        } catch(let err) {
            print(err)
        }
    }
    
    func unlove(track: LovedTrack) async {
        do {
            try await LastfmAPI.unLoveTrack(track: track)
            DispatchQueue.main.async {
                withAnimation {
                    self.data = self.data.filter {
                        $0.name != track.name && $0.artist != track.artist
                    }
                }
            }
        } catch(let err) {
            print(err)
        }
    }
}

struct LovedTracksView_Previews: PreviewProvider {
    static var previews: some View {
        LovedTracksView()
    }
}
