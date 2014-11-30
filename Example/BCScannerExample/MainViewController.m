//
//  MainViewController.m
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

#import "MainViewController.h"

#import <BCScanner/BCScanner.h>


@interface MainViewController () <BCScannerViewControllerDelegate>

@end


@implementation MainViewController

- (IBAction)openScanner:(id)sender
{
	if ([BCScannerViewController scannerAvailable]) {
		BCScannerViewController *scanner = [[BCScannerViewController alloc] init];
		scanner.delegate = self;
		scanner.codeTypes = @[ BCScannerQRCode, BCScannerEAN8Code, BCScannerEAN13Code, BCScannerUPCECode ];
		scanner.torchButtonEnabled = YES;
		[self.navigationController pushViewController:scanner animated:YES];
	}
}

- (IBAction)openScannerBlockBased:(id)sender
{
	[self bcscanner_presentScannerWithCodeTypes:@[ BCScannerQRCode, BCScannerI25Code ] hudImage:[UIImage imageNamed:@"HUD"] completionHandler:^(NSString *code) {
		NSLog(@"Found: [%@]", code);
	}];
}



#pragma mark - BCScannerViewControllerDelegate

- (void)scanner:(BCScannerViewController *)scanner codesDidEnterFOV:(NSSet *)codes
{
	NSLog(@"Added: [%@]", codes);
}

//- (void)scanner:(BCScannerViewController *)scanner codesDidUpdate:(NSSet *)codes
//{
//	NSLog(@"Updated: [%lu]", (unsigned long)codes.count);
//}

- (void)scanner:(BCScannerViewController *)scanner codesDidLeaveFOV:(NSSet *)codes
{
	NSLog(@"Deleted: [%@]", codes);
}

- (UIImage *)scannerHUDImage:(BCScannerViewController *)scanner
{
	return [UIImage imageNamed:@"HUD"];
}

@end
