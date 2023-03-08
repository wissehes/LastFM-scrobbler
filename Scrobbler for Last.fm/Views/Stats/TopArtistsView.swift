//
//  TopArtistsView.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 01/02/2023.
//

import SwiftUI
import Alamofire

struct TopArtistsView: View {
    @StateObject var vm = TopArtistsViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.data, id: \.id) { item in
                    HStack(alignment: .center) {
                        Rank(rank: item.attr.rank)
                        
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.title)
                            Text(item.scrobbles + " Scrobbles")
                        }
                        
                        Spacer()
                        
                        NavigationLink("Info") {
                            ArtistDetailView(artist: item)
                        }
                        
                        Link(destination: item.url) {
                            Label("View", systemImage: "arrow.up.forward.square")
                        }.padding(.trailing)
                    }
                }
            }.listStyle(.inset(alternatesRowBackgrounds: true))
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
                .task(id: vm.period.rawValue) {
                    await vm.load()
                }.contentTransition(.opacity)
        }
    }
}

final class TopArtistsViewModel: ObservableObject {
    @Published var data: [TopArtist] = []
    @Published var isLoading = true
    @Published var period: Period = .overall

    func load() async {
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        do {
            let data = try await LastfmAPI.getTopArtists(period: period)
            DispatchQueue.main.async {
                
                self.data = data.artists.sorted {
                    ($0.playcountInt ?? 0) > ($1.playcountInt ?? 0)
                }
            }
        } catch AFError.responseValidationFailed(let error) {
            print("AFERROR")
            //            print(error.)
            print(error)
        } catch(let err) {
            print(err)
        }
    }
}

struct TopArtistsView_Previews: PreviewProvider {
    static var previews: some View {
        TopArtistsView()
    }
}
