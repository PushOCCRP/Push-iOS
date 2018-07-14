//
//  AnalyticsManager.h
//  Push
//
//  Created by Christopher Guess on 2/4/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CWGAnalyticsCrashlytics,
    CWGAnalyticsGoogle,
} CWGAnalytics;

@interface AnalyticsManager : NSObject

+ (AnalyticsManager *)sharedManager;
- (void)setupForAnaylytics:(CWGAnalytics)analyticsType;
- (void)logContentViewWithName:(NSString* _Nonnull)name contentType:(nullable NSString *)contentTypeOrNil contentId:(nullable NSString *)contentIdOrNil customAttributes:(nullable NSDictionary<NSString *,id> *)customAttributesOrNil;
- (void)logSearchWithQuery:(nullable NSString *)queryOrNil customAttributes:(nullable NSDictionary<NSString *,id> *)customAttributesOrNil;
- (void)logCustomEventWithName:(nonnull NSString *)name customAttributes:(nullable NSDictionary<NSString *, id> *)attributes;

- (void)logErrorWithErrorDescription:(nonnull NSString *)errorDescription;

- (void)startTimerForContentViewWithObject:(nullable id)object name:(NSString* _Nonnull)name contentType:(nullable NSString *)contentTypeOrNil
                                 contentId:(nullable NSString *)contentIdOrNil
                          customAttributes:(nullable NSDictionary<NSString *,id> *)customAttributesOrNil;
- (void)endTimerForContentViewWithObject:(nullable id)object andName:(NSString* _Nonnull)name;

- (nonnull NSUUID*)installationUUID;

@end
