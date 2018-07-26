//
//  RNZenDeskSupport.m
//
//  Created by Patrick O'Connor on 8/30/17.
//

// RN < 0.40 suppoert
#if __has_include(<React/RCTBridge.h>)
#import <React/RCTConvert.h>
#else
#import "RCTConvert.h"
#endif

#import "RNZenDeskSupport.h"
#import <ZendeskSDK/ZendeskSDK.h>
@implementation RNZenDeskSupport

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(initialize:(NSDictionary *)config){
    NSString *appId = [RCTConvert NSString:config[@"appId"]];
    NSString *zendeskUrl = [RCTConvert NSString:config[@"zendeskUrl"]];
    NSString *clientId = [RCTConvert NSString:config[@"clientId"]];
    [[ZDKConfig instance]
     initializeWithAppId:appId
     zendeskUrl:zendeskUrl
     clientId:clientId];
}

RCT_EXPORT_METHOD(applyTheme:(NSDictionary *)options){
    ZDKTheme * theme = [ZDKTheme baseTheme];

    UIColor *primaryTextColor = [RCTConvert UIColor:options[@"primaryTextColor"]];
    UIColor *secondaryTextColor = [RCTConvert UIColor:options[@"secondaryTextColor"]];
    UIColor *primaryBackgroundColor = [RCTConvert UIColor:options[@"primaryBackgroundColor"]];
    UIColor *secondaryBackgroundColor = [RCTConvert UIColor:options[@"secondaryBackgroundColor"]];
    UIColor *emptyBackgroundColor = [RCTConvert UIColor:options[@"emptyBackgroundColor"]];
    UIColor *metaTextColor = [RCTConvert UIColor:options[@"metaTextColor"]];
    UIColor *separatorColor = [RCTConvert UIColor:options[@"separatorColor"]];
    UIColor *inputFieldTextColor = [RCTConvert UIColor:options[@"inputFieldTextColor"]];
    UIColor *inputFieldBackgroundColor = [RCTConvert UIColor:options[@"inputFieldBackgroundColor"]];
    UIColor *fontName = [RCTConvert NSString:options[@"fontName"]];
    UIColor *boldFontName = [RCTConvert NSString:options[@"boldFontName"]];

    if (primaryTextColor != nil) {
        theme.primaryTextColor = primaryTextColor;
    }
    if (secondaryTextColor != nil) {
        theme.secondaryTextColor = secondaryTextColor;
    }
    if (primaryBackgroundColor != nil) {
        theme.primaryBackgroundColor = primaryBackgroundColor;
    }
    if (secondaryBackgroundColor != nil) {
        theme.secondaryBackgroundColor = secondaryBackgroundColor;
    }
    if (emptyBackgroundColor != nil) {
        theme.emptyBackgroundColor = emptyBackgroundColor;
    }
    if (metaTextColor != nil) {
        theme.metaTextColor = metaTextColor;
    }
    if (separatorColor != nil) {
        theme.separatorColor = separatorColor;
    }
    if (inputFieldTextColor != nil) {
        theme.inputFieldTextColor = inputFieldTextColor;
    }
    if (emptyBackgroundColor != nil) {
        theme.inputFieldBackgroundColor = inputFieldBackgroundColor;
    }
    if (fontName != nil) {
        theme.fontName = fontName;
    }
    if (boldFontName != nil) {
        theme.boldFontName = boldFontName;
    }

    [theme apply];
}

RCT_EXPORT_METHOD(setupIdentity:(NSDictionary *)identity){
    dispatch_async(dispatch_get_main_queue(), ^{
        ZDKAnonymousIdentity *zdIdentity = [ZDKAnonymousIdentity new];
        NSString *email = [RCTConvert NSString:identity[@"customerEmail"]];
        NSString *name = [RCTConvert NSString:identity[@"customerName"]];
        if (email != nil) {
            zdIdentity.email = email;
        }
        if (name != nil) {
            zdIdentity.name = name;
        }
        [ZDKConfig instance].userIdentity = zdIdentity;

    });
}

