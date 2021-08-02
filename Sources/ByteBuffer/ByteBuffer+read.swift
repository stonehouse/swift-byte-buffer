//
//  ByteBuffer+read.swift
//  ByteBuffer
//
//  Created by Alexander Stonehouse on 2/8/21.
//

import Foundation

extension ByteBuffer {
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
}
