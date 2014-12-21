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

#import "BCScannerDelegate.h"


@interface BCScannerDelegate ()

@property (nonatomic, copy, readwrite) void(^completionHandler)(NSString *code);

@end


@implementation BCScannerDelegate

+ (instancetype)delegateWithCompletionHandler:(void(^)(NSString *code))completionHandler
{
	return [[self alloc] initWithCompletionHandler:completionHandler];
}

- (instancetype)initWithCompletionHandler:(void(^)(NSString *code))completionHandler
{
	self = [super init];
	if (self) {
		_completionHandler = completionHandler;
	}
	return self;
}

- (void)scanner:(BCScannerViewController *)scanner codesDidEnterFOV:(NSSet *)codes
{
	if (self.completionHandler) {
		self.completionHandler([codes anyObject]);
		self.completionHandler = nil; // make sure this is only called once!
	}
	[scanner dismissViewControllerAnimated:YES completion:NULL];
}

- (UIImage *)scannerHUDImage:(BCScannerViewController *)scanner {
	return self.hudImage;
}

@end
