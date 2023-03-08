//
//  LongProgessView.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 08/03/2023.
//

import SwiftUI

struct LongProgessView: View {
    @State private var showProgress = false
    
    //    @ViewBuilder
    var body: some View {
        ProgressView()
            .opacity(showProgress ? 1 : 0)
            .task {
                await countDown()
            }
    }
    func countDown() async {
        try? await Task.sleep(for: .seconds(1))
        DispatchQueue.main.async {
            withAnimation {
                self.showProgress = true
            }
        }
    }
}

struct LongProgessView_Previews: PreviewProvider {
    static var previews: some View {
        LongProgessView()
    }
}
