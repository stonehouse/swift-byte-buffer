//
//  ByteBufferTests.swift
//  ByteBufferTests
//
//  Created by Alexander Stonehouse on 25/2/19.
//

import XCTest
import Nimble
import ByteBuffer

class ByteBufferTests: XCTestCase {
    func testBufferRewind() {
        var buffer = ByteBuffer()
        expect(buffer.remaining).to(equal(0))
        buffer.write(bytes: [0x01, 0x00, 0x01, 0xf0])
        expect(buffer.remaining).to(equal(32))
        expect(try? buffer.readByte()).to(equal(0x01))
        expect(try? buffer.readShort()).to(equal(0x01_00))
        expect(try? buffer.readByte()).to(equal(0xf0))
        expect(buffer.remaining).to(equal(0))
        buffer.rewind()
        expect(buffer.remaining).to(equal(32))
        expect(try? buffer.readByte()).to(equal(0x01))
        expect(buffer.remaining).to(equal(24))
        do {
            _ = try buffer.readUInt64()
            XCTFail()
        } catch let e {
            expect(e).to(matchError(ByteBuffer.Errors.insufficientBytes))
        }
    }
    
    func testReadUInt32() throws {
        var buffer = ByteBuffer()
        buffer.write(bytes: [0x01, 0x00, 0x00, 0xFF])
        expect(try buffer.readUInt32()) == 0xFF000001
        
        buffer.rewind()
        expect(try buffer.readUInt32(bits: 32)) == 0xFF000001
    }
    
    func testReadBytes() throws {
        var buffer = ByteBuffer()
        buffer.write(bytes: [0x01, 0x02, 0x03, 0x04])        
        expect(try buffer.readByte()) == 0x01
        expect(try buffer.readByte()) == 0x02
        expect(try buffer.readByte()) == 0x03
        expect(try buffer.readByte()) == 0x04
        buffer.rewind()
        expect(try buffer.readByte(bits: 8)) == 0x01
    }
    
    func testReadBits() throws {
        let data = Data([0b1011_0001, 0xFF])
        var buffer = ByteBuffer(data: data)
        
        expect(try buffer.readBool(bits: 1)) == true
        expect(try buffer.readBool(bits: 3)) == false
        expect(try buffer.readUInt32(bits: 2)) == 3
        expect(try buffer.readShort(bits: 2)) == 2
        expect(try buffer.readByte()) == 0xFF
    }
}
