//
//  CreateCollageView.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 11/03/2023.
//

import SwiftUI
import Alamofire
import Cocoa
import UniformTypeIdentifiers

enum CollageType {
    case artists
    case albums
}

enum ArtistImageError: Error {
    case noImage
    case imageError
}

struct CreateCollageView: View {
    @StateObject var vm = CreateCollageViewModel()
    @Environment(\.dismiss) var dismiss
    
    var type: CollageType
    
    var body: some View {
        VStack(alignment: .trailing) {
            GroupBox {
                VStack(alignment: .leading) {
                    Picker(selection: $vm.period) {
                        ForEach(Period.allCases, id: \.rawValue) { period in
                            Text(period.name)
                                .tag(period)
                        }
                    } label: {
                        Label("Period", systemImage: "clock")
                    }.pickerStyle(.menu)
                        .frame(maxWidth: 300)
                    
                    HStack {
                        Label("Size", systemImage: "textformat.size")
                        TextField("", value: $vm.size, formatter: NumberFormatter())
                            .frame(maxWidth: 50)
                        Text("px")
                    }
                }.padding()
            } label: {
                Label("Settings", systemImage: "gear")
            }
            
            GroupBox {
                if vm.isLoading {
                    ProgressView()
                        .padding()
                        .frame(width: 300, height: 300)
                        .padding()
                } else {
                    CollageView(items: vm.data, size: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onDrag { vm.onDrag() ?? NSItemProvider() }
                        .padding()
                }
            } label: {
                Label("Preview", systemImage: "photo.fill")
            }
            
            HStack(alignment: .center) {
                Button() {
                    vm.saveFile(dismiss: dismiss)
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                }.disabled(vm.isLoading)
                    .frame(alignment: .leading)
                
                Button() { dismiss() } label: {
                    Label("Close", systemImage: "xmark.circle")
                }
            }
        }.padding()
            .frame(minWidth: 500, minHeight: 550)
            .task(id: vm.period) {
                do {
                    try await vm.load(type)
                } catch {
                    print(error)
                }
            }
    }
}

final class CreateCollageViewModel: ObservableObject {
    @Published var data: [CollageImage] = []
    @Published var isLoading = true
    @Published var period: Period = .overall
    
    @Published var size: Double = 1200
    
    func load(_ type: CollageType) async throws {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
                
        switch type {
        case .artists:
            let images = try await self.getArtistsAndImages()
            DispatchQueue.main.async {
                self.data = images
            }
        case .albums:
            let images = try await self.getAlbumsAndImages()
            DispatchQueue.main.async {
                self.data = images
            }
        }
    }
    
    private func getArtistsAndImages() async throws -> [CollageImage] {
        let data = try await LastfmAPI.getTopArtists(period: period)
        let firstNine = Array(data.artists.prefix(9))
        
        let mapped: [CollageImage] = await firstNine.asyncMap { item in
            var collageImage = CollageImage(item)
            let image = try? await loadArtistImage(artist: item)
            if let image = image {
                collageImage.image = image
            }
            // Wait 250 ms to try and not get rate-limited by last.fm
            try? await Task.sleep(for: .milliseconds(250))
            return collageImage
        }
        
        return mapped
    }
    
    private func getAlbumsAndImages() async throws -> [CollageImage] {
        let data = try await LastfmAPI.getTopAlbums(period: period)
        let firstNine = Array(data.albums.prefix(9))
        
        let mapped: [CollageImage] = await firstNine.asyncMap { item in
            var collageImage = CollageImage(item)
            let image = try? await loadImage(item)
            if let image = image {
                collageImage.image = image
            }
            return collageImage
        }
        
        return mapped
    }
    
    private func loadArtistImage(artist: Artist) async throws -> Image {
        let artistData = try await LastfmAPI.getArtistDetail(artist: artist)
        guard let url = artistData.image.last?.text else { throw ArtistImageError.noImage }
        
        let imageData = try await AF.request(url)
            .serializingData()
            .value
        
        guard let nsImage = NSImage(data: imageData) else { throw ArtistImageError.imageError }
        return Image(nsImage: nsImage)
    }
    
    func loadImage(_ item: Album) async throws -> Image? {
        guard let url = item.image.last?.text else { return nil }
        
        let data = try await AF.request(url)
            .serializingData()
            .value
        
        guard let image = NSImage(data: data) else { return nil }
        
        return Image(nsImage: image)
    }
    
    @MainActor func render() -> NSImage? {
        let collage = CollageView(items: self.data, size: size / 3)
        print("size: ", size / 3)
        
        let renderer = ImageRenderer(content: collage)
        
        renderer.scale = 1
        
        return renderer.nsImage
    }
    
    @MainActor func onDrag() -> NSItemProvider? {
        guard let image = self.render() else { print("no image"); return nil }
        guard let tiffRepresentation = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation),
              let bitmapRepresentation = bitmapImage.representation(using: .png, properties: [:]) else {
            return NSItemProvider(item: image.tiffRepresentation as NSSecureCoding?, typeIdentifier: UTType.fileURL.identifier as String)
        }
        
        
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("collage.png")
        try! bitmapRepresentation.write(to: url)
        
        let provider = NSItemProvider(item: url as NSSecureCoding?, typeIdentifier: UTType.fileURL.identifier as String)
        provider.suggestedName = url.lastPathComponent
        
        return provider
    }
    
    @MainActor func saveFile(dismiss: DismissAction?) {
        guard let url = showSavePanel() else { return }
        guard let image = self.render() else { print("no image"); return }
        guard let tiffRepresentation = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation),
              let bitmapRepresentation = bitmapImage.representation(using: .png, properties: [:]) else { return }
        
        //        let url = url.appendingPathComponent("collage.png")
        try? bitmapRepresentation.write(to: url)
        
        if let dismiss = dismiss {
            dismiss()
        }
    }
    
    func showSavePanel() -> URL? {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.allowsOtherFileTypes = false
        savePanel.title = "Save your collage"
        //        savePanel.message = "Choose a folder and a name to store your text."
        savePanel.nameFieldLabel = "File name:"
        //        savePanel.place
        
        let response = savePanel.runModal()
        print(response)
        return response == .OK ? savePanel.url : nil
    }
}

struct CreateCollageView_Previews: PreviewProvider {
    static var previews: some View {
        CreateCollageView(type: .albums)
    }
}

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()
        
        for element in self {
            try await values.append(transform(element))
        }
        
        return values
    }
}
