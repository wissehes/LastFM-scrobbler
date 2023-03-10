//
//  TopTracksView.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 02/02/2023.
//

import SwiftUI
struct TopTracksView: View {
    @StateObject var vm = TopTracksViewModel()
    
    var listview: some View {
        List {
            ForEach(vm.data, id: \.id) { item in
                HStack(alignment: .center) {
                    Rank(rank: item.attr.rank)
                    
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .lineLimit(1)
                        Text(item.artist)
                            .font(.title2)
                        Text(item.scrobbles + " Scrobbles")
                    }
                    
                    Spacer()
                    
                    Link(destination: item.url) {
                        Label("View", systemImage: "arrow.up.forward.square")
                    }.padding(.trailing)
                }
            }
        }.environment(\.defaultMinListRowHeight, 80)
            .listStyle(.inset(alternatesRowBackgrounds: true))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Picker("Period", selection: $vm.period) {
                        ForEach(Period.allCases, id: \.rawValue) { period in
                            Text(period.name)
                                .tag(period)
                        }
                    }
                }
            }
    }
    
    var body: some View {
        listview
            .loading(vm.isLoading)
            .task(id: vm.period.rawValue) {
                await vm.load()
            }
    }
}

final class TopTracksViewModel: ObservableObject {
    @Published var data: [TopTrack] = []
    @Published var isLoading = true
    @Published var period: Period = .overall
    
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
            let data = try await LastfmAPI.getTopTracks(period: period)
            DispatchQueue.main.async {
                self.data = data.tracks.sorted {
                    ($0.playcountInt ?? 0) > ($1.playcountInt ?? 0)
                }
            }
        } catch(let err) {
            print(err)
        }
    }
}


struct TopTracksView_Previews: PreviewProvider {
    static var previews: some View {
        TopTracksView()
    }
}
