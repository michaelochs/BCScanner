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


@class BCScannerViewController;


@interface UIViewController (BCScanner)

/**
 Present a scanner view controller.
 
 The scanner is dismissed as soon as the first code of one of the desired types
 is found.
 
 @note The completionHandler is only called if a code is found. If the user
       cancelled the scanner, no completion handler is called!
 
 @param codeTypes         An array of all code types that should be scanned for
 @param completionHandler The completion handler that is called when a code is
                          found
 
 @return The created view controller. You can configure this view controller.
 */
- (BCScannerViewController *)bcscanner_presentScannerWithCodeTypes:(NSArray *)codeTypes completionHandler:(void(^)(NSString *code))completionHandler;

@end
