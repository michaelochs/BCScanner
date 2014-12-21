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

#import <Foundation/Foundation.h>

#import "BCScannerViewController.h"


@interface BCScannerDelegate : NSObject <BCScannerViewControllerDelegate>

@property (nonatomic, copy, readonly) void(^completionHandler)(NSString *code);

@property (nonatomic, strong, readwrite) UIImage *hudImage;

/**
 Initializes a new delegate object that call the completion handler when a
 scanner view controller finds the first code.
 
 @param completionHandler called when a code was found
 
 @return The configured instance of the scanner delegate
 */
+ (instancetype)delegateWithCompletionHandler:(void(^)(NSString *code))completionHandler;

@end
