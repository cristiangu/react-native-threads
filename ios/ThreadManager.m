#import "ThreadManager.h"
#include <stdlib.h>

@implementation ThreadManager

@synthesize bridge = _bridge;

NSMutableDictionary *threads;

RCT_EXPORT_MODULE();


- (RCTBridge *)startThreadIfNeeded: (NSString *)name
           threadId:(NSNumber *)threadId {
    
    if (threads == nil) {
      threads = [[NSMutableDictionary alloc] init];
    }
    
    RCTBridge *currentThreadBridge = [threads objectForKey:threadId];
    
    if(currentThreadBridge != NULL) {
        ThreadSelfManager *threadSelf = [currentThreadBridge moduleForName:@"ThreadSelfManager"];
        [threadSelf setThreadId:[threadId intValue]];
        [threadSelf setParentBridge:self.bridge];
        return currentThreadBridge;
    }

    NSURL *threadURL = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:name fallbackResource:name];
    NSLog(@"starting Thread %@", [threadURL absoluteString]);


    RCTBridge *threadBridge = [[RCTBridge alloc] initWithBundleURL:threadURL
                                              moduleProvider:nil
                                               launchOptions:nil];

    ThreadSelfManager *threadSelf = [threadBridge moduleForName:@"ThreadSelfManager"];
    [threadSelf setThreadId:[threadId intValue]];
    [threadSelf setParentBridge:self.bridge];
    

    [threads setObject:threadBridge forKey:threadId];
    
    return threadBridge;
    
    
}

RCT_REMAP_METHOD(startThreadIfNeeded,
                 name: (NSString *)name
                 threadId:(NSNumber * _Nonnull)  threadId
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    
    
    [self startThreadIfNeeded:name threadId:threadId];
    resolve(threadId);
   
}

RCT_EXPORT_METHOD(stopThread:(int)threadId)
{
  if (threads == nil) {
    NSLog(@"Empty list of threads. abort stopping thread with id %i", threadId);
    return;
  }

  RCTBridge *threadBridge = threads[[NSNumber numberWithInt:threadId]];
  if (threadBridge == nil) {
    NSLog(@"Thread is NIl. abort stopping thread with id %i", threadId);
    return;
  }

  [threadBridge invalidate];
  [threads removeObjectForKey:[NSNumber numberWithInt:threadId]];
}

RCT_EXPORT_METHOD(postThreadMessage: (int)threadId message:(NSString *)message)
{
  if (threads == nil) {
    NSLog(@"Empty list of threads. abort posting to thread with id %i", threadId);
    return;
  }

  RCTBridge *threadBridge = threads[[NSNumber numberWithInt:threadId]];
  if (threadBridge == nil) {
    NSLog(@"Thread is NIl. abort posting to thread with id %i", threadId);
    return;
  }

  [threadBridge.eventDispatcher sendAppEventWithName:@"ThreadMessage"
                                               body:message];
}

- (void)invalidate {
  if (threads == nil) {
    return;
  }

  for (NSNumber *threadId in threads) {
    RCTBridge *threadBridge = threads[threadId];
    [threadBridge invalidate];
  }

  [threads removeAllObjects];
  threads = nil;
}


+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

@end
