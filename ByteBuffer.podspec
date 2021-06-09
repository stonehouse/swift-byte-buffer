#
#  Be sure to run `pod spec lint ByteBuffer.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "ByteBuffer"
  s.version      = "1.0.0"
  s.summary      = "Swift implemenation of a Byte Buffer, includes support for Bit Fields."

  s.license      = { :type => 'Proprietary', :file => 'LICENSE' }
  s.homepage	 = "https://github.com/LIFX/swift-byte-buffer"
  s.author       = { "Alex Stonehouse" => "alexander@lifx.co" }
  s.source       = { :git => "https://github.com/LIFX/swift-byte-buffer.git", :branch => "main" }

  # Version
  s.platform = :ios
  s.swift_version = "5.0"
  s.ios.deployment_target = "10.3"

  s.source_files  = "Sources/ByteBuffer/**/*"

end
