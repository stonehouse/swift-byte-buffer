//
//  ByteBuffer+write.swift
//  ByteBuffer
//
//  Created by Alexander Stonehouse on 2/8/21.
//

import Foundation

extension ByteBuffer {
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
}
