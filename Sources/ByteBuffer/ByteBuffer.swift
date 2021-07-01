//
//  ByteBuffer.swift
//  ByteBuffer
//
//  Created by Alexander Stonehouse on 25/2/19.
//

import Foundation

public struct ByteBuffer {
    
    // MARK: - Errors
    
    public enum Errors: Error {
        case insufficientBytes
    }
    
    // MARK: - Bit Manipulators
    
    private struct BitReader {
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
    
    private struct BitWriter {
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
    
    // MARK: - Private
    
    private var reader = BitReader()
    private var writer = BitWriter()
    private(set) public var data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public init(capacity: Int) {
        self.data = Data(capacity: capacity)
    }
    
    public init() {
        self.data = Data()
    }
    
    private mutating func read(bits: Int) throws -> UInt64 {
        try reader.read(bits: bits, data: &data)
    }
    
    private mutating func read(bytes: Int) throws -> UInt64 {
        try reader.read(bytes: bytes, data: &data)
    }
    
    private mutating func write(bits: Int, data inData: Data) {
        writer.write(bits: bits, data: inData, outData: &data)
    }
    
    private mutating func write(bytes: Int, data inData: Data) {
        writer.write(bytes: bytes, data: inData, outData: &data)
    }
    
    // MARK: - Reading
    
    public var remaining: Int {
        return reader.remainingBits(data)
    }
    
    public mutating func rewind() {
        reader.rewind()
    }
    
    public mutating func readBool(bits: Int) throws -> Bool {
        return Bool(truncating: try read(bits: bits) as NSNumber)
    }
    
    public mutating func readBool() throws -> Bool {
        return Bool(truncating: try read(bytes: 1) as NSNumber)
    }
    
    public mutating func readByte(bits: Int) throws -> UInt8 {
        UInt8(try read(bits: bits))
    }
    
    public mutating func readByte() throws -> UInt8 {
        UInt8(try read(bytes: 1))
    }
    
    public mutating func readShort(bits: Int) throws -> UInt16 {
        return UInt16(try read(bits: bits))
    }
    
    public mutating func readShort() throws -> UInt16 {
        return UInt16(try read(bytes: 2))
    }
    
    public mutating func readUInt32(bits: Int) throws -> UInt32 {
        return UInt32(try read(bits: bits))
    }
    
    public mutating func readUInt32() throws -> UInt32 {
        return UInt32(try read(bytes: 4))
    }
    
    public mutating func readUInt64(bits: Int) throws -> UInt64 {
        return try read(bits: bits)
    }
    
    public mutating func readUInt64() throws -> UInt64 {
        return try read(bytes: 8)
    }
    
    public mutating func readBytes(_ count: Int) throws -> [UInt8] {
        return try (0..<count).map { _ in try readByte() }
    }
    
    // MARK: - Writing
    
    public mutating func write(bool: Bool, bits: Int) {
        write(bits: bits, data: Data(ByteBuffer.toByteArray(bool)))
    }
    
    public mutating func write(bool: Bool) {
        write(bytes: 1, data: Data(ByteBuffer.toByteArray(bool)))
    }
    
    public mutating func write(byte: UInt8, bits: Int) {
        write(bits: bits, data: Data([byte]))
    }
    
    public mutating func write(byte: UInt8) {
        write(bytes: 1, data: Data([byte]))
    }
    
    public mutating func write(short: UInt16, bits: Int) {
        write(bits: bits, data: Data(ByteBuffer.toByteArray(short)))
    }
    
    public mutating func write(short: UInt16) {
        write(bytes: 2, data: Data(ByteBuffer.toByteArray(short)))
    }
    
    public mutating func write(uint32: UInt32, bits: Int) {
        write(bits: bits, data: Data(ByteBuffer.toByteArray(uint32)))
    }
    
    public mutating func write(uint32: UInt32) {
        write(bytes: 4, data: Data(ByteBuffer.toByteArray(uint32)))
    }
    
    public mutating func write(uint64: UInt64, bits: Int) {
        write(bits: bits, data: Data(ByteBuffer.toByteArray(uint64)))
    }
    
    public mutating func write(uint64: UInt64) {
        write(bytes: 8, data: Data(ByteBuffer.toByteArray(uint64)))
    }
    
    public mutating func write(bytes: [UInt8]) {
        write(bytes: bytes.count, data: Data(bytes))
    }
    
    public mutating func write(data inData: Data) {
        data.append(inData)
    }
    
    // MARK: - Helpers
    
    public static func toByteArray<T>(_ value: T) -> [UInt8] {
        var value = value
        return withUnsafePointer(to: &value) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<T>.size) {
                Array(UnsafeBufferPointer(start: $0, count: MemoryLayout<T>.size))
            }
        }
    }
}
