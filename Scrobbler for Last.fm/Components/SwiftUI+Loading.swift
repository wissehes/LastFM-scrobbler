//
//  SwiftUI+Loading.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 08/03/2023.
//

import Foundation
import SwiftUI

extension View {
    func loading(_ loading: Bool) -> some View {
        overlay {
            if loading {
                LoadingOverlay()
                    .contentTransition(.opacity)
            }
        }
    }
}
