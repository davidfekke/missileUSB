//
//  AboutScreen.swift
//  missileUSB
//
//  Created by David Fekke on 1/6/26.
//

import SwiftUI

struct AboutScreen: View {
    var body: some View {
        HStack {
            // Source - https://stackoverflow.com/a
            // Posted by Asperi, modified by community. See post 'Timeline' for change history
            // Retrieved 2026-01-06, License - CC BY-SA 4.0

            Image("missile")
                .resizable()
                .scaledToFit()
            VStack {
                Text("Missile USB")
                    .font(.largeTitle)
                Text("This a utility for launching Nerf missiles!")
                Text("Copyright David Fekke 2026!")
            }
        }
        
    }
}

