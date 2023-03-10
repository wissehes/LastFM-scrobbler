//
//  ArtistDetailView.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 03/02/2023.
//

import SwiftUI

struct ArtistDetailView: View {
    
    @StateObject var vm = ArtistDetailViewModel()
    var artist: Artist
    
    init(artist: some Artist) {
        self.artist = artist
    }
    
    var body: some View {
        Group {
            if vm.isLoading {
                ProgressView()
                    .padding()
            } else if let artistData = vm.data {
                artistView(artist: artistData)
            } else {
                EmptyView()
            }
        }.navigationTitle(artist.name)
            .task {
                await vm.load(artist)
            }
            .transition(.opacity)
    }
    
    func artistView(artist: ArtistInfo) -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    ExternalImage(url: artist.image.last?.text)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: 250, height: 250)
                        .padding(5)
                        .shadow(radius: 10)
                    
                    VStack(alignment: .leading) {
                        Text(artist.name)
                            .font(.system(.title, design: .rounded, weight: .bold))
                        
                        if let listeners = artist.stats.listenersInt {
                            Text("**\(listeners.formatted())** Listeners")
                                .font(.callout)
                        }
                        
                        if let plays = artist.stats.playcountInt {
                            Text("**\(plays.formatted())** Total plays")
                                .font(.callout)
                        }
                        
                        if let myPlays = artist.stats.userplaycountInt {
                            Text("**\(myPlays.formatted())** Plays by you")
                                .font(.callout)
                        }
                        GroupBox {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(artist.tags.tag, id: \.name) { tag in
                                        Pill(text: tag.name, color: .pink)
                                    }
                                }
                                .padding(.horizontal)
                                .frame(height: 50)
                            }
                        } label: {
                            Label("Tags", systemImage: "tag.circle")
                        }
                        
                        GroupBox {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(artist.similar.artist, id: \.name) { simArtist in
                                        NavigationLink {
                                            ArtistDetailView(artist: simArtist)
                                        } label: {
                                            Pill(text: simArtist.name, color: .indigo)
                                                .pointerOnHover()
                                        }.buttonStyle(.plain)

                                    }
                                }.padding(.horizontal)
                                    .frame(height: 50)
                            }
                        } label: {
                            Label("Similar artists", systemImage: "person.2")
                        }
                        
                    }
                }
                
                Text(artist.bio.content)
            }.padding()
        }
    }
}

final class ArtistDetailViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var data: ArtistInfo?
    
    func load(_ artist: some Artist) async {
        
        defer {
            DispatchQueue.main.async {
                withAnimation {
                    self.isLoading = false
                }
            }
        }
        
        do {
            let data = try await LastfmAPI.getArtistDetail(artist: artist)
            DispatchQueue.main.async {
                self.data = data
            }
        } catch(let err){
            print(err)
        }
    }
}

struct ArtistDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistDetailView(artist: SimpleArtist(url: "", name: "Taylor Swift", mbid: ""))
    }
}
