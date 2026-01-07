import Foundation
import IOKit.hid

class AirCannon {
    private let vendorID: Int32 = 0x1941
    private let productID: Int32 = 0x8021
    private var manager: IOHIDManager?
    private var device: IOHIDDevice?
    
    private var lastStatus: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0]
    // Allocate 8 bytes of memory for the report buffer
    private let reportBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 8)
    
    private let hidWriteQueue = DispatchQueue(label: "hid.write.queue")

    // Your existing logic now works instantly
    var isFiringInProgress: Bool {
        let status = getStatus()
        return (status[1] & 0x80) != 0
    }
    
    func isLimitReached(for direction: CannonDirection) -> Bool {
        let status = getStatus()
        let config = direction.limitConfig
        
        // Check if the specific bit is set in the status byte
        return (status[config.index] & config.mask) != 0
    }
    
    init() {
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
            
        let deviceMatch: [String: Any] = [
            kIOHIDVendorIDKey: vendorID,
            kIOHIDProductIDKey: productID
        ]
        
        IOHIDManagerSetDeviceMatching(manager!, deviceMatch as CFDictionary)
        
        // 1. Create the pointer for 'self' to use inside closures
        let clientPointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        // 2. Register the matching callback
        IOHIDManagerRegisterDeviceMatchingCallback(manager!, { (context, result, sender, device) in
            let mySelf = Unmanaged<AirCannon>.fromOpaque(context!).takeUnretainedValue()
            mySelf.device = device
            print("Cannon Connected!")
            
            // --- MOVE REGISTRATION HERE ---
            // Now that we HAVE the device, we can tell the OS to listen to it
            IOHIDDeviceRegisterInputReportCallback(
                device,
                mySelf.reportBuffer,
                8,
                { (context, result, sender, type, reportId, report, reportLength) in
                    let mySelf = Unmanaged<AirCannon>.fromOpaque(context!).takeUnretainedValue()
                    let data = UnsafeBufferPointer(start: report, count: reportLength)
                    mySelf.lastStatus = Array(data)
                },
                context // Pass the same clientPointer (context)
            )
            // ------------------------------
            
        }, clientPointer)

        // 3. Schedule and Open
        IOHIDManagerScheduleWithRunLoop(manager!, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerOpen(manager!, IOOptionBits(kIOHIDOptionsTypeNone))
    }
    
    private func getStatus() -> [UInt8] {
        return lastStatus
    }

    private func send(bytes: [UInt8]) {
        guard let device = device else {
            print("Error: Cannon not connected")
            return
        }

        hidWriteQueue.async {
        
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
        
        
    }

    // MARK: - Commands
    func stop()  { send(bytes: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]) }
    func up()    { send(bytes: [0x01, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]) }
    func down()  { send(bytes: [0x02, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]) }
    func left()  { send(bytes: [0x04, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]) }
    func right() { send(bytes: [0x08, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]) }
    func fire()  { send(bytes: [0x10, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]) }
    
    func moveSmart(direction: CannonDirection, duration: Double) async {
        // 1. Start moving
        switch direction {
        case .up:    up()
        case .down:  down()
        case .left:  left()
        case .right: right()
        }

        let startTime = Date()
        
        // 2. Monitor on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            while Date().timeIntervalSince(startTime) < duration {
                if self.isLimitReached(for: direction) {
                    print("Limit reached for \(direction)! Stopping.")
                    break
                }
                usleep(5000) // Poll every 5ms
            }
            
            // 3. Stop movement
            self.stop()
        }
    }
    
    func fireAndWait(completion: @escaping () -> Void) async {
        // 1. Send the fire command
        fire()
        
        // 2. Poll the device on a background thread so we don't freeze the app
        DispatchQueue.global(qos: .userInitiated).async {
            // Wait for the motor to start moving (the bit becomes 1)
            while !self.isFiringInProgress {
                usleep(10000) // Sleep 10ms to save CPU
            }
            
            // Wait for the motor to return to home (the bit becomes 0)
            while self.isFiringInProgress {
                usleep(10000)
            }
            
            // 3. Command complete
            self.stop()
            DispatchQueue.main.async {
                print("Firing cycle complete.")
                completion()
            }
        }
    }
    
    deinit {
        reportBuffer.deallocate()
        
        // Also a good idea to stop the manager
        if let manager = manager {
            IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        }
    }
}
