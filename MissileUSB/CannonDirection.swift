//
//  CannonDirection.swift
//  missileUSB
//
//  Created by David Fekke on 1/3/26.
//

public enum CannonDirection {
    case up, down, left, right
    
    // Returns (Byte Index, Bitmask)
    var limitConfig: (index: Int, mask: UInt8) {
        switch self {
        case .up:    return (0, 0x80) // 128
        case .down:  return (0, 0x40) // 64
        case .left:  return (1, 0x04) // 4
        case .right: return (1, 0x08) // 8
        }
    }
}
