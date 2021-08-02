//
//  BitWriter.swift
//  ByteBuffer
//
//  Created by Alexander Stonehouse on 2/8/21.
//

import Foundation

struct BitWriter {
    private var currentValue: UInt8 = 0
    // Index in bits in the current byte (stored in currentValue)
    private var bitIndex: Int = 0
    
    mutating func write(bytes: Int, data readData: Data, outData: inout Data) {
        guard bitIndex == 0 else {
            write(bits: bytes * 8, data: readData, outData: &outData)
            return
        }
        
        outData.append(readData[0..<bytes])
    }
    
    mutating func write(bits: Int, data readData: Data, outData: inout Data) {
        var i = 0
        var bitsLeft = bits
        // To append all the bits, we go byte by byte
        while (i * 8) < bits {
            // Either read a whole byte or the remaining bits
            let bitsToRead = bitsLeft < 8 ? bitsLeft : 8
            // Mask to make sure we only read in the indended bits
            var bitMask: UInt8 = 0
            for _ in 0..<bitsToRead {
                bitMask = (bitMask << 1) + 1
            }
            
            let inByte = readData[i]
            // How far the current value should be shifted (basically tells us how many new
            // bits from the new byte should be added to the current byte). Potentially we
            // need to add a few bits to a previous byte and then put the remaining bits in
            // a new byte.
            let mergedByte = currentValue | ((inByte & bitMask) << bitIndex)
            
            var newIndex = bitIndex + bitsToRead
            if newIndex >= 8 {
                // Commit completed byte
                outData.append(mergedByte)
                // Remove byte from index
                newIndex -= 8
                bitIndex = newIndex
                
                var readBitsAnd: UInt8 = 0
                for _ in 0..<newIndex {
                    readBitsAnd = (readBitsAnd << 1) + 1
                }
                // Wipe read bits from byte
                currentValue = inByte & readBitsAnd
            } else {
                // Save partial byte, continue to next byte from input
                currentValue = mergedByte
                bitIndex = newIndex
            }
            
            i += 1
            bitsLeft -= 8
        }
    }
}
