//
//  BCScannerViewController.m
//  BCScannerViewController
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

#import "BCScannerViewController.h"

#import "BCVideoPreviewView.h"

@import AVFoundation;


NSString *const BCScannerQRCode = @"BCScannerQRCode";
NSString *const BCScannerUPCECode = @"BCScannerUPCECode";
NSString *const BCScannerI25Code = @"BCScannerI25Code";

//NSString *const BCScannerCode39Code = @"BCScannerCode39Code";
//NSString *const BCScannerCode39Mod43Code = @"BCScannerCode39Mod43Code";

NSString *const BCScannerEAN13Code = @"BCScannerEAN13Code";
NSString *const BCScannerEAN8Code = @"BCScannerEAN8Code";

//NSString *const BCScannerCode93Code = @"BCScannerCode93Code";
//NSString *const BCScannerCode128Code = @"BCScannerCode128Code";
//NSString *const BCScannerPDF417Code = @"BCScannerPDF417Code";
//NSString *const BCScannerAztecCode = @"BCScannerAztecCode";


@interface BCScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, weak, readwrite) UITapGestureRecognizer *focusAndExposeGestureRecognizer;

@property (nonatomic, strong, readwrite) NSSet *codesInFOV;
@property (nonatomic, weak, readwrite) UIImageView *hudImageView;

@property (nonatomic, strong, readwrite) AVCaptureSession *session;
@property (nonatomic, weak, readonly) BCVideoPreviewView *previewView;
@property (nonatomic, weak, readwrite) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong, readwrite) dispatch_queue_t metadataQueue;

@property (nonatomic, strong) UIBarButtonItem *torchButton;

@end


static inline CGRect HUDRect(CGRect bounds, UIEdgeInsets padding, CGFloat aspectRatio)
{
	CGRect frame = UIEdgeInsetsInsetRect(bounds, padding);
	
	CGFloat frameAspectRatio = CGRectGetWidth(frame) / CGRectGetHeight(frame);
	CGRect hudRect = frame;
	
	if (aspectRatio > frameAspectRatio) {
		hudRect.size.height = CGRectGetHeight(frame) / aspectRatio;
		hudRect.origin.y += (CGRectGetHeight(frame) - CGRectGetHeight(hudRect)) * .5f;
	} else {
		hudRect.size.width = CGRectGetHeight(frame) * aspectRatio;
		hudRect.origin.x += (CGRectGetWidth(frame) - CGRectGetWidth(hudRect)) * .5f;
	}
	
	return CGRectIntegral(hudRect);

}


@implementation BCScannerViewController

@dynamic previewView;


+ (BOOL)scannerAvailable
{
	return ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending);
}



#pragma mark - code parameters

+ (NSNumber *)aspectRatioForCode:(NSString *)code
{
	static NSMutableDictionary *aspectRatios = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        aspectRatios =  [NSMutableDictionary
                         dictionaryWithDictionary:@{
                          BCScannerQRCode: @1,
						  BCScannerEAN8Code: @1.1833333333,
						  BCScannerEAN13Code: @1.4198113208,
                          BCScannerUPCECode: @0.8538812785 }]; // horizontal
        // add AVMetadataObjectTypeInterleaved2of5Code if iOS8+
        if(&AVMetadataObjectTypeInterleaved2of5Code){
            [aspectRatios setObject:@1.5 forKey:BCScannerI25Code];
        }
	});
	return aspectRatios[code];
}

+ (NSString *)metadataObjectTypeFromScannerCode:(NSString *)code
{
	static NSMutableDictionary *objectTypes = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        
        objectTypes = [NSMutableDictionary
                       dictionaryWithDictionary:@{
                         BCScannerQRCode: AVMetadataObjectTypeQRCode,
						 BCScannerEAN8Code: AVMetadataObjectTypeEAN8Code,
						 BCScannerEAN13Code: AVMetadataObjectTypeEAN13Code,
                         BCScannerUPCECode: AVMetadataObjectTypeUPCECode,
                         BCScannerI25Code: AVMetadataObjectTypeInterleaved2of5Code }];
        // add AVMetadataObjectTypeInterleaved2of5Code if iOS8+
        if(&AVMetadataObjectTypeInterleaved2of5Code){
            [objectTypes setObject:AVMetadataObjectTypeInterleaved2of5Code forKey:BCScannerI25Code];
        }
        
	});
	return objectTypes[code];
}

+ (NSArray *)metadataObjectTypesFromScannerCodes:(NSArray *)codes
{
	NSMutableArray *objectTypes = [NSMutableArray arrayWithCapacity:codes.count];
	for (NSString *code in codes) {
		NSString *objectType = [self metadataObjectTypeFromScannerCode:code];
		if (objectType) {
			[objectTypes addObject:objectType];
		}
	}
	return [objectTypes copy];
}



