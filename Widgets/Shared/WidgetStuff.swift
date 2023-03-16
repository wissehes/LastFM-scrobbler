//
//  WidgetStuff.swift
//  WidgetsExtension
//
//  Created by Wisse Hes on 17/03/2023.
//

import Foundation

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
