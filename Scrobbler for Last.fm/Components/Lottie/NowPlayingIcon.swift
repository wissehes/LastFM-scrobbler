//
//  NowPlayingIcon.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 10/03/2023.
//

import SwiftUI

struct NowPlayingIcon: View {
    @Environment(\.colorScheme) var colorScheme

    var icon: some View {
        LottieView(lottieFile: "now-playing")
            .frame(width: 50, height: 50)
    }
    
    var body: some View {
        switch colorScheme {
        case .dark:
            icon
        case .light:
            icon.colorInvert()
        @unknown default:
            icon
        }
    }
}

struct NowPlayingIcon_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingIcon()
    }
}
