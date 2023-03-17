//
//  WidgetStuff.swift
//  WidgetsExtension
//
//  Created by Wisse Hes on 17/03/2023.
//

import Foundation
import SwiftUI

protocol WidgetEntry {
    var configuration: ConfigurationIntent { get }
    var items: [CollageImage] { get }
    var username: String? { get }
    var error: Error? { get }
}

extension WidgetEntry {
    func usernameText(_ type: WidgetType) -> String {
        if let text = self.username {
            return String(format: type.title, text)
        } else {
            return String(format: type.title, "Your")
        }
    }
}

enum WidgetType: String {
    case albums
    case artists
    
    var title: String {
        "%@'s most listened \(self)"
    }
}

extension View {
    func headerStyle() -> some View {
        self
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .lineLimit(1)
            .multilineTextAlignment(.center)
            .padding(.leading, 3)
            .padding(.trailing, 3)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
    
    func subheaderStyle() -> some View {
        self
            .font(.system(size: 9, design: .rounded))
            .lineLimit(1)
            .multilineTextAlignment(.center)
            .padding(.leading, 3)
            .padding(.trailing, 3)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
