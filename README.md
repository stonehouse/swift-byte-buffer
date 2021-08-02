# Swift Byte Buffer

This framework provides a Swift implementation of 'ByteBuffer' which provides various tools for reading binary data. This includes support for bit fields.

## Usage
ByteBuffer is a struct and reading/writing data mutates the internal state so it needs to be a ```var```.

#### Reading Data

```swift
var buffer = ByteBuffer(data: data)

let bitField = try buffer.readBool(bits: 1)
let field2 = try buffer.readByte(bits: 3)
let field3 = try buffer.readByte(bits: 4)
let field4 = try buffer.readUInt64()
```

Calling ```rewind()``` resets the read position and allows you to start reading from the beginning of the buffer.

#### Writing Data
Data can be written as whole bytes or other data types written into bit increments. The resulting ```Data``` can be read out and easily converted to hex.

```swift
var buffer = ByteBuffer()
buffer.write(bytes: [0x01, 0x02, 0x03, 0x04])
buffer.write(short: 312, bits: 9)
buffer.write(byte: 128, bits: 7)
buffer.data.hexEncodedString()
```

## Helpers
There are some extensions on ```Data``` to make working with hex data easier. See ```Data(hexEncoded:)``` and ```Data.hexEncodedString```.
