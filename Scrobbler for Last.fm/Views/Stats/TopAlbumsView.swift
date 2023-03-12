//
//  TopAlbumsView.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 01/02/2023.
//

import SwiftUI
import Alamofire

struct TopAlbumsView: View {
    @StateObject var vm = TopAlbumsViewModel()
    
    var body: some View {
        list
            .listStyle(.inset(alternatesRowBackgrounds: true))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Create collage") { vm.isShowingSheet = true }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Picker("Period", selection: $vm.period) {
                        ForEach(Period.allCases, id: \.rawValue) { period in
                            Text(period.name)
                                .tag(period)
                        }
                    }
                }
            }
            .loading(vm.isLoading)
            .task(id: vm.period.rawValue) {
                await vm.load()
            }
            .sheet(isPresented: $vm.isShowingSheet) {
                CreateCollageView(type: .albums)
            }
    }
    
    var list: some View {
        List {
            ForEach(vm.data, id: \.id, content: rowItem(_:))
        }.environment(\.defaultMinListRowHeight, 110)
    }
    
    func rowItem(_ item: Album) -> some View {
        HStack(alignment: .center) {
            Rank(rank: item.attr.rank, emoji: true)
            
            ExternalImage(url: item.image.last?.text)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 10)
                .frame(width: 75, height: 75)
                .padding(5)
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .lineLimit(1)
                Text(item.artist.name)
                    .font(.title2)
                Text(item.scrobbles + " Scrobbles")
            }
            
            Spacer()
            
            Link(destination: item.url) {
                Label("View", systemImage: "arrow.up.forward.square")
            }.padding(.trailing)
        }.frame(height: 100)
    }
}

final class TopAlbumsViewModel: ObservableObject {
    @Published var data: [Album] = []
    @Published var isLoading = true
    @Published var period: Period = .overall
    
    @Published var isShowingSheet = false
    
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
            let data = try await LastfmAPI.getTopAlbums(period: period)
            DispatchQueue.main.async {
                self.data = data.albums.sorted {
                    ($0.playcountInt ?? 0) > ($1.playcountInt ?? 0)
                }
            }
        } catch AFError.responseValidationFailed(let error) {
            print("AFERROR")
            print(error)
        } catch(let err) {
            print(err)
        }
    }
}

struct TopAlbumsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TopAlbumsView()
        }
    }
}
