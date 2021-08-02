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
    
    // MARK: - Private
    
    private var reader = BitReader()
    private var writer = BitWriter()
    internal(set) public var data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public init(capacity: Int) {
        self.data = Data(capacity: capacity)
    }
    
    public init() {
        self.data = Data()
    }
    
    // MARK: - Writing
    
    mutating func write(bits: Int, data inData: Data) {
        writer.write(bits: bits, data: inData, outData: &data)
    }
    
    mutating func write(bytes: Int, data inData: Data) {
        writer.write(bytes: bytes, data: inData, outData: &data)
    }
    
    // MARK: - Reading
    
    mutating func read(bits: Int) throws -> UInt64 {
        try reader.read(bits: bits, data: &data)
    }
    
    mutating func read(bytes: Int) throws -> UInt64 {
        try reader.read(bytes: bytes, data: &data)
    }
    
    public var remaining: Int {
        return reader.remainingBits(data)
    }
    
    public mutating func rewind() {
        reader.rewind()
    }
}
