# BCScanner

BCScanner is a barcode and qr code scanner library that makes use of the new iOS7 features build into AVFoundation. It lets you easily integrate a barcode or qr code scanner into your application without dealing with AVFoundation.

## Requirements

BCScanner is bild for the use with iOS7. If you still do support iOS6, make sure to check the +[BCScanner scannerAvailable] method bevore making any other calls to BCScanner. BCScanner is not compatible with iOS6 because of the internal use of new AVFoundation API.
BCScanner also requires you to use ARC.

## Dependencies

- UIKit
- AVFoundation
- QuartzCore

## Beta

BCScanner is beta. Some issues will get fixed within the next couple of weeks. Feel free to send pull requests. The open TODOs are:
- When using multiple codes together with a hud immage the animation will break when relayouting the screen (e.g. when rotating).
- There should be a block based API for those use cases where only scanning one barcode is required.
- As this is beta, there might be changes in the API that may break the current API.
- Not all supported code types of AVFoundation are added to BCScanner yet. Currently supported types are: QR, UPCE, EAN8 and EAN13.
- There are no unit tests at the moment.

## Install

Add the BCScanner project to your project.
Set the header search path to "$(BUILT_PRODUCTS_DIR)/../../Headers". (Including the quotes!)
Add BCScanner as a target dependency and in the linker phase.
Make sure to set the -ObjC linker flag in your build settings.
See BCScannerExample target for a reference, if you have problems, linking the library.

## Licence

Copyright 2013 bitecode, Michael Ochs

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.