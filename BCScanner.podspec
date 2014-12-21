Pod::Spec.new do |s|
  s.name         = "BCScanner"
  s.version      = "0.1.0"
  s.summary      = "A barcode and qr code scanner that wraps the `AVFoundation` scanning capabilities in a `UIViewController`"
  s.homepage     = "https://github.com/michaelochs/BCScanner"
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = 'Michael Ochs, @_mochs'
  s.platform     = :ios, '8.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true
  s.framework    = 'AVFoundation', 'UIKit'
  s.source       = { :git => "https://github.com/michaelochs/BCScanner.git", :tag => s.version.to_s }
  s.source_files = 'BCScanner', 'BCScanner/**/*.{h,m}'
  s.public_header_files = 'BCScanner/*.h'
  s.preserve_path = 'LICENSE', 'VERSION', 'CREDITS.md'
end
