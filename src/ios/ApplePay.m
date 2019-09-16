#import "ApplePay.h"
#import <PassKit/PassKit.h>
#import "NSStrinAdditions.h"
#import "NSData+Conversion.h"

static NSString *const responseAvailable = @"AVAILABLE";
static NSString *const responseNotAvailable = @"NOT_AVAILABLE";
static NSString *const responseConnected = @"CONNECTED";

static NSString *const paymentNetworkAmex = @"Amex";
static NSString *const paymentNetworkCartesBancaires = @"CartesBancaires";
static NSString *const paymentNetworkChinaUnionPay = @"ChinaUnionPay";
static NSString *const paymentNetworkDiscover = @"Discover";
static NSString *const paymentNetworkIDCredit = @"IDCredit";
static NSString *const paymentNetworkInterac = @"Interac";
static NSString *const paymentNetworkJCB = @"JCB";
static NSString *const paymentNetworkMasterCard = @"MasterCard";
static NSString *const paymentNetworkPrivateLabel = @"PrivateLabel";
static NSString *const paymentNetworkQUICPay = @"QUICPay";
static NSString *const paymentNetworkSuica = @"Suica";
static NSString *const paymentNetworkVisa = @"Visa";

@interface ApplePay()<PKAddPaymentPassViewControllerDelegate>

@end

@implementation ApplePay

- (void) canAddCard:(CDVInvokedUrlCommand*)command {
    __block CDVPluginResult* pluginResult;
    
    if ([PKPassLibrary isPassLibraryAvailable]) {
        NSString *primaryAccountIdentifier = [command.arguments objectAtIndex:0];
        PKPassLibrary* passLib = [[PKPassLibrary alloc] init];
        if ([PKAddPaymentPassViewController canAddPaymentPass] && [passLib canAddPaymentPassWithPrimaryAccountIdentifier:primaryAccountIdentifier]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:responseAvailable];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:responseNotAvailable];
        }
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:responseNotAvailable];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) bindCard:(CDVInvokedUrlCommand *)command {
    NSString *cardHolderName = [command.arguments objectAtIndex:0];
    NSString *primaryAccountSuffix = [command.arguments objectAtIndex:1];
    NSString *localizedDescription = [command.arguments objectAtIndex:2];
    NSString *primaryAccountIdentifier = [command.arguments objectAtIndex:3];
    NSString *paymentNetwork = [command.arguments objectAtIndex:4];
    cardId = [command.arguments objectAtIndex:5];
    
    PKAddPaymentPassRequestConfiguration *pkRequestConfig = [[PKAddPaymentPassRequestConfiguration alloc] initWithEncryptionScheme:PKEncryptionSchemeECC_V2];
    pkRequestConfig.cardholderName = cardHolderName;
    pkRequestConfig.primaryAccountSuffix = primaryAccountSuffix;
    pkRequestConfig.localizedDescription = localizedDescription;
    pkRequestConfig.primaryAccountIdentifier = primaryAccountIdentifier;
    pkRequestConfig.paymentNetwork = [self convertNSStringToPKPaymentNetwork:paymentNetwork];
    
    PKAddPaymentPassViewController *pkAddPaymentPassVC = [[PKAddPaymentPassViewController alloc] initWithRequestConfiguration:pkRequestConfig delegate:self];
    pkAddPaymentPassVC.delegate = self;
    [[self getTopMostViewController] presentViewController:pkAddPaymentPassVC animated:YES completion:nil];
}

- (UIViewController*) getTopMostViewController {
    UIViewController *presentingViewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
    while (presentingViewController.presentedViewController != nil) {
        presentingViewController = presentingViewController.presentedViewController;
    }
    return presentingViewController;
}
- (PKPaymentNetwork) convertNSStringToPKPaymentNetwork:(NSString *)paymentNetwork {
    if ([[paymentNetwork uppercaseString] isEqualToString: [paymentNetworkMasterCard uppercaseString]]) {
        return PKPaymentNetworkMasterCard;
    } else if ([[paymentNetwork uppercaseString] isEqualToString: [paymentNetworkVisa uppercaseString]]) {
        return PKPaymentNetworkVisa;
    } if ([[paymentNetwork uppercaseString] isEqualToString: [paymentNetworkChinaUnionPay uppercaseString]]) {
        return PKPaymentNetworkChinaUnionPay;
    } if ([[paymentNetwork uppercaseString] isEqualToString: [paymentNetworkAmex uppercaseString]]) {
        return PKPaymentNetworkAmex;
    } if ([[paymentNetwork uppercaseString] isEqualToString: [paymentNetworkDiscover uppercaseString]]) {
        return PKPaymentNetworkDiscover;
    } if ([[paymentNetwork uppercaseString] isEqualToString: [paymentNetworkIDCredit uppercaseString]]) {
        return PKPaymentNetworkIDCredit;
    } if ([[paymentNetwork uppercaseString] isEqualToString: [paymentNetworkInterac uppercaseString]]) {
        return PKPaymentNetworkInterac;
    } if ([[paymentNetwork uppercaseString] isEqualToString: [paymentNetworkJCB uppercaseString]]) {
        return PKPaymentNetworkJCB;
    } if ([[paymentNetwork uppercaseString] isEqualToString: [paymentNetworkPrivateLabel uppercaseString]]) {
        return PKPaymentNetworkPrivateLabel;
    } if ([[paymentNetwork uppercaseString] isEqualToString: [paymentNetworkQUICPay uppercaseString]]) {
        return PKPaymentNetworkQuicPay;
    } if ([[paymentNetwork uppercaseString] isEqualToString: [paymentNetworkSuica uppercaseString]]) {
        return PKPaymentNetworkSuica;
    } if ([[paymentNetwork uppercaseString] isEqualToString: [paymentNetworkCartesBancaires uppercaseString]]) {
        if (@available(iOS 11.2, *)) {
            return PKPaymentNetworkCartesBancaires;
        }
    }
    return nil;
}

