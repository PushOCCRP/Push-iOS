//
//  TorManager.m
//  Push
//
//  Created by Christopher Guess on 12/29/16.
//  Copyright © 2016 OCCRP. All rights reserved.
//

#import "TorManager.h"
#include <CPAProxy/CPAProxy.h>

@interface TorManager()

@property (nonatomic, retain) CPAProxyManager * cpaProxyManager;

@end

@implementation TorManager

+ (TorManager *)sharedManager {
    static TorManager *_sharedManager = nil;
    
    //We only want to create one singleton object, so do that with GCD
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //Set up the singleton class
        _sharedManager = [[TorManager alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if(self){
        self.status = TorManagerInactive;
    }
    
    return self;
}

- (void)startTorSessionWithSession:(AFHTTPSessionManager<TorManagerDelegate>*)sessionManager
{
    self.sessionManager = sessionManager;
    [self startTorWithAFHTTPSessionManager:sessionManager];
}

- (void)startTorWithAFHTTPSessionManager:(AFHTTPSessionManager<TorManagerDelegate>*)sessionManager
{
    self.status = TorManagerStarting;
    
    // Get resource paths for the torrc and geoip files from the main bundle
    NSURL *cpaProxyBundleURL = [[NSBundle bundleForClass:[CPAProxyManager class]] URLForResource:@"CPAProxy" withExtension:@"bundle"];
    NSBundle *cpaProxyBundle = [NSBundle bundleWithURL:cpaProxyBundleURL];
    NSString *torrcPath = [cpaProxyBundle pathForResource:@"torrc" ofType:nil];
    NSString *geoipPath = [cpaProxyBundle pathForResource:@"geoip" ofType:nil];
    
    // Place to store Tor caches (non-temp storage improves performance since
    // directory data does not need to be re-loaded each launch)
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *torDataDir = [documentsDirectory stringByAppendingPathComponent:@"tor"];
    
    // Initialize a CPAProxyManager
    CPAConfiguration * configuration = [CPAConfiguration configurationWithTorrcPath:torrcPath geoipPath:geoipPath torDataDirectoryPath:torDataDir];
    
    self.cpaProxyManager = [CPAProxyManager proxyWithConfiguration:configuration];
    
    [self.cpaProxyManager setupWithCompletion:^(NSString *socksHost, NSUInteger socksPort, NSError *error) {
        if (error == nil) {
            // ... do something with Tor socks hostname & port ...
            NSLog(@"Connected: host=%@, port=%lu", socksHost, (long)socksPort);
            
            // ... like this -- see below for implementation ...
            [self handleCPAProxySetupWithSOCKSHost:socksHost SOCKSPort:socksPort sessionManager:sessionManager];
        } else {
            [self torSpinUpFailedWithError:error sessionManager:sessionManager];
        }
    } progress:^(NSInteger progress, NSString *summaryString) {
        // ... do something to notify user of tor's initialization progress ...
        NSLog(@"%li %@", (long)progress, summaryString);
    }];
    
}

- (void)handleCPAProxySetupWithSOCKSHost:(NSString *)SOCKSHost SOCKSPort:(NSUInteger)SOCKSPort
                          sessionManager:(AFHTTPSessionManager<TorManagerDelegate>*)sessionManager
{
    // Create a NSURLSessionConfiguration that uses the newly setup SOCKS proxy
    NSDictionary *proxyDict = @{
                                (NSString *)kCFStreamPropertySOCKSProxyHost : SOCKSHost,
                                (NSString *)kCFStreamPropertySOCKSProxyPort : @(SOCKSPort)
                                };
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.connectionProxyDictionary = proxyDict;
    
    
    // Create a NSURLSession with the configuration
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:configuration delegate:sessionManager delegateQueue:[NSOperationQueue mainQueue]];
    
    self.status = TorManagerConnected;
    // Set the AFNetworking to use the tor proxy here. Everything else will work normally.
    if(sessionManager && [sessionManager respondsToSelector:@selector(didCreateTorSession:)]){
        [sessionManager didCreateTorSession:urlSession];
    }
}

- (void)torSpinUpFailedWithError:(NSError*)error sessionManager:(AFHTTPSessionManager<TorManagerDelegate>*)sessionManager
{
    self.status = TorManagerInactive;
    if(sessionManager && [sessionManager respondsToSelector:@selector(errorCreatingTorSession:)]){
        [sessionManager errorCreatingTorSession:error];
    }
}

@end
