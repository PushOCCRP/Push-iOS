//
//  TorManager.h
//  Push
//
//  Created by Christopher Guess on 12/29/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>

@protocol TorManagerDelegate

- (void)didCreateTorSession:(NSURLSession*)session;
- (void)errorCreatingTorSession:(NSError*)error;

@end

typedef enum : NSUInteger {
    TorManagerInactive,
    TorManagerStarting,
    TorManagerConnected,
} TorManagerStatus;

@interface TorManager : NSObject

@property (nonatomic, assign) AFHTTPSessionManager<TorManagerDelegate> * sessionManager;
@property (nonatomic, assign) TorManagerStatus status;


+ (TorManager *)sharedManager;
- (void)startTorSessionWithSession:(AFHTTPSessionManager<TorManagerDelegate>*)sessionManager;

@end