RCT_EXPORT_METHOD(showHelpCenterWithOptions:(NSDictionary *)options) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        UIViewController *vc = [window rootViewController];
        ZDKHelpCenterOverviewContentModel *helpCenterContentModel = [ZDKHelpCenterOverviewContentModel defaultContent];
        helpCenterContentModel.hideContactSupport = [RCTConvert BOOL:options[@"hideContactSupport"]];
        if (helpCenterContentModel.hideContactSupport) {
            [ZDKHelpCenter setNavBarConversationsUIType:ZDKNavBarConversationsUITypeNone];
        }
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        [ZDKHelpCenter presentHelpCenterOverview:vc withContentModel:helpCenterContentModel];
    });
}

RCT_EXPORT_METHOD(showCategoriesWithOptions:(NSArray *)categories options:(NSDictionary *)options) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        UIViewController *vc = [window rootViewController];
        ZDKHelpCenterOverviewContentModel *helpCenterContentModel = [ZDKHelpCenterOverviewContentModel defaultContent];
        helpCenterContentModel.groupType = ZDKHelpCenterOverviewGroupTypeCategory;
        helpCenterContentModel.groupIds = categories;
        helpCenterContentModel.hideContactSupport = [RCTConvert BOOL:options[@"hideContactSupport"]];
        if (helpCenterContentModel.hideContactSupport) {
            [ZDKHelpCenter setNavBarConversationsUIType:ZDKNavBarConversationsUITypeNone];
        }
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        [ZDKHelpCenter presentHelpCenterOverview:vc withContentModel:helpCenterContentModel];
    });
}

RCT_EXPORT_METHOD(showSectionsWithOptions:(NSArray *)sections options:(NSDictionary *)options) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        UIViewController *vc = [window rootViewController];
        ZDKHelpCenterOverviewContentModel *helpCenterContentModel = [ZDKHelpCenterOverviewContentModel defaultContent];
        helpCenterContentModel.groupType = ZDKHelpCenterOverviewGroupTypeSection;
        helpCenterContentModel.groupIds = sections;
        helpCenterContentModel.hideContactSupport = [RCTConvert BOOL:options[@"hideContactSupport"]];
        if (helpCenterContentModel.hideContactSupport) {
            [ZDKHelpCenter setNavBarConversationsUIType:ZDKNavBarConversationsUITypeNone];
        }
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        [ZDKHelpCenter presentHelpCenterOverview:vc withContentModel:helpCenterContentModel];
    });
}

RCT_EXPORT_METHOD(showLabelsWithOptions:(NSArray *)labels options:(NSDictionary *)options) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        UIViewController *vc = [window rootViewController];
        ZDKHelpCenterOverviewContentModel *helpCenterContentModel = [ZDKHelpCenterOverviewContentModel defaultContent];
        helpCenterContentModel.labels = labels;
        helpCenterContentModel.hideContactSupport = [RCTConvert BOOL:options[@"hideContactSupport"]];
        if (helpCenterContentModel.hideContactSupport) {
            [ZDKHelpCenter setNavBarConversationsUIType:ZDKNavBarConversationsUITypeNone];
        }
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        [ZDKHelpCenter presentHelpCenterOverview:vc withContentModel:helpCenterContentModel];
    });
}

RCT_EXPORT_METHOD(showHelpCenter) {
    [self showHelpCenterWithOptions:nil];
}

RCT_EXPORT_METHOD(showCategories:(NSArray *)categories) {
    [self showCategoriesWithOptions:categories options:nil];
}

RCT_EXPORT_METHOD(showSections:(NSArray *)sections) {
    [self showSectionsWithOptions:sections options:nil];
}

RCT_EXPORT_METHOD(showLabels:(NSArray *)labels) {
    [self showLabelsWithOptions:labels options:nil];
}

RCT_EXPORT_METHOD(callSupport:(NSDictionary *)customFields) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        UIViewController *vc = [window rootViewController];

        NSMutableArray *fields = [[NSMutableArray alloc] init];

        for (NSString* key in customFields) {
            id value = [customFields objectForKey:key];
            [fields addObject: [[ZDKCustomField alloc] initWithFieldId:@(key.intValue) andValue:value]];
        }
        [ZDKConfig instance].customTicketFields = fields;
        [ZDKRequests presentRequestCreationWithViewController:vc];
    });
}

RCT_EXPORT_METHOD(supportHistory){
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        UIViewController *vc = [window rootViewController];
        [ZDKRequests presentRequestListWithViewController:vc];
    });
}
@end
