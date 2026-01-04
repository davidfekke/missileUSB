//
//  ContentView.swift
//  missileUSB
//
//  Created by David Fekke on 12/31/25.
//

import SwiftUI

struct ContentView: View {
    let usbController = AirCannon()
    
    
    // Set up the listener
   
    
    var body: some View {
        VStack {
            
            Button("Up") {
                Task {
                    await usbController.moveSmart(direction: .up, duration: 0.5)
                }
            }
            HStack {
                Button("Left") {
                    Task {
                        await usbController.moveSmart(direction: .left, duration: 0.5)
                    }
                    
                }
                Button("Stop") {
                    Task {
                        usbController.stop()
                    }
                    
                }
                Button("Right") {
                    Task {
                        await usbController.moveSmart(direction: .right, duration: 0.5)
                    }
                    
                }
            }
            
            Button("Down") {
                Task {
                    await usbController.moveSmart(direction: .down, duration: 0.5)
                }
                
            }
            Button("Fire") {
                Task {
                    await usbController.fireAndWait {}
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
