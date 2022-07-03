//
//  Created by Shekar Mudaliyar on 12/12/19.
//  Copyright © 2019 Shekar Mudaliyar. All rights reserved.
//

#import "SocialSharePlugin.h"
#include <objc/runtime.h>
#import <Photos/Photos.h>

@implementation SocialSharePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"social_share" binaryMessenger:[registrar messenger]];
  SocialSharePlugin* instance = [[SocialSharePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"shareInstagramStory" isEqualToString:call.method]) {
        //Sharing story on instagram
        // Verify app can open custom URL scheme, open if able
                NSData *backgroundVideo = [NSData dataWithContentsOfFile:call.arguments[@"backgroundImage"]];
               // NSData *backgroundVideo = call.arguments[@"backgroundImage"];
                  NSURL *urlScheme = [NSURL URLWithString:@"instagram-stories://share?source_application=com.consumer.quse"];
                  if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {

                        // Assign background image asset to pasteboard
                        NSArray *pasteboardItems = @[@{@"com.instagram.sharedSticker.backgroundVideo" : backgroundVideo}];
                        NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
                        // This call is iOS 10+, can use 'setItems' depending on what versions you support
                        [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];

                        [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
                  } else {
                      // Handle older app versions or app not installed case
                  }
            } else if ([@"shareInstagramFeed" isEqualToString:call.method]) {
               /* PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
                                                fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                                                fetchOptions.fetchLimit = 1;
                                                PHFetchResult *fetchResult;

                fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:fetchOptions];
                PHObject *lastAsset = fetchResult.firstObject;*/

               // if (lastAsset != nil) {
                                                   // NSString *localIdentifier = lastAsset.localIdentifier;
                                                    NSString *u = [NSString stringWithFormat:@"instagram://library?AssetPath=%@", call.arguments[@"backgroundImage"]];
                                                    NSURL *url = [NSURL URLWithString:u];
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        if ([[UIApplication sharedApplication] canOpenURL:url]) {
                                                            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                                                        } else {

                                                            NSString *urlStr = @"https://itunes.apple.com/in/app/instagram/id389801252?mt=8";
                                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr] options:@{} completionHandler:nil];
                                                        }
                                                    });
                                               // }
            }else if ([@"shareFacebookStory" isEqualToString:call.method]) {
                NSData *backgroundVideo = [NSData dataWithContentsOfFile:call.arguments[@"stickerImage"]];
                NSURL *urlScheme = [NSURL URLWithString:@"facebook-stories://share"];
                   if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {

                       // Assign background video asset to pasteboard
                       NSArray *pasteboardItems = @[@{@"com.facebook.sharedSticker.backgroundVideo" : backgroundVideo,
                                                      @"com.facebook.sharedSticker.appID" : call.arguments[@"appId"]}];
                       NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
                       // This call is iOS 10+, can use 'setItems' depending on what versions you support
                       [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];

               [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
           }

    } else if ([@"copyToClipboard" isEqualToString:call.method]) {
        NSString *content = call.arguments[@"content"];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        //assigning content to pasteboard
        pasteboard.string = content;
        result([NSNumber numberWithBool:YES]);
    } else if ([@"shareTwitter" isEqualToString:call.method]) {
        // NSString *assetImage = call.arguments[@"assetImage"];
        NSString *captionText = call.arguments[@"captionText"];
        NSString *urlstring = call.arguments[@"url"];
        NSString *trailingText = call.arguments[@"trailingText"];

        NSString* urlTextEscaped = [urlstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString: urlTextEscaped];
        NSURL *urlScheme = [NSURL URLWithString:@"twitter://"];
        if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
            //check if twitter app exists
            //check if it contains a link
            if ( [ [url absoluteString]  length] == 0 ) {
                NSString *urlSchemeTwitter = [NSString stringWithFormat:@"twitter://post?message=%@",captionText];
                NSURL *urlSchemeSend = [NSURL URLWithString:urlSchemeTwitter];
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:urlSchemeSend options:@{} completionHandler:nil];
                    result(@"sharing");
                } else {
                  result(@"this only supports iOS 10+");
                }
            } else {
                //check if trailing text equals null
                if ( [ trailingText   length] == 0 ) {
                    //if trailing text is null
                    NSString *urlSchemeSms = [NSString stringWithFormat:@"twitter://post?message=%@",captionText];
                    //appending url with normal text and url scheme
                    NSString *urlWithLink = [urlSchemeSms stringByAppendingString:[url absoluteString]];

                    //final urlscheme
                    NSURL *urlSchemeMsg = [NSURL URLWithString:urlWithLink];
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication] openURL:urlSchemeMsg options:@{} completionHandler:nil];
                        result(@"sharing");
                    } else {
                        result(@"this only supports iOS 10+");
                    }
                } else {
                    //if trailing text is not null
                    NSString *urlSchemeSms = [NSString stringWithFormat:@"twitter://post?message=%@",captionText];
                    //appending url with normal text and url scheme
                    NSString *urlWithLink = [urlSchemeSms stringByAppendingString:[url absoluteString]];
                    NSString *finalurl = [urlWithLink stringByAppendingString:trailingText];
                    //final urlscheme
                    NSURL *urlSchemeMsg = [NSURL URLWithString:finalurl];
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication] openURL:urlSchemeMsg options:@{} completionHandler:nil];
                        result(@"sharing");
                    } else {
                        result(@"this only supports iOS 10+");
                    }
                }
            }
        } else {
            result(@"cannot find Twitter app");
        }
    } else if ([@"shareSms" isEqualToString:call.method]) {
        NSString *msg = call.arguments[@"message"];
        NSString *urlstring = call.arguments[@"urlLink"];
        NSString *trailingText = call.arguments[@"trailingText"];

        NSURL *urlScheme = [NSURL URLWithString:@"sms://"];

        NSString* urlTextEscaped = [urlstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString: urlTextEscaped];
        //check if it contains a link
        if ( [ [url absoluteString]  length] == 0 ) {
            //if it doesn't contains a link
            NSString *urlSchemeSms = [NSString stringWithFormat:@"sms:?&body=%@",msg];
            NSURL *urlScheme = [NSURL URLWithString:urlSchemeSms];
            if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
                    result(@"sharing");
                } else {
                    result(@"this only supports iOS 10+");
                }
            } else {
                result(@"cannot find Sms app");
            }
        } else {
            //if it does contains a link
            //check if trailing text equals null
            if ( [ trailingText   length] == 0 ) {
                //if trailing text is null
                //url scheme with normal text message
                NSString *urlSchemeSms = [NSString stringWithFormat:@"sms:?&body=%@",msg];
                //appending url with normal text and url scheme
                NSString *urlWithLink = [urlSchemeSms stringByAppendingString:[url absoluteString]];
                //final urlscheme
                NSURL *urlSchemeMsg = [NSURL URLWithString:urlWithLink];
                if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication] openURL:urlSchemeMsg options:@{} completionHandler:nil];
                        result(@"sharing");
                    } else {
                        result(@"this only supports iOS 10+");
                    }
                } else {
                    result(@"cannot find Sms app");
                }
            } else {
                //if trailing text is not null
                NSString *urlSchemeSms = [NSString stringWithFormat:@"sms:?&body=%@",msg];
                //appending url with normal text and url scheme
                NSString *urlWithLink = [urlSchemeSms stringByAppendingString:[url absoluteString]];
                NSString *finalUrl = [urlWithLink stringByAppendingString:trailingText];

                //final urlscheme
                NSURL *urlSchemeMsg = [NSURL URLWithString:finalUrl];
                if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication] openURL:urlSchemeMsg options:@{} completionHandler:nil];
                        result(@"sharing");
                    } else {
                        result(@"this only supports iOS 10+");
                    }
                } else {
                    result(@"cannot find Sms app");
                }
            }
        
        }
    } else if ([@"shareSlack" isEqualToString:call.method]) {
        //NSString *content = call.arguments[@"content"];
        result([NSNumber numberWithBool:YES]);
    } else if ([@"shareWhatsapp" isEqualToString:call.method]) {
        NSString *content = call.arguments[@"content"];
        NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",content];
        NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
            [[UIApplication sharedApplication] openURL: whatsappURL];
            result(@"sharing");
        } else {
            result(@"cannot open whatsapp");
        }
        result([NSNumber numberWithBool:YES]);
    } else if ([@"shareTelegram" isEqualToString:call.method]) {
        NSString *content = call.arguments[@"content"];
        NSString * urlScheme = [NSString stringWithFormat:@"tg://msg?text=%@",content];
        NSURL * telegramURL = [NSURL URLWithString:[urlScheme stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if ([[UIApplication sharedApplication] canOpenURL: telegramURL]) {
            [[UIApplication sharedApplication] openURL: telegramURL];
            result(@"sharing");
        } else {
            result(@"cannot open Telegram");
        }
        result([NSNumber numberWithBool:YES]);
    } else if ([@"shareOptions" isEqualToString:call.method]) {
        NSString *content = call.arguments[@"content"];
        NSString *image = call.arguments[@"image"];
        //checking if it contains image file
        if ([image isEqual:[NSNull null]] || [ image  length] == 0 ) {
            //when image is not included
            NSArray *objectsToShare = @[content];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            UIViewController *controller =[UIApplication sharedApplication].keyWindow.rootViewController;
            [controller presentViewController:activityVC animated:YES completion:nil];
            result([NSNumber numberWithBool:YES]);
        } else {
            //when image file is included
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL isFileExist = [fileManager fileExistsAtPath: image];
            UIImage *imgShare;
            if (isFileExist) {
                imgShare = [[UIImage alloc] initWithContentsOfFile:image];
            }
            NSArray *objectsToShare = @[content, imgShare];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            UIViewController *controller =[UIApplication sharedApplication].keyWindow.rootViewController;
            [controller presentViewController:activityVC animated:YES completion:nil];
            result([NSNumber numberWithBool:YES]);
        }
    } else if ([@"checkInstalledApps" isEqualToString:call.method]) {
        NSMutableDictionary *installedApps = [[NSMutableDictionary alloc] init];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram-stories://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"instagram"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"instagram"];
        }

        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"facebook-stories://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"facebook"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"facebook"];
        }

        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"twitter"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"twitter"];
        }

        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"sms"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"sms"];
        }

        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"whatsapp://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"whatsapp"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"whatsapp"];
        }

        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tg://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"telegram"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"telegram"];
        }
        result(installedApps);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
