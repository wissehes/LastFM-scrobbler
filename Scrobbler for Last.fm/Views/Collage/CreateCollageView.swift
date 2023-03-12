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
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .trailing) {
//            Form {
                GroupBox {
                    VStack(alignment: .leading) {
                        Picker("Period", selection: $vm.period) {
                            ForEach(Period.allCases, id: \.rawValue) { period in
                                Text(period.name)
                                    .tag(period)
                            }
                        }.pickerStyle(.menu)
                            .frame(maxWidth: 300)
                        
                        HStack {
                            Text("Size")
                            TextField("", value: $vm.size, formatter: NumberFormatter())
                            Text("px")
                        }.frame(maxWidth: 150)
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
                        try await vm.load()
                    } catch {
                        print(error)
                    }
                }
                .navigationTitle("Create a collage")
        }
    }
}

final class CreateCollageViewModel: ObservableObject {
    @Published var data: [CollageImage] = []
    @Published var isLoading = true
    @Published var period: Period = .overall
    
    @Published var size: Double = 600

    
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
