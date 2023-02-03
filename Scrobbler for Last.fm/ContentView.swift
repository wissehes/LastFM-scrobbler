//
//  ContentView.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 01/02/2023.
//

import SwiftUI

fileprivate enum Page {
    case topArtists
    case topAlbums
    case topTracks
    
    case recentTracks
    case lovedTracks
    
    case empty
}

struct ContentView: View {
    @EnvironmentObject var authController: AuthController
    
    @State private var selectedPage: Page = .topArtists
    
    var body: some View {
        switch authController.state {
        case .loading:
            ProgressView()
                .padding()
        case .authorized(_):
            navigation
        case .notAuthorized:
            LoginView()
        }
        
    }
    
    var navigation: some View {
        NavigationSplitView {
            List(selection: $selectedPage) {
                
                Section {
                    NavigationLink(value: Page.recentTracks) {
                        Label("Recently played", systemImage: "clock")
                    }
                    
                    NavigationLink(value: Page.lovedTracks) {
                        Label("Loved tracks", systemImage: "heart")
                    }
                } header: {
                    Label("Me", systemImage: "person.circle")
                        .symbolRenderingMode(.palette)
                }
                
                Section {
                    NavigationLink(value: Page.topArtists) {
                        Label("Artists", systemImage: "music.mic")
                    }
                    
                    NavigationLink(value: Page.topAlbums) {
                        Label("Albums", systemImage: "opticaldisc")
                    }
                    
                    NavigationLink(value: Page.topTracks) {
                        Label("Tracks", systemImage: "music.note.list")
                    }
                } header: {
                    Label("Statistics", systemImage: "chart.xyaxis.line")
                }
                
                
            }.symbolRenderingMode(.multicolor)
                .listStyle(.sidebar)
                .navigationTitle("Sidebar")
        } detail: {
            switch selectedPage {
            case .topArtists:
                TopArtistsView()
            case .topAlbums:
                TopAlbumsView()
            case .topTracks:
                TopTracksView()
                
            case .recentTracks:
                RecentTracksView()
            case .lovedTracks:
                LovedTracksView()
            case .empty:
                Text("Hey!")
                    .background(.thinMaterial)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthController.shared)
    }
}
