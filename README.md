# BCScanner

BCScanner is a barcode and qr code scanner library that makes use of the new iOS7 features build into AVFoundation. It lets you easily integrate a barcode or qr code scanner into your application without dealing with AVFoundation.

## Requirements

BCScanner is bild for the use with iOS7. If you still do support iOS6, make sure to check the `+[BCScanner scannerAvailable]` method bevore making any other calls to BCScanner. BCScanner is not compatible with iOS6 because of the internal use of new AVFoundation API.
BCScanner also requires you to use ARC.

## Dependencies

- UIKit
- AVFoundation
- QuartzCore

## Beta

BCScanner is beta. Some issues will get fixed within the next couple of weeks. Feel free to send pull requests. For a list of open issues, please have a look at the [issues section](https://github.com/michaelochs/BCScanner/issues) of this project.

## Install

Add the library through cocoapods. Currently you need to reference the git repository directly, this will change in the next release.

    pod 'BCScanner', :git => 'https://github.com/michaelochs/BCScanner.git'

See BCScannerExample target for a reference, if you have problems, linking the library.

### cocoapods

A public cocoapods release is coming with the 0.1.0 release in the next weeks.

### Example

To build the example project run `pod install` inside the `Example` folder.


## Licence

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.