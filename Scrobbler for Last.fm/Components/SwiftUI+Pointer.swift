//
//  SwiftUI+Pointer.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 10/03/2023.
//

import Foundation
import SwiftUI
import Cocoa

extension View {
    func pointerOnHover() -> some View {
        self
            .onHover { inside in
                if inside {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                    
                }
            }
    }
}
