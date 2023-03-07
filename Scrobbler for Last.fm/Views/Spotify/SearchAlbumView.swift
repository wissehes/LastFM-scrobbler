//
//  SearchAlbumView.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 07/03/2023.
//

import SwiftUI
import SpotifyWebAPI

struct SearchAlbumView: View {
    @StateObject var vm = SearchAlbumViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.results, id: \.id) { item in
//                    NavigationLink(value: item.uri) {
//                        rowItem(item)
//                    }
                    NavigationLink {
                        SpotifyAlbumView(albumURI: item.uri ?? "")
                    } label: {
                        rowItem(item)
                    }

                }
            }.listStyle(.bordered(alternatesRowBackgrounds: true))
                .searchable(text: $vm.searchQuery)
                .onSubmit(of: .search) {
                    vm.search()
                }.onAppear {
                    vm.search()
            }
        }
    }
    
    func rowItem(_ album: SpotifyWebAPI.Album) -> some View {
        HStack(alignment: .center) {
            ExternalImage(url:album.images?.first?.url)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .frame(width: 75, height: 75)
                .padding(5)
            
            VStack(alignment: .leading) {
                Text(album.name)
                    .font(.system(.title, design: .rounded, weight: .bold))
                Text(album.artists?.map { $0.name }.joined(separator: ", ") ?? "*N/A*")
            }
            Spacer()
            
            if let date = album.releaseDate {
                yearPill(date: date)
            }
        }
    }
    
    @ViewBuilder
    func yearPill(date: Date) -> some View {
        Text(vm.getYearFromDate(date))
            .font(.system(.headline, design: .rounded, weight: .bold))
            .foregroundColor(.white)
            .lineLimit(1)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.blue)
            .clipShape(Capsule())
            .shadow(radius: 5)
            .padding(.trailing)
    }
    
}

final class SearchAlbumViewModel: ObservableObject {
    @Published var searchQuery = "Taylor Swift"
    @Published var results: [SpotifyWebAPI.Album] = []
    
    var formatter: DateFormatter
    init() {
        self.formatter = .init()
        self.formatter.dateFormat = "yyyy"
    }
    
    func search() {
        Spotify.shared.client.search(query: searchQuery, categories: [.album])
            .sink { completion in
                print(completion)
            } receiveValue: { results in
                if let albums = results.albums?.items {
                    DispatchQueue.main.async {
                        self.results = albums
                    }
                }
            }.store(in: &Spotify.shared.cancellables)
        
    }
    
    func getYearFromDate(_ date: Date) -> String {
        return formatter.string(from: date)
    }
}

struct SearchAlbumView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchAlbumView()
        }
    }
}
