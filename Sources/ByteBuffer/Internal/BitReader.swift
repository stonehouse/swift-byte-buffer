//
//  BitReader.swift
//  ByteBuffer
//
//  Created by Alexander Stonehouse on 2/8/21.
//

import Foundation

struct BitReader {
    private var byteOffset: Int = 0
    private var currentValue: UInt64 = 0
    /// How much space is left in the currentValue
    private var bitOverhang: Int = 0
    
    func remainingBytes(_ data: Data) -> Int {
        data.count - byteOffset
    }
    
    func remainingBits(_ data: Data) -> Int {
        return 8 * remainingBytes(data) + bitOverhang
    }
    
    mutating func rewind() {
        byteOffset = 0
        bitOverhang = 0
        currentValue = 0
    }
    
    mutating func read(bytes: Int, data: inout Data) throws -> UInt64 {
        guard remainingBytes(data) >= bytes else {
            throw ByteBuffer.Errors.insufficientBytes
        }

        // Reading full bytes only supported if not partially through a byte
        guard bitOverhang == 0 else {
            return try read(bits: bytes * 8, data: &data)
        }

        let subdata = data.subdata(in: byteOffset..<byteOffset+bytes)
        byteOffset += bytes

        var value: UInt64 = 0

        _ = withUnsafeMutableBytes(of: &value, {
            subdata.copyBytes(to: $0)
        })

        return value
    }
    
    mutating func read(bits: Int, data: inout Data) throws -> UInt64 {
        guard remainingBits(data) >= bits else {
            throw ByteBuffer.Errors.insufficientBytes
        }
        // Collect bytes until we have enough bits
        while bitOverhang < bits {
            // Move value over and append new byte
            currentValue = currentValue | (UInt64(data[byteOffset]) << bitOverhang)
            bitOverhang += 8
            byteOffset += 1
        }
        
        var bitsToRead: UInt64 = 0
        for _ in 0..<bits {
            bitsToRead = (bitsToRead << 1) + 1
        }
        
        // Remove overhang bits
        let result = currentValue & bitsToRead
        // Shift value to throw away read bits
        currentValue = currentValue >> UInt64(bits)
        // Rewind bit offset for next read
        bitOverhang -= bits
        
        return result
    }
}
