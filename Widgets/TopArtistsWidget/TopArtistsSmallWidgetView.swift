//
//  TopArtistsSmallWidgetView.swift
//  WidgetsExtension
//
//  Created by Wisse Hes on 16/03/2023.
//

import SwiftUI

struct TopArtistsSmallWidgetView: View {
    let entry: TopArtistsEntry
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct TopArtistsSmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        TopArtistsSmallWidgetView(entry: .init(date: .now, configuration: ConfigurationIntent(), artists: .examples))
    }
}