- (void)redirectLogToDocuments
{
    NSArray *allPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [allPaths objectAtIndex:0];
    NSString *pathForLog = [documentsDirectory stringByAppendingPathComponent:@"yourFile.txt"];
    
    freopen([pathForLog cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

-(void)showMessage:(NSString*)message withTitle:(NSString *)title{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:^{
        }];
    });
}

#pragma mark - PKAddPaymentPassViewControllerDelegate

-(void)addPaymentPassViewController:(PKAddPaymentPassViewController *)controller
generateRequestWithCertificateChain:(NSArray<NSData *> *)certificates
                              nonce:(NSData *)nonce
                     nonceSignature:(NSData *)nonceSignature
                  completionHandler:(void (^)(PKAddPaymentPassRequest *addRequest))handler {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://bank.ru/rest/pkAddPaymentPassRequest"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *nonceForReq = [nonce hexadecimalString];
    NSString *nonceSignatureForReq = [nonceSignature hexadecimalString];
    
    NSMutableArray *certsForReq = [NSMutableArray array];
    for (int i=0; i<[certificates count]; i++) {
        NSString *cert = [NSString base64StringFromData:certificates[i] length:[certificates[i] length]];
        [certsForReq addObject:cert];
    }
    
    NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:
                         nonceForReq, @"nonce",
                         nonceSignatureForReq, @"noncesignature",
                         certsForReq, @"certificate",
                         cardId, @"cardId",
                         nil];
    
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      if (data != nil) {
                                          id object = [NSJSONSerialization
                                                       JSONObjectWithData:data
                                                       options:0
                                                       error:&error];
                                          if ([object isKindOfClass:[NSDictionary class]]) {
                                              NSString *ephemeralPublicKey = [object valueForKey:@"ephemeralPublicKey"];
                                              NSString *activationData = [object valueForKey:@"activationData"];
                                              NSString *encryptedPassData = [object valueForKey:@"encryptedPassData"];
                                              
                                              PKAddPaymentPassRequest *addRequest = [[PKAddPaymentPassRequest alloc] init];
                                              addRequest.activationData = [[NSData alloc] initWithBase64EncodedString:activationData options:0];
                                              addRequest.encryptedPassData = [[NSData alloc] initWithBase64EncodedString:encryptedPassData options:0];
                                              addRequest.ephemeralPublicKey = [[NSData alloc] initWithBase64EncodedString:ephemeralPublicKey options:0];
                                              
                                              handler(addRequest);
                                              
                                          }}
                                  }
                                  ];
    [task resume];
};

- (void)addPaymentPassViewController:(PKAddPaymentPassViewController *)controller
          didFinishAddingPaymentPass:(PKPaymentPass *)pass error:(NSError *)error {
    NSLog(@"delegate fail: receive cert and sensitive data from server");
    if (pass) {
        [controller dismissViewControllerAnimated:true completion:^{
            NSLog(@"adding payment pass success, and complete dismissing addPaymentPassConroller. Now, what to do ?");
        }];
    }  else {
        if (error.code == PKAddPaymentPassErrorUnsupported) {
            [controller dismissViewControllerAnimated:true completion:^{
                NSLog(@"PKAddPaymentPassErrorUnsupported");
            }];
        } else if (error.code == PKAddPaymentPassErrorUserCancelled) {
            [controller dismissViewControllerAnimated:true completion:^{
                NSLog(@"PKAddPaymentPassErrorUserCancelled");
            }];
        } else if (error.code == PKAddPaymentPassErrorSystemCancelled) {
            [controller dismissViewControllerAnimated:true completion:^{
                NSLog(@"PKAddPaymentPassErrorSystemCancelled");
            }];
        } else {
            [controller dismissViewControllerAnimated:true completion:^{
                NSLog(@"PKAddPaymentPassErrorSystemCancelled");
            }];
        }
    }
}
@end

