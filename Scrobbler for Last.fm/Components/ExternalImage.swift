//
//  ExternalImage.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 02/02/2023.
//

import SwiftUI

struct ExternalImage: View {
    
    var url: URL?
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure(_):
                ProgressView()
            @unknown default:
                ProgressView()
            }
        }

    }
}

struct ExternalImage_Previews: PreviewProvider {
    static var previews: some View {
        ExternalImage()
    }
}
