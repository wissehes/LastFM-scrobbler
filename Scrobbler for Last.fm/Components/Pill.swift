//
//  Pill.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 08/03/2023.
//

import SwiftUI

struct Pill: View {
    var text: String
    var color: Color
    
    var body: some View {
        Text(text)
            .font(.system(.title3, design: .rounded, weight: .heavy))
            .foregroundColor(.white)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color)
            .clipShape(Capsule())
    }
}

struct Pill_Previews: PreviewProvider {
    static var previews: some View {
        Pill(text: "helo", color: .blue)
    }
}