#pragma mark - object

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		_codesInFOV = [NSSet set];
		_scannerArea = CGRectZero;
		[self configureCaptureSession];
		[self updateMetaData];
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		_codesInFOV = [NSSet set];
		_scannerArea = CGRectZero;
		[self configureCaptureSession];
		[self updateMetaData];
	}
	return self;
}

- (void)dealloc
{
	[self teardownCaptureSession];
}

- (void)updateMetaData
{
	BOOL isVisible = self.isViewLoaded && self.view.window;
	if (self.isTorchButtonEnabled) {
		UIBarButtonItem *torchToggle = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"bcscanner_torch", nil, [NSBundle mainBundle], @"Torch", @"The title of the torch mode button") style:UIBarButtonItemStyleBordered target:self action:@selector(toggleTorch:)];
		[self.navigationItem setRightBarButtonItem:torchToggle animated:isVisible];
	} else {
		[self.navigationItem setRightBarButtonItem:nil animated:isVisible];
	}
}



#pragma mark - Capture Session

- (void)configureCaptureSession
{
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
	
	NSError *inputError = nil;
	AVCaptureDevice *camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&inputError];
	if (cameraInput) {
		if ([session canAddInput:cameraInput]) {
			[session addInput:cameraInput];
		} else {
			NSLog(@"[BCScanner] could not add capture device!");
		}
	} else {
		NSLog(@"[BCScanner] could not create capture device: %@", inputError);
	}
	
	AVCaptureMetadataOutput *metadata = [[AVCaptureMetadataOutput alloc] init];
	if ([session canAddOutput:metadata]) {
		dispatch_queue_t metadataQueue = dispatch_queue_create("org.bitecode.BCScanner.metadata", NULL);
		[metadata setMetadataObjectsDelegate:self queue:metadataQueue];
		[session addOutput:metadata];
		_metadataOutput = metadata;
		_metadataQueue = metadataQueue;
	} else {
		NSLog(@"[BCScanner] could not create metadata output!");
	}
	
	_session = session;
}

- (void)teardownCaptureSession
{
	[_session stopRunning];
	_session = nil;
	_metadataOutput = nil;
	_metadataQueue = NULL;
}



#pragma mark - view handling

- (void)loadView
{
	self.view = [BCVideoPreviewView new];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.previewView.session = self.session;
	
    if ([self.delegate respondsToSelector:@selector(scannerHUDImage:)])
    {
        UIImage *hudImage = [self.delegate scannerHUDImage:self];
        if (hudImage) {
            UIImageView *hudImageView = [[UIImageView alloc] initWithImage:hudImage];
            hudImageView.contentMode = UIViewContentModeScaleToFill;
            [self.previewView addSubview:hudImageView];
            _hudImageView = hudImageView;
        }
    }
    
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusAndExpose:)];
	[self.previewView addGestureRecognizer:tapRecognizer];
	self.focusAndExposeGestureRecognizer = tapRecognizer;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.session startRunning];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[self.session stopRunning];
	
	[super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	[self layoutHUD];
	[self updateRectOfInterest];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	self.previewView.videoOrientation = (AVCaptureVideoOrientation)toInterfaceOrientation; // The enum defs for UIInterfaceOrientation and AVCaptureVideoOrientation are the same!
}

- (void)layoutHUD
{
	UIEdgeInsets padding = UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f);
	CGRect bounds = self.previewView.bounds;
	bounds.origin.y += self.topLayoutGuide.length;
	bounds.size.height -= self.topLayoutGuide.length + self.bottomLayoutGuide.length;
	if (CGRectGetHeight(bounds) > CGRectGetWidth(bounds)) {
		bounds.origin.y += (CGRectGetHeight(bounds) - CGRectGetWidth(bounds)) * .5f;
		bounds.size.height = CGRectGetWidth(bounds);
	} else {
		bounds.origin.x += (CGRectGetWidth(bounds) - CGRectGetHeight(bounds)) * .5f;
		bounds.size.width = CGRectGetHeight(bounds);
	}
	
	self.hudImageView.hidden = (self.codeTypes.count == 0);
	
	if (self.codeTypes.count > 0) {
		NSNumber *aspectRatio = [[self class] aspectRatioForCode:[self.codeTypes lastObject]];
#if defined(CGFLOAT_IS_DOUBLE) && (CGFLOAT_IS_DOUBLE > 0)
		CGFloat rawAspectRatio = [aspectRatio doubleValue];
#else
		CGFloat rawAspectRatio = [aspectRatio floatValue];
#endif
		[UIView performWithoutAnimation:^{
			self.hudImageView.frame = HUDRect(bounds, padding, rawAspectRatio);
		}];
	}
	
	if (self.codeTypes.count > 1) {
		NSUInteger count = self.codeTypes.count;
		[UIView animateKeyframesWithDuration:1.0*count delay:0.0f options:(UIViewKeyframeAnimationOptionOverrideInheritedOptions | UIViewKeyframeAnimationOptionCalculationModePaced | UIViewKeyframeAnimationOptionRepeat) animations:^{
			[self.codeTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSNumber *aspectRatio = [[self class] aspectRatioForCode:obj];
#if defined(CGFLOAT_IS_DOUBLE) && (CGFLOAT_IS_DOUBLE > 0)
				CGFloat rawAspectRatio = [aspectRatio doubleValue];
#else
				CGFloat rawAspectRatio = [aspectRatio floatValue];
#endif
				CGRect frame = HUDRect(bounds, padding, rawAspectRatio);
				[UIView addKeyframeWithRelativeStartTime:idx/(double)count relativeDuration:1/(double)count animations:^{
					self.hudImageView.frame = frame;
				}];
			}];
			
		} completion:NULL];
	}
}

