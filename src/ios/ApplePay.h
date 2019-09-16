#import <Cordova/CDVPlugin.h>
#import "NSStrinAdditions.h"

NSString *cardId = @"";

@interface ViewController : UIViewController <UIPageViewControllerDelegate>
@end

@interface ApplePay: CDVPlugin

- (void) canAddCard:(CDVInvokedUrlCommand*) command;
- (void) bindCard:(CDVInvokedUrlCommand*) command;

@end
