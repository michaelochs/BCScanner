//
//  BCVideoPreviewView.h
//  BCScanner
//
//	Copyright 2013 bitecode, Michael Ochs
//
//	Licensed under the Apache License, Version 2.0 (the "License");
//	you may not use this file except in compliance with the License.
//	You may obtain a copy of the License at
//
//	http://www.apache.org/licenses/LICENSE-2.0
//
//	Unless required by applicable law or agreed to in writing, software
//	distributed under the License is distributed on an "AS IS" BASIS,
//	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//	See the License for the specific language governing permissions and
//	limitations under the License.
//

#import <UIKit/UIKit.h>


@import AVFoundation;


@interface BCVideoPreviewView : UIView

@property (nonatomic, strong, readwrite) AVCaptureSession *session;
@property (nonatomic, assign, readwrite) AVCaptureVideoOrientation videoOrientation;

- (BOOL)focusAtPoint:(CGPoint)point;
- (BOOL)exposeAtPoint:(CGPoint)point;

@end
