//
//  Rank.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 01/02/2023.
//

import SwiftUI

struct Rank: View {
    
    let rank: String
    
    var text: some View {
        Text(rank)
            .font(.title2)
            .bold()
            .scaledToFit()
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .strokeBorder(Color.pink, lineWidth: 5)
            .overlay(text)
            .frame(width: 50, height: 50)
            .padding(5)
    }
}

struct Rank_Previews: PreviewProvider {
    static var previews: some View {
        Rank(rank: "1")
    }
}
