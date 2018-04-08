//
//  InAppPurchasesHelper.m
//  SimulatedElon
//
//  Created by Si Te Feng on 4/1/18.
//  Copyright © 2018 Si Te Feng. All rights reserved.
//

#import "InAppPurchasesHelper.h"

@implementation InAppPurchasesHelper

+ (BOOL)checkInAppPurchaseStatus
{
    // Load the receipt from the app bundle.
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
    if (receipt) {
        BOOL sandbox = [[receiptURL lastPathComponent] isEqualToString:@"sandboxReceipt"];
        // Create the JSON object that describes the request
        NSError *error;
        NSDictionary *requestContents = @{
                                          @"receipt-data": [receipt base64EncodedStringWithOptions:0],@"password":@"SHARE_SECRET_CODE"
                                          };
        NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents
                                                              options:0
                                                                error:&error];
        
        if (requestData) {
            // Create a POST request with the receipt data.
            NSURL *storeURL = [NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"];
            if (sandbox) {
                storeURL = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
            }
            NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
            [storeRequest setHTTPMethod:@"POST"];
            [storeRequest setHTTPBody:requestData];
            
            BOOL rs = NO;
            //Can use sendAsynchronousRequest to request to Apple API, here I use sendSynchronousRequest
            NSError *error;
            NSURLResponse *response;
            NSData *resData = [NSURLConnection sendSynchronousRequest:storeRequest returningResponse:&response error:&error];
            if (error) {
                rs = NO;
            }
            else
            {
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:resData options:0 error:&error];
                if (!jsonResponse) {
                    rs = NO;
                }
                else
                {
                    NSLog(@"jsonResponse:%@", jsonResponse);
                    
                    NSDictionary *dictLatestReceiptsInfo = jsonResponse[@"latest_receipt_info"];
                    long long int expirationDateMs = [[dictLatestReceiptsInfo valueForKeyPath:@"@max.expires_date_ms"] longLongValue];
                    long long requestDateMs = [jsonResponse[@"receipt"][@"request_date_ms"] longLongValue];
                    NSLog(@"%lld--%lld", expirationDateMs, requestDateMs);
                    rs = [[jsonResponse objectForKey:@"status"] integerValue] == 0 && (expirationDateMs > requestDateMs);
                }
            }
            return rs;
        }
        else
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
}

@end
