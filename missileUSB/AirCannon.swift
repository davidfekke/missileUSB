import Foundation
import IOKit.hid

class AirCannon {
    private let vendorID: Int32 = 0x1941
    private let productID: Int32 = 0x8021
    private var manager: IOHIDManager?
    private var device: IOHIDDevice?

    init() {
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        
        let deviceMatch: [String: Any] = [
            kIOHIDVendorIDKey: vendorID,
            kIOHIDProductIDKey: productID
        ]
        
        IOHIDManagerSetDeviceMatching(manager!, deviceMatch as CFDictionary)
        
        // Register connection callbacks
        let clientPointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        IOHIDManagerRegisterDeviceMatchingCallback(manager!, { (context, result, sender, device) in
            let mySelf = Unmanaged<AirCannon>.fromOpaque(context!).takeUnretainedValue()
            mySelf.device = device
            print("Cannon Connected!")
        }, clientPointer)

        IOHIDManagerScheduleWithRunLoop(manager!, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerOpen(manager!, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    private func send(bytes: [UInt8]) {
        guard let device = device else {
            print("Error: Cannon not connected")
            return
        }

        let reportID: CFIndex = 0
        let result = IOHIDDeviceSetReport(
            device,
            kIOHIDReportTypeOutput,
            reportID,
            bytes,
            bytes.count
        )

        if result != kIOReturnSuccess {
            print("Failed to send command: \(result)")
        }
    }

    // MARK: - Commands
    func stop()  { send(bytes: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]) }
    func up()    { send(bytes: [0x01, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]) }
    func down()  { send(bytes: [0x02, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]) }
    func left()  { send(bytes: [0x04, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]) }
    func right() { send(bytes: [0x08, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]) }
    func fire()  { send(bytes: [0x10, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]) }
    
    // MARK: - Movement with Auto-Stop
    func moveTimed(direction: String, duration: Double = 1.0) {
        switch direction.lowercased() {
        case "up": up()
        case "down": down()
        case "left": left()
        case "right": right()
        case "fire": fire()
        default: return
        }
        
        // Schedule the stop command
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.stop()
            print("Movement stopped.")
        }
    }
}
