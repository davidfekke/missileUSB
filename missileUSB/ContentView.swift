//
//  ContentView.swift
//  missileUSB
//
//  Created by David Fekke on 12/31/25.
//

import SwiftUI

struct ContentView: View {
    let usbController = AirCannon()
    
    var body: some View {
        VStack {
            
            Button("Up") {
                usbController.moveTimed(direction: "up")
            }
            HStack {
                Button("Left") {
                    usbController.moveTimed(direction: "left")
                }
                Button("Stop") {
                    usbController.moveTimed(direction: "stop")
                }
                Button("Right") {
                    usbController.moveTimed(direction: "right")
                }
            }
            
            Button("Down") {
                usbController.moveTimed(direction: "down")
            }
            Button("Fire") {
                usbController.moveTimed(direction: "fire", duration: 2)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
