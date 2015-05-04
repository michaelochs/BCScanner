# BCScanner

![version tag](https://img.shields.io/github/tag/michaelochs/bcscanner.svg?style=flat-square)
![release](https://img.shields.io/github/release/michaelochs/bcscanner.svg?style=flat-square)
![cocoapods version](https://img.shields.io/cocoapods/v/BCScanner.svg?style=flat-square)
![open issues](https://img.shields.io/github/issues/michaelochs/bcscanner.svg?style=flat-square)

![apache 2.0 license](https://img.shields.io/cocoapods/l/BCScanner.svg?style=flat-square)
![iOS platform](https://img.shields.io/cocoapods/p/BCScanner.svg?style=flat-square)

`BCScanner` is a barcode and qr code scanner library that makes use of the built in `AVFoundation` code scanning capabilities. It lets you easily integrate a barcode or qr code scanner into your application without dealing with `AVFoundation`.


## Requirements

`BCScanner` is bild for the use with iOS7+. If you still do support iOS6, make sure to check the `+[BCScanner scannerAvailable]` method before making any other calls to `BCScanner`. `BCScanner` is not compatible with iOS6 because of the internal use of new `AVFoundation` API.
`BCScanner` also requires you to use ARC.


## Dependencies

- UIKit
- AVFoundation
- QuartzCore


## Install

### cocoapods

The easiest way to install this module is to add the library through cocoapods:

    pod 'BCScanner'

If you want to specify a certain version of `BCScanner` please note that this project uses [semantic versioning](http://semver.org). This means it is safe to upgrade to every minor and patch release as this is fully backwards compatible. If you want to provide a version in your podfile, use this line:

    pod 'BCScanner', '~> 0.1'


### static library

If you, for some reason, do not want to directly integrate the project from the git repository, there is a [binary release in the release section on github](https://github.com/michaelochs/BCScanner/releases) for every version. This bundle includes a pre compiled library as well as a local `podspecs` file you can use to integrate the library locally.


### other integration

Currently, other types of integrations are not supported officially, however they are possible by simply using the library or the repository and adding `AVFoundation` as a dependency. Please also remember to add the `-ObjC` flag to your 'other linker flags' build settings.

See `BCScannerExample` target for a reference, if you have problems, linking the library.


## Example

To build the example project run `pod install` inside the `Example` folder and open up the `BCScanner.xcworkspace` file. Make sure you are using the workspace and not the project itself if you are experiencing issues.


## Contribution

If you are experiencing issues or have any question, please create an issue in the [issues section on github](https://github.com/michaelochs/BCScanner/issues). You can also reach me on twitter [@_mochs](https://twitter.com/_mochs) or check my blog at [ios-coding.com](http://ios-coding.com) for any how-to related questions.

Also feel free to open pull requests to improve the project. Thanks to everyone who has already done so in the past! For a list of contributors, please see the [CREDITS.md](https://github.com/michaelochs/BCScanner/blob/develop/CREDITS.md) file.


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
