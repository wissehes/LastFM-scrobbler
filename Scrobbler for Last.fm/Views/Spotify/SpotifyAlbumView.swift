//
//  SpotifyAlbumView.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 07/03/2023.
//

import SwiftUI
import SpotifyWebAPI
import Foundation
import AppKit
import AlertToast

struct SpotifyAlbumView: View {
    
    var albumURI: String
    @StateObject var vm = SpotifyAlbumViewModel()
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Group {
            if let album = vm.album {
                success(album: album)
                    .navigationTitle(album.name)
            } else {
                LongProgessView()
                    .navigationTitle("Loading...")
            }
        }.onAppear {
            vm.load(uri: albumURI)
        }
        .transition(.opacity)
    }
    
    func success(album: SpotifyWebAPI.Album) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                ExternalImage(url:album.images?.first?.url)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .frame(width: 200, height: 200)
                    .padding(5)
                
                VStack(alignment: .leading) {
                    Text(album.name)
                        .font(.system(.title, design: .rounded, weight: .bold))
                    Text("By " + album.formatArtists())
                    
                    Spacer()
                    
                    HStack {
                        Button("Scrobble album") {
                            Task {
                                await vm.scrobbleAlbum()
                            }
                        }.help("Scrobble the whole album as if you've just finished listening to it.")
                        
                        Button("Scrobble selected") {
                            Task {
                                await vm.scrobbleSelected()
                            }
                        }.disabled(vm.selectedTracks.count == 0)
                        
                        Button("Open on Spotify") {
                            if let uri = album.uri {
//                                openURL(URL(string: "https://open.spotify.com/album/\(id)")!)
                                openURL(URL(string: uri)!)
                            }
                        }
                    }
                }
                
                
            }.frame(height: 200)
                .padding()
            
            List(album.tracks?.items ?? [], id: \.id, selection: $vm.selectedTracks) { track in
                trackRowItem(track)
                    .tag(track)
            }
            .listStyle(.bordered(alternatesRowBackgrounds: true))
        }.toast(isPresenting: $vm.isShowingToast) {
            AlertToast(type: .complete(.green), title: "Successfully scrobbled \(album.name)")
        }
    }
    
    func trackRowItem(_ track: SpotifyWebAPI.Track) -> some View {
        //        VStack(alignment: .leading) {
        HStack {
            Text(track.trackNumber?.description ?? "-")
                .font(.system(.headline, design: .monospaced))
                .lineLimit(1)
                .multilineTextAlignment(.trailing)
                .frame(width:30, height: 25)
            VStack(alignment: .leading) {
                Text(track.name)
                    .font(.headline)
                
                Text(track.artists?.map { $0.name }.joined(separator: ", ") ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formattedTrackLength(track: track))
                .padding(.trailing, 10)
        }
        //        }
    }
    
    func formattedTrackLength(track: SpotifyWebAPI.Track) -> String {
        let double = Double(track.durationMS ?? 0) / 1000
        return double.toMinutesAndSeconds()
    }
}

final class SpotifyAlbumViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var album: SpotifyWebAPI.Album?
    @Published var isShowingToast = false
    @Published var selectedTracks = Set<SpotifyWebAPI.Track>()
    
    func load(uri: String) {
        Spotify.shared.client.album(uri)
            .sink { completion in
                print(completion)
            } receiveValue: { album in
                DispatchQueue.main.async {
                    withAnimation {
                        self.album = album
                    }
                }
            }
            .store(in: &Spotify.shared.cancellables)
        
    }
    
    func scrobbleAlbum() async {
        defer {
            DispatchQueue.main.async {
                self.isShowingToast = true
            }
        }
        
        if let tracks = album?.tracks?.items {
            print("scrobbling...")
            do {
                try await LastfmAPI.scrobble.scrobbleAlbumTracks(tracks: tracks, album: album)
            } catch { }
        }
    }
    
    func scrobbleSelected() async {
        defer {
            DispatchQueue.main.async {
                self.isShowingToast = true
            }
        }
        
        if selectedTracks.count > 0 {
            print("scrobbling...")
            do {
                try await LastfmAPI.scrobble.scrobbleAlbumTracks(tracks: Array(selectedTracks), album: album)
            } catch { }
        }
    }
}

struct SpotifyAlbumView_Previews: PreviewProvider {
    static var previews: some View {
        // URI for Midnights by taylor
        SpotifyAlbumView(albumURI: "spotify:album:151w1FgRZfnKZA9FEcg9Z3")
            .frame(width: 1000, height: 600)
    }
}

extension Double {
    func toMinutesAndSeconds() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        
        let formattedString = formatter.string(from: TimeInterval(self))!
        return formattedString
    }
}

extension SpotifyWebAPI.Album {
    func formatArtists() -> String {
        return self.artists?.map { $0.name }.formatted(.list(type: .and)) ?? ""
    }
}
