//
//  AnalyticsManager.m
//  Push
//
//  Created by Christopher Guess on 2/4/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "AnalyticsManager.h"
#import "LanguageManager.h"
//#import <Fabric/Fabric.h>
//#import <Crashlytics/Crashlytics.h>

@interface AnalyticsManagerViewTimeEventTracker : NSObject

@property (nonatomic, retain) id object;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * contentType;
@property (nonatomic, retain) NSString * contentId;
@property (nonatomic, retain) NSDictionary * customAttributes;

@end

@implementation AnalyticsManagerViewTimeEventTracker

static NSString * installationUUIDKeyName = @"INSTALLATION_UUID";

- (instancetype)initWithObject:(id)object name:(NSString*)name contentType:(nullable NSString *)contentTypeOrNil
                     contentId:(nullable NSString *)contentIdOrNil
              customAttributes:(nullable NSDictionary<NSString *,id> *)customAttributesOrNil
{
    self = [self initWithObject:object startTime:[NSDate date]
                           name:name
                    contentType:contentTypeOrNil
                      contentId:contentIdOrNil
               customAttributes:customAttributesOrNil];
    return self;
}

- (instancetype)initWithObject:(id)object startTime:(NSDate*)time name:(NSString*)name contentType:(nullable NSString *)contentTypeOrNil
                     contentId:(nullable NSString *)contentIdOrNil
              customAttributes:(nullable NSDictionary<NSString *,id> *)customAttributesOrNil
{
    self = [super init];
    if(self){
        self.object = object;
        self.time = time;
        self.name = name;
        self.contentType = contentTypeOrNil;
        self.contentId = contentIdOrNil;
        self.customAttributes = customAttributesOrNil;
    }
    
    return self;
}

- (NSString*)description
{
    return [AnalyticsManagerViewTimeEventTracker descriptionForObject:self.object andName:self.name];
}

+ (NSString*)descriptionForObject:(id)object andName:(NSString*)name
{
    return [NSString stringWithFormat:@"%p : %@", object, name];
}


@end


@interface AnalyticsManager()

@property (nonatomic, assign) CWGAnalytics analyticsType;
@property (nonatomic, retain) NSMutableSet * timers;

@end

@implementation AnalyticsManager

static NSString * uuidKey = @"push_analytics_uuid";

