//
//  Rank.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 01/02/2023.
//

import SwiftUI

struct Rank: View {
    
    let rank: String
    
    var body: some View {
        Text(rank)
            .font(.system(.title2, design: .rounded))
            .bold()
            .foregroundColor(.white)
            .scaledToFit()
            .frame(width: 40, height: 40)
            .lineLimit(1)
            .multilineTextAlignment(.center)
//            .background(Color.indigo.gradient)
//            .clipShape(Circle())
            .frame(width: 45, height: 45)
            .padding(5)
    }
}

struct Rank_Previews: PreviewProvider {
    static var previews: some View {
        Rank(rank: "1")
        Rank(rank: "100")

    }
}
