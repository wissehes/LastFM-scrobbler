//
//  Text+PillBackground.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 17/03/2023.
//

import Foundation
import SwiftUI

extension View {
    func pillbackground() -> some View {
        self
            .multilineTextAlignment(.center)
            .padding(.leading, 4)
            .padding(.trailing, 4)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
