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

struct CreateCollageView: View {
    @StateObject var vm = CreateCollageViewModel()
    @Environment(\.displayScale) var displayScale
    
    var body: some View {
        NavigationStack {
//            VStack(alignment: .center) {
            Form {
                Picker("Period", selection: $vm.period) {
                    ForEach(Period.allCases, id: \.rawValue) { period in
                        Text(period.name)
                            .tag(period)
                    }
                }.pickerStyle(.menu)
                
                GroupBox("Preview") {
                    if vm.isLoading {
                        ProgressView()
                            .padding()
                            .frame(width: 300, height: 300)
                    } else {
                        CollageView(items: vm.data, size: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onDrag { vm.onDrag(scale: displayScale) ?? NSItemProvider() }
                    }
                }
                
                Button("Export") {
                    
                }.disabled(vm.isLoading)
            }.padding()
                .frame(width: 500, height: 500)
                .task(id: vm.period) {
                    do {
                        try await vm.load()
                    } catch {
                        print(error)
                    }
                }
        }
    }
}

final class CreateCollageViewModel: ObservableObject {
    @Published var data: [CollageImage] = []
    @Published var isLoading = true
    @Published var period: Period = .overall
    
    @Published var isShowingSheet = false
    
    func load() async throws {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
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
        
        DispatchQueue.main.async {
            self.data = mapped
        }
    }
    
    func loadImage(_ item: Album) async throws -> Image? {
        guard let url = item.image.last?.text else { return nil }
        
        let data = try await AF.request(url)
            .serializingData()
            .value

        guard let image = NSImage(data: data) else { return nil }
        
        return Image(nsImage: image)
    }
    
    @MainActor func render(scale: Double) -> NSImage? {
        let collage = CollageView(items: self.data, size: 200)
        
        let renderer = ImageRenderer(content: collage)
        
        // make sure and use the correct display scale for this device
        renderer.scale = scale
        
        return renderer.nsImage
    }
    
    @MainActor func onDrag(scale: Double) -> NSItemProvider? {
        guard let image = self.render(scale: scale) else { print("no image"); return nil }
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
}

struct CreateCollageView_Previews: PreviewProvider {
    static var previews: some View {
        CreateCollageView()
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
