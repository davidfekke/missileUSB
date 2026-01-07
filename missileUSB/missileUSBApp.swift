//
//  missileUSBApp.swift
//  missileUSB
//
//  Created by David Fekke on 12/31/25.
//

import SwiftUI

@main
struct missileUSBApp: App {
    @Environment(\.openWindow) private var openWindow
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button {
                    openWindow(id: "about")
                } label: {
                    Text("About Missile USB")
                }
            }
        }
        
        Window("About Missile USB", id: "about") {
            AboutScreen()
                .containerBackground(.regularMaterial, for: .window)
                        .toolbar(removing: .title)
                        .toolbarBackground(.hidden, for: .windowToolbar)
        }
    }
}
