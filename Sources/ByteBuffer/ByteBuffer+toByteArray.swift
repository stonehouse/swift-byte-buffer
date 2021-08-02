//
//  ByteBuffer+toByteArray.swift
//  ByteBuffer
//
//  Created by Alexander Stonehouse on 2/8/21.
//

import Foundation

extension ByteBuffer {
    public static func toByteArray<T>(_ value: T) -> [UInt8] {
        var value = value
        return withUnsafePointer(to: &value) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<T>.size) {
                Array(UnsafeBufferPointer(start: $0, count: MemoryLayout<T>.size))
            }
        }
    }
}
