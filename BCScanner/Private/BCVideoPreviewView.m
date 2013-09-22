//
//  BCVideoPreviewView.m
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

#import "BCVideoPreviewView.h"


@interface BCVideoPreviewView ()

@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *previewLayer;

@end


@implementation BCVideoPreviewView

@dynamic session;
@dynamic previewLayer;
@dynamic videoOrientation;

+ (Class)layerClass
{
	return [AVCaptureVideoPreviewLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self configureLayer];
	}
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self configureLayer];
}

- (void)configureLayer
{
	self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
	return (AVCaptureVideoPreviewLayer *)self.layer;
}



#pragma mark - camera handling

- (AVCaptureDevice *)captureDevice
{
	NSArray *inputPorts = [self.previewLayer.connection inputPorts];
	for (AVCaptureInputPort *port in inputPorts) {
		if ([[port mediaType] isEqualToString:AVMediaTypeVideo]) {
			AVCaptureInput *input = [port input];
			if ([input isKindOfClass:[AVCaptureDeviceInput class]]) {
				AVCaptureDevice *device = [(AVCaptureDeviceInput *)input device];
				return device;
			}
		}
	}
	return nil;
}

- (BOOL)focusAtPoint:(CGPoint)point
{
	CGPoint convertedPoint = [self.previewLayer captureDevicePointOfInterestForPoint:point];
	
	AVCaptureDevice* videoDevice = [self captureDevice];
	if ([videoDevice isFocusPointOfInterestSupported] && [videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
		NSError* configurationError = nil;
		if ([videoDevice lockForConfiguration:&configurationError]) {
			[videoDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
			[videoDevice setFocusPointOfInterest:convertedPoint];
			[videoDevice unlockForConfiguration];
			return YES;
			
		} else {
			NSLog(@"[BCScanner] Can not configure focus for input device: %@", configurationError);
			return NO;
		}
		
	} else {
		return NO;
	}
}

- (BOOL)exposeAtPoint:(CGPoint)point
{
	CGPoint convertedPoint = [self.previewLayer captureDevicePointOfInterestForPoint:point];
	
	AVCaptureDevice* videoDevice = [self captureDevice];
	if ([videoDevice isExposurePointOfInterestSupported] && [videoDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
		NSError* configurationError = nil;
		if ([videoDevice lockForConfiguration:&configurationError]) {
			[videoDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
			[videoDevice setExposurePointOfInterest:convertedPoint];
			[videoDevice unlockForConfiguration];
			return YES;
			
		} else {
			NSLog(@"[BCScanner] Can not configure exposure for input device: %@", configurationError);
			return NO;
		}
		
	} else {
		return NO;
	}
}



#pragma mark - accessors

- (void)setSession:(AVCaptureSession *)session
{
	[self.previewLayer setSession:session];
}

- (AVCaptureSession *)session
{
	return [self.previewLayer session];
}

- (void)setVideoOrientation:(AVCaptureVideoOrientation)videoOrientation
{
	if ([self.previewLayer.connection isVideoOrientationSupported]) {
		self.previewLayer.connection.videoOrientation = videoOrientation;
	}
}

- (AVCaptureVideoOrientation)videoOrientation
{
	if ([self.previewLayer.connection isVideoOrientationSupported]) {
		return self.previewLayer.connection.videoOrientation;
	} else {
		return 0;
	}
}

@end