- (void)updateRectOfInterest
{
	if (CGRectEqualToRect(self.scannerArea, CGRectZero)) {
		self.metadataOutput.rectOfInterest = CGRectMake(0.0, 0.0, 1.0, 1.0);
		return;
	}
	CGRect rectOfInterest = (CGRect){
		.origin = {
			.x = CGRectGetMinX(self.scannerArea) / CGRectGetWidth(self.view.bounds),
			.y = CGRectGetMinY(self.scannerArea) / CGRectGetHeight(self.view.bounds)
		},
		.size = {
			.width = CGRectGetWidth(self.scannerArea) / CGRectGetWidth(self.view.bounds),
			.height = CGRectGetHeight(self.scannerArea) / CGRectGetHeight(self.view.bounds)
		}
	};
	
	self.metadataOutput.rectOfInterest = rectOfInterest;
}



#pragma mark - actions

- (IBAction)focusAndExpose:(id)sender
{
	if (sender == self.focusAndExposeGestureRecognizer) {
		CGPoint location = [self.focusAndExposeGestureRecognizer locationInView:self.previewView];
		[self.previewView focusAtPoint:location];
		[self.previewView exposeAtPoint:location];
	}
}

- (IBAction)toggleTorch:(UIBarButtonItem *)sender
{
	self.torchEnabled = (self.isTorchModeAvailable && !self.isTorchEnabled);
}



#pragma mark - torch mode

@synthesize torchEnabled = _torchEnabled;

- (void)setTorchEnabled:(BOOL)torchEnabled
{
    _torchEnabled = torchEnabled;
	if (self.isTorchModeAvailable)
	{
		self.previewView.torchMode = (torchEnabled ? AVCaptureTorchModeOn : AVCaptureTorchModeOff);
	}
}

- (BOOL)isTorchEnabled {
	return _torchEnabled && self.isTorchModeAvailable;
}

- (void)setTorchButtonEnabled:(BOOL)torchButtonEnabled
{
    _torchButtonEnabled = torchButtonEnabled;
	[self updateMetaData];
}



#pragma mark - capturing

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
	NSSet *objectsStillLiving = [NSSet setWithArray:[metadataObjects valueForKeyPath:@"@distinctUnionOfObjects.stringValue"]];
	
	NSMutableSet *objectsAdded = [NSMutableSet setWithSet:objectsStillLiving];
	[objectsAdded minusSet:self.codesInFOV];
	
//	NSMutableSet *objectsUpdated = [NSMutableSet setWithSet:objectsStillLiving];
//	[objectsUpdated intersectSet:self.codesInFOV];
	
	NSMutableSet *objectsMissing = [NSMutableSet setWithSet:self.codesInFOV];
	[objectsMissing minusSet:objectsStillLiving];
	
	self.codesInFOV = objectsStillLiving;
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		if (objectsAdded.count > 0 && [self.delegate respondsToSelector:@selector(scanner:codesDidEnterFOV:)]) {
			[self.delegate scanner:self codesDidEnterFOV:[objectsAdded copy]];
		}
//		if (objectsUpdated.count > 0 && [self.delegate respondsToSelector:@selector(scanner:codesDidUpdate:)]) {
//			[self.delegate scanner:self codesDidUpdate:[objectsUpdated copy]];
//		}
		if (objectsMissing.count > 0 && [self.delegate respondsToSelector:@selector(scanner:codesDidLeaveFOV:)]) {
			[self.delegate scanner:self codesDidLeaveFOV:[objectsMissing copy]];
		}
	});
}



#pragma mark - accessors

- (void)setScannerArea:(CGRect)scannerArea
{
	_scannerArea = scannerArea;
	if (self.isViewLoaded) {
		[self updateRectOfInterest];
	}
}

- (BOOL)isTorchModeAvailable
{
	return self.previewView.isTorchModeAvailable;
}

- (BCVideoPreviewView *)previewView
{
	if (self.isViewLoaded) {
		return (BCVideoPreviewView *)self.view;
	} else {
		return nil;
	}
}

- (void)setCodeTypes:(NSArray *)codes
{
	_codeTypes = codes;
	NSArray *metadataObjectTypes = [[self class] metadataObjectTypesFromScannerCodes:codes];
	[self.metadataOutput setMetadataObjectTypes:metadataObjectTypes];
	if (self.isViewLoaded) {
		[self layoutHUD];
	}
}

@end
