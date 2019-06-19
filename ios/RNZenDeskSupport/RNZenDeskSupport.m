//
//  RNZenDeskSupport.m
//
//  Created by Patrick O'Connor on 8/30/17.
//  Modified by Ryan Kuhn on 6/11/19
//

#if __has_include(<React/RCTBridge.h>)
#import <React/RCTConvert.h>
#else
#import "RCTConvert.h"
#endif

#import "RNZenDeskSupport.h"
#import <ZendeskSDK/ZendeskSDK.h>
#import <ZendeskCoreSDK/ZendeskCoreSDK.h>
#import <sys/utsname.h>

@implementation RNZenDeskSupport

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(initialize:(NSDictionary *)config){
    NSString *appId = [RCTConvert NSString:config[@"appId"]];
    NSString *zendeskUrl = [RCTConvert NSString:config[@"zendeskUrl"]];
    NSString *clientId = [RCTConvert NSString:config[@"clientId"]];
    [ZDKZendesk initializeWithAppId:appId clientId:clientId zendeskUrl:zendeskUrl];
    [ZDKSupport initializeWithZendesk:[ZDKZendesk instance]];
}

RCT_EXPORT_METHOD(setupIdentity:(NSDictionary *)identity){
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *email = [RCTConvert NSString:identity[@"customerEmail"]];
        NSString *name = [RCTConvert NSString:identity[@"customerName"]];
        
        id<ZDKObjCIdentity> zdIdentity = [[ZDKObjCAnonymous alloc] initWithName:name email:email];
        [[ZDKZendesk instance] setIdentity:zdIdentity];
        
    });
}

RCT_EXPORT_METHOD(showHelpCenterWithOptions:(NSDictionary *)options) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        
        UIViewController *vc = [window rootViewController];
        
        UIViewController *helpCenter = [ZDKHelpCenterUi buildHelpCenterOverviewUi];
        [vc presentViewController:helpCenter animated:YES completion:nil];
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
        ZDKHelpCenterUiConfiguration* helpCenterUiConfig = [ZDKHelpCenterUiConfiguration new];
        if (helpCenterContentModel.hideContactSupport) {
            [helpCenterUiConfig setHideContactSupport:YES];
        }
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        
        UIViewController *helpCenter = [ZDKHelpCenterUi buildHelpCenterOverviewUiWithConfigs:@[helpCenterUiConfig]];
        [vc.navigationController pushViewController:helpCenter animated:YES];
    });
}

RCT_EXPORT_METHOD(showSectionsWithOptions:(NSArray *)sections options:(NSDictionary *)options) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        
        UIViewController *vc = [window rootViewController];
        
        ZDKHelpCenterUiConfiguration * hcConfig = [ZDKHelpCenterUiConfiguration new];
        [hcConfig setGroupType:ZDKHelpCenterOverviewGroupTypeSection];
        [hcConfig setGroupIds:@[@115000600952, @115001289432]];
        
        UIViewController *helpCenter = [ZDKHelpCenterUi buildHelpCenterOverviewUiWithConfigs:@[hcConfig]];
        [vc presentViewController:helpCenter animated:YES completion:nil];
    });
}

RCT_EXPORT_METHOD(showSection:(NSString *)section) {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        
        UIViewController *vc = [window rootViewController];
        
        UIViewController *articleController = [ZDKHelpCenterUi buildHelpCenterArticleUiWithArticleId:section andConfigs:@[]];
        [vc presentViewController:articleController animated:YES completion:nil];
    });
}

RCT_EXPORT_METHOD(showLabelsWithOptions:(NSArray *)labels options:(NSDictionary *)options) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        UIViewController *vc = [window rootViewController];
        ZDKHelpCenterOverviewContentModel *helpCenterContentModel = [ZDKHelpCenterOverviewContentModel defaultContent];
        helpCenterContentModel.labels = labels;
        helpCenterContentModel.hideContactSupport = [RCTConvert BOOL:options[@"hideContactSupport"]];
        ZDKHelpCenterUiConfiguration* helpCenterUiConfig = [ZDKHelpCenterUiConfiguration new];
        if (helpCenterContentModel.hideContactSupport) {
            [helpCenterUiConfig setHideContactSupport:YES];
        }
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        
        UIViewController *helpCenter = [ZDKHelpCenterUi buildHelpCenterOverviewUiWithConfigs:@[helpCenterUiConfig]];
        [vc.navigationController pushViewController:helpCenter animated:YES];
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

ZDKHelpCenterProvider * provider;

RCT_EXPORT_METHOD(createProvider) {
    provider = [[ZDKHelpCenterProvider alloc] init];
}

RCT_EXPORT_METHOD(getArticle:(NSString *)article callback:(RCTResponseSenderBlock)callback) {
    [provider getArticleWithId:article withCallback:^(NSArray *items, NSError *error) {
        NSString *title = [[items objectAtIndex:0] title];
        NSString *body = [[items objectAtIndex:0] body];
        NSString *article_details = [[items objectAtIndex:0] article_details];
        NSArray *articleData = [NSArray arrayWithObjects:title, body, article_details, nil];
        
        callback(@[[NSNull null], articleData]);
    }];
}

RCT_EXPORT_METHOD(getSection:(NSString *)section callback:(RCTResponseSenderBlock)callback) {
    [provider getArticlesWithSectionId:section withCallback:^(NSArray *items, NSError *error) {
        NSMutableArray* returnArticles = [[NSMutableArray alloc] init];
        for (int i = 0; i < [items count]; i++)
        {
            NSMutableArray *section = [[NSMutableArray alloc] init];
            section[0] = [[items objectAtIndex:i] title];
            section[1] = [[items objectAtIndex:i] identifier];
            [returnArticles addObject: section];
        }
        NSArray *articleData = [returnArticles copy];
        callback(@[[NSNull null], articleData]);
    }];
}

RCT_EXPORT_METHOD(getCategory:(NSString *)category callback:(RCTResponseSenderBlock)callback) {
    [provider getSectionsWithCategoryId:category withCallback:^(NSArray *items, NSError *error) {
        NSMutableArray* returnSections = [[NSMutableArray alloc] init];
        for (int i = 0; i < [items count]; i++)
        {
            NSMutableArray *section = [[NSMutableArray alloc] init];
            section[0] = [[items objectAtIndex:i] name];
            section[1] = [[items objectAtIndex:i] identifier];
            [returnSections addObject: section];
        }
        NSArray *sectionData = [returnSections copy];
        callback(@[[NSNull null], sectionData]);
    }];
}

RCT_EXPORT_METHOD(callSupport:(NSDictionary *)customFields) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        UIViewController *vc = [window rootViewController];
        
        ZDKRequestUiConfiguration * requestConfig = [ZDKRequestUiConfiguration new];
        requestConfig.tags = [NSArray arrayWithObjects:@"mobile", deviceName(), "iOS", nil];
        
        UIViewController *request = [ZDKRequestUi buildRequestUiWith:@[requestConfig]];
        [vc presentViewController:request animated:YES completion:nil];
    });
}

RCT_EXPORT_METHOD(supportHistory){
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        UIViewController *vc = [window rootViewController];
        
        ZDKRequestUiConfiguration * requestConfig = [ZDKRequestUiConfiguration new];
        requestConfig.tags = [NSArray arrayWithObjects:@"mobile", deviceName(), "iOS", nil];
        
        UIViewController *requestListController = [ZDKRequestUi buildRequestListWith:@[requestConfig]];
        [vc presentViewController:requestListController animated:YES completion:nil];
    });
}

NSString* deviceName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

@end
