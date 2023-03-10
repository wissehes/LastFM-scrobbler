//
//  LottieView.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 10/03/2023.
//

import SwiftUI
import Lottie

struct LottieView: NSViewRepresentable {
    let lottieFile: String
    
    let animationView = LottieAnimationView()
    
    
    public func makeNSView(context: Context) -> some NSView {
        let view = NSView()
      
        animationView.animation = LottieAnimation.named(lottieFile)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.play()
        
        view.addSubview(animationView)
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        animationView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        animationView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return view
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {

    }
}

struct LottieView_Previews: PreviewProvider {
    static var previews: some View {
        LottieView(lottieFile: "now-playing")
            .frame(width: 50, height: 50)
    }
}
