//
//  LoadingOverlay.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 08/03/2023.
//

import SwiftUI

struct LoadingOverlay: View {
    var body: some View {
        ProgressView()
            .padding()
            .background(.thickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(width: 100, height: 100)
    }
}

struct LoadingOverlay_Previews: PreviewProvider {
    static var previews: some View {
        LoadingOverlay()
    }
}
