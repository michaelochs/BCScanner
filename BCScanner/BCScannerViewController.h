//
//  BCScannerViewController.h
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

#import <UIKit/UIKit.h>


extern NSString *const BCScannerQRCode; /// The code type used for QR codes.
extern NSString *const BCScannerUPCECode;

//extern NSString *const BCScannerCode39Code;
//extern NSString *const BCScannerCode39Mod43Code;

extern NSString *const BCScannerEAN13Code;
extern NSString *const BCScannerEAN8Code;

//extern NSString *const BCScannerCode93Code;
//extern NSString *const BCScannerCode128Code;
//extern NSString *const BCScannerPDF417Code;
//extern NSString *const BCScannerAztecCode;




@protocol BCScannerViewControllerDelegate;


/**
 BCScannerViewController is a view controller that wrapps the scanning
 capabilities of iOS7 into a simple to use drop-in view controller for easy
 integration into your app.
 
 It is build for the purpose of scanning a single or multiple codes in a
 deticated screen and encapsules all the camera handling and metadata gathering.
 
 The view controller can be presented or pushed onto a navigation stack. It is
 up to you to present and dismiss the view controller whenever you need it.
*/
@interface BCScannerViewController : UIViewController

/**
 This method lets you check for the availability of the native scanner
 functionality provided by AVFoundation.

 @note Do not instanciate this class if this method returns NO!

 @return YES if native scanning is available, NO otherwise.
 */
+ (BOOL)scannerAvailable;

/**
 This is the delegate of the scanner. The delegate will get called to notify you
 about codes that were found in the field of view of the camera.
 */
@property (nonatomic, weak, readwrite) id<BCScannerViewControllerDelegate> delegate;

/**
 This is an array of the codes the scanner should look for. The more code types
 you specify, the longer the image analysis will take!

 @see BCScannerCode constants
 */
@property (nonatomic, strong, readwrite) NSArray *codeTypes;

/**
 This is the gesture recognizer that is used to let the user focus and expose to
 a specific point in the field of view. You can access this property when you
 want to more precisely control what taps should be recognized.
 */
@property (nonatomic, weak, readonly) UITapGestureRecognizer *focusAndExposeGestureRecognizer;

/**
 Defines the rect of the view controller's view that describes the active area
 that is used by `AVFoundation` to scan for barcodes.
 
 The default value is `CGRectZero` which turns this feature off and always uses
 the whole camera input as a capturing area.

 @note all codes that are completely visible by the active camera and intersect
       with the specified area are scanned. The code does not need to be
       completely inside the scanner area.
 */
@property (nonatomic, assign, readwrite) CGRect scannerArea;



#pragma mark - torch

/**
 Defines the video preview torch mode.
 */
@property (nonatomic, assign, readwrite, getter = isTorchEnabled) BOOL torchEnabled;

/**
 Hides or displays the torch button in the navigation bar.
 
 The default value is YES.
 */
@property (nonatomic, assign, readwrite, getter = isTorchButtonEnabled) BOOL torchButtonEnabled;

/**
 Indicates if the torch mode is available. Varies depending on the device.
 */
@property (nonatomic, assign, readonly, getter = isTorchModeAvailable) BOOL torchModeAvailable;

@end


@protocol BCScannerViewControllerDelegate <NSObject>

@optional
/**
 This method is called whenever a new code enters the field of view.

 @param	scanner	The scanner that is calling this delegate
 @param	codes	A list of all the codes that entered the FOV in this interval

 @note	If you do a simple scan for the first code you find, you can get the
        code from this method and close the scanner afterwards.
 */
- (void)scanner:(BCScannerViewController *)scanner codesDidEnterFOV:(NSSet *)codes;

//- (void)scanner:(BCScannerViewController *)scanner codesDidUpdate:(NSSet *)codes;

/**
 This method is called whenever an existing code leaves the field of view.

 @param	scanner	The scanner that is calling this delegate
 @param	codes	A list of all the codes that left the FOV in this interval
 */
- (void)scanner:(BCScannerViewController *)scanner codesDidLeaveFOV:(NSSet *)codes;

/**
 This method lets you specify an image that is shown as an overlay to give the
 user some feedback about how to hold the camera.

 This method is called when the scanner configures its interface.

 @param scanner	The scanner that is calling this delegate
 
 @return The image you want to be used as HUD
 */
- (UIImage *)scannerHUDImage:(BCScannerViewController *)scanner;

@end
