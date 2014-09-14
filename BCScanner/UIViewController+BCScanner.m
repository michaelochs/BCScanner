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

#import "UIViewController+BCScanner.h"

#import <objc/runtime.h>

#import "BCScannerViewController.h"
#import "BCScannerDelegate.h"


static void *const BCScannerDelegateContext = (void *)&BCScannerDelegateContext;


@implementation UIViewController (BCScanner)

- (BCScannerViewController *)bcscanner_presentScannerWithCodeTypes:(NSArray *)codeTypes completionHandler:(void(^)(NSString *code))completionHandler
{
	if (![BCScannerViewController scannerAvailable]) {
		return nil;
	}
	
	BCScannerDelegate *delegate = [BCScannerDelegate delegateWithCompletionHandler:completionHandler];
	
	BCScannerViewController *viewController = [BCScannerViewController new];
	viewController.delegate = delegate;
	viewController.codeTypes = codeTypes;
	viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(bcscanner_dismissScannerViewController:)];
	
	objc_setAssociatedObject(viewController, BCScannerDelegateContext, delegate, OBJC_ASSOCIATION_RETAIN);
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self presentViewController:navigationController animated:YES completion:NULL];
	
	return viewController;
}

- (IBAction)bcscanner_dismissScannerViewController:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end