+ (AnalyticsManager *)sharedManager {
    static AnalyticsManager *_sharedManager = nil;
    
    //We only want to create one singleton object, so do that with GCD
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //Set up the singleton class
        _sharedManager = [[AnalyticsManager alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if(self){
        self.timers = [NSMutableSet set];
    }
    
    return self;
}

+ (CWGAnalytics)analyticsType
{
    return [AnalyticsManager sharedManager].analyticsType;
}

+ (void)setupForAnaylytics:(CWGAnalytics)analyticsType
{
    [AnalyticsManager sharedManager].analyticsType = analyticsType;
    
    switch (analyticsType) {
        case CWGAnalyticsCrashlytics:
            //[Fabric with:@[[Crashlytics class]]];
            break;
        case CWGAnalyticsGoogle:
            // Not implemented
            break;
        default:
            break;
    }
    
    [AnalyticsManager setupUUID];
}

+ (void)setupUUID
{
    NSString * uuid = [[NSUserDefaults standardUserDefaults] objectForKey:uuidKey];
    if(!uuid || uuid.length < 1){
        uuid = [NSUUID UUID].UUIDString;
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:uuidKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    switch ([AnalyticsManager analyticsType]) {
        case CWGAnalyticsCrashlytics:
            //[[Crashlytics sharedInstance] setUserIdentifier:uuid];
            break;
        case CWGAnalyticsGoogle:
            // Not implemented
            break;
        default:
            break;
    }

}

+ (void)logContentViewWithName:(NSString*)name contentType:(nullable NSString *)contentTypeOrNil
                     contentId:(nullable NSString *)contentIdOrNil
              customAttributes:(nullable NSDictionary<NSString *,id> *)customAttributesOrNil
{
    switch ([AnalyticsManager analyticsType]) {
        case CWGAnalyticsCrashlytics:
            //[Answers logContentViewWithName:name contentType:contentIdOrNil contentId:contentIdOrNil customAttributes:[self attributesDictionaryWithDictionary:customAttributesOrNil]];
            break;
        case CWGAnalyticsGoogle:
            // Not implemented
            break;
        default:
            break;
    }
}

+ (void)logSearchWithQuery:(nullable NSString *)queryOrNil customAttributes:(nullable NSDictionary<NSString *,id> *)customAttributesOrNil
{
    switch ([AnalyticsManager analyticsType]) {
        case CWGAnalyticsCrashlytics:
            //[Answers logSearchWithQuery:queryOrNil customAttributes:[self attributesDictionaryWithDictionary:customAttributesOrNil]];
            break;
        case CWGAnalyticsGoogle:
            // Not implemented
            break;
        default:
            break;
    }

}

+ (void)logCustomEventWithName:(nonnull NSString *)name customAttributes:(nullable NSDictionary<NSString *, id> *)customAttributesOrNil
{
    switch ([AnalyticsManager analyticsType]) {
        case CWGAnalyticsCrashlytics:
            //[Answers logCustomEventWithName:name customAttributes:[self attributesDictionaryWithDictionary:customAttributesOrNil]];
            break;
        case CWGAnalyticsGoogle:
            // Not implemented
            break;
        default:
            break;
    }

}

+ (void)logErrorWithErrorDescription:(nonnull NSString *)errorDescription
{
    [self logCustomEventWithName:errorDescription customAttributes:nil];
}

+ (void)startTimerForContentViewWithObject:(id)object name:(NSString*)name contentType:(nullable NSString *)contentTypeOrNil
                               contentId:(nullable NSString *)contentIdOrNil
                        customAttributes:(nullable NSDictionary<NSString *,id> *)customAttributesOrNil
{
    AnalyticsManagerViewTimeEventTracker * tracker = [[AnalyticsManagerViewTimeEventTracker alloc] initWithObject:object name:name contentType:contentTypeOrNil contentId:contentIdOrNil customAttributes:customAttributesOrNil];
    
    [[AnalyticsManager sharedManager].timers addObject:tracker];
}

+ (void)endTimerForContentViewWithObject:(id)object andName:(NSString*)name
{
    NSSet * timers = [[AnalyticsManager sharedManager].timers objectsPassingTest:^BOOL(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if([[(AnalyticsManagerViewTimeEventTracker*)obj description] isEqualToString:[AnalyticsManagerViewTimeEventTracker descriptionForObject:object andName:name]]){
            return obj;
        }
        return nil;
    }];
    

    AnalyticsManagerViewTimeEventTracker * timer = timers.anyObject;
    if(timer){
        // Get time since timer was added
        NSDate * previousTime = timer.time;
        
        NSTimeInterval timeInterval = fabs([previousTime timeIntervalSinceNow]);
        
        NSMutableDictionary * attributes = [NSMutableDictionary dictionaryWithDictionary:timer.customAttributes];
        if(timer.contentType){
            [attributes setObject:timer.contentType forKey:@"contentType"];
        }
        
        if(timer.contentId){
            [attributes setObject:timer.contentId forKey:@"contentId"];
        }
        
        [attributes setObject:[NSNumber numberWithDouble:timeInterval] forKey:@"Time Viewed"];
        
        [self logCustomEventWithName:timer.name customAttributes:attributes];
    }
}

- (void)dealloc
{
    // If the object's deallocated we want to close all the timers out first
    for(AnalyticsManagerViewTimeEventTracker * timer in self.timers.allObjects){
        [AnalyticsManager endTimerForContentViewWithObject:timer.object andName:timer.name];
    }
}


/**
 *  Adds language parameter to all notifications
 *
 *  @param dictionary attributes dictionary or nil, passed through
 *
 *  @return dictionary with "Language: English" or whichever language is selected added.
 */
+ (NSDictionary*)attributesDictionaryWithDictionary:(NSDictionary*)dictionary
{
    if(!dictionary){
        dictionary = [NSDictionary dictionary];
    }
    
    NSMutableDictionary * mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    [mutableAttributes setObject:[LanguageManager sharedManager].language forKey:@"Language"];
    
    return [NSDictionary dictionaryWithDictionary:mutableAttributes];
}

+ (NSUUID*)installationUUID
{
    NSUUID * uuid = [[NSUserDefaults standardUserDefaults] valueForKey:installationUUIDKeyName];
    if(!uuid){
        uuid = [NSUUID UUID];
        [[NSUserDefaults standardUserDefaults] setObject:[uuid UUIDString] forKey:installationUUIDKeyName];
    }
    
    return uuid;
}

@end
