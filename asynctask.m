/*
 * Copyright 2008-2011, Torsten Curdt
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *
 * Modified by Li Richard on 12-6-03.
 */

#import "asynctask.h"
extern NSString *windowNeedToShowNotification;
void *threadFunction(void *arguments);

// ADDED begin
static int empty_data_count; 
static int task_exit_code;

struct arg_struct {
    NSData *inData;
    NSFileHandle *inHandle;
};

void *threadFunction(void *arguments) 
{
    [[NSAutoreleasePool alloc] init];
    struct arg_struct *taskArgs = arguments;
    [taskArgs -> inHandle writeData: taskArgs -> inData];
    [taskArgs -> inHandle closeFile];
    //[taskArgs -> inHandle release];
    //[taskArgs -> inData release];
    return nil;
}
// ADDED end

@implementation NSFileHandle (CSFileHandleExtensions)

- (NSData *)availableDataOrError:(NSException **)returnError;
{
    for (;;) {
        @try {
            return [self availableData];
        } 
        @catch (NSException *e) {
            
            if ([[e name] isEqualToString:NSFileHandleOperationException]) {
                
                if ([[e reason] isEqualToString:@"*** -[NSConcreteFileHandle availableData]: Interrupted systemcall"]) {
                     continue;
                }
                
                if (returnError)
                    *returnError = e;
                
                return nil;
            }
                     
            @throw;
        }
    }
}
                     
@end
                     
@implementation FRCommandNew

- (id) initWithPath:(NSString*)pPath
{
    self = [super init];
    if (self != nil) 
    {
        task = [[NSTask alloc] init];
        args = [NSArray array];
        path = pPath;
        stdinData = nil;  // ADDED
        error = nil;
        output = nil;
        terminated = NO;
        timeoutSecs = 100000.0;
    }
    
    return self;
    
}

// ADDED
// For "availableDataOrError:" see: 
// - "NSTasks, NSPipes, and deadlocks when reading...",
//    http://dev.notoptimal.net/2007/04/nstasks-nspipes-and-deadlocks-when.html
// - "NSTask stealth bug in readDataOfLength!! :(", 
//    http://www.cocoabuilder.com/archive/cocoa/173348-nstask-stealth-bug-in-readdataoflength.html#173647

-(NSData *) availableDataOrError: (NSFileHandle *)file {
    for (;;) 
    {
        @try {
            return [file availableData];
        } @catch (NSException *e) {
                
            if ([[e name] isEqualToString:NSFileHandleOperationException]) 
            {
                if ([[e reason] isEqualToString: @"*** -[NSConcreteFileHandle availableData]: Interrupted system call"]) 
                {
                    continue;
                }
                return nil;
            }
            ALog(@"exception here");
            @throw;
        }
    }  // for
}

- (void) setArgs:(NSArray*)pArgs
{
    args = pArgs;
}

- (void) setInput:(NSData*)pInput    // ADDED  
{
    stdinData = pInput;
}

- (void) setError:(NSMutableString*)pError
{
    error = pError;
}

- (void) setOutput:(NSMutableString*)pOutput
{
    output = pOutput;
}

- (void) setTimeoutSecs:(int)timeoutSeconds
{
    timeoutSecs = (int)timeoutSeconds;
}

-(void) appendDataFrom:(NSFileHandle*)fileHandle to:(NSMutableString*)string
{
     @try {
         
    NSData *data = [self availableDataOrError: fileHandle];
    //NSData *data = [fileHandle availableData];
    if ([data length]) {
        NSString *s = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding: NSUTF8StringEncoding];
        //NSString *s = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding: NSASCIIStringEncoding];
        [string appendString:s];
        [[NSNotificationCenter defaultCenter] postNotificationName:windowNeedToShowNotification object:s];
        //NSLog(@"| %@", s);
        [s release];
        //[fileHandle waitForDataInBackgroundAndNotify];
    }else{
        empty_data_count += 1;
        if (empty_data_count > 10)
        {   
            //[task interrupt];   // failed to abort infinite NSRunLoop
            //[task terminate];   // same
            [[NSNotificationCenter defaultCenter] removeObserver:self];  // only way to abort infinite NSRunLoop ???
        }
    }
    
    [fileHandle waitForDataInBackgroundAndNotify];
     }
    @catch (NSException *exception) {
        NSRunAlertPanel(@"Exception", [NSString stringWithFormat:@"Error: %@", [exception reason]],@"OK",nil,nil);
        return ;
    }
    
    
}

-(void) outData: (NSNotification *) notification
{
    NSFileHandle *fileHandle = (NSFileHandle*) [notification object];
    [self appendDataFrom:fileHandle to:output];
    //DLog(@"outData:%@",output);
    [fileHandle waitForDataInBackgroundAndNotify];
}

-(void) errData: (NSNotification *) notification
{
    NSFileHandle *fileHandle = (NSFileHandle*) [notification object];
    [self appendDataFrom:fileHandle to:error];
    //DLog(@"errData:%@",error);
    [fileHandle waitForDataInBackgroundAndNotify];
}

- (void) terminated: (NSNotification *)notification
{
    NSLog(@"Task terminated");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    terminated = YES;
}

- (int) execute
{
    @try{
        
        int result = 1;
        empty_data_count = 0;
    
        [task setLaunchPath:path];
        [task setArguments:args];
        DLog([task launchPath]);
    
        BOOL exists = [[NSFileManager defaultManager] isExecutableFileAtPath:[task launchPath]];
        
        if (NO == exists)
            return 1;
        NSPipe *outPipe = [NSPipe pipe];
        NSPipe *errPipe = [NSPipe pipe];
        [task setStandardOutput:outPipe];
        [task setStandardError:errPipe];
        [task setCurrentDirectoryPath:@"."];  // ADDED
    
        //NSFileHandle *outFile = [outPipe fileHandleForReading];   // TROUBLEMAKER
        //NSFileHandle *errFile = [errPipe fileHandleForReading];
        outFile = [outPipe fileHandleForReading];
        //errFile = [errPipe fileHandleForReading];
    
        //  ADDED
        // create inPipe after outPipe & errPipe
        NSPipe *inPipe = [NSPipe pipe];     
        stdinHandle = [inPipe fileHandleForWriting];
    
        [task setStandardInput:inPipe];
    
        struct arg_struct taskArguments;
        taskArguments.inData = stdinData;
        taskArguments.inHandle = stdinHandle;
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(terminated:)
                                                     name:NSTaskDidTerminateNotification
                                                   object:task];
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(outData:)
                                                     name:NSFileHandleDataAvailableNotification
                                                   object:outFile];
    
       // [[NSNotificationCenter defaultCenter] addObserver:self
         //                                        selector:@selector(errData:)
           //                                          name:NSFileHandleDataAvailableNotification
             //                                      object:errFile];
    
    
        [outFile waitForDataInBackgroundAndNotify];
        //[errFile waitForDataInBackgroundAndNotify];
    
        [task launch];
    
        // ADDED
        pthread_t thread = nil;
    
        if (pthread_create(&thread, nil, (void *(*)(void *))threadFunction, (void *)&taskArguments) != 0)
        {
            perror("pthread_create failed");
            return 1;
        }
    
        if (pthread_detach(thread) != 0)
        {
            perror("pthread_detach failed");
            return 1;
        } 
    
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        sleep(1);
        DLog(@"Execute task in %d seconds",(int)timeoutSecs);
        NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
        BOOL runningStatus = NO;
    while((!runningStatus)||[task isRunning]) 
    {
        if([timeoutDate timeIntervalSinceNow] < 0.0) {
            DLog(@"Time out. Jump from Loop");
            break;
        }
        
        if (![[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate])
        //if (![[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) 
        {
            DLog(@"RunLoop Error. Jump from Loop");
            break;
        }
        if (NO == runningStatus)
            runningStatus = YES;

    }
    
    [pool release];

    if (![task isRunning]) {
        result = [task terminationStatus];
        if (result == ATASK_SUCCESS_VALUE) {
            DLog(@"Task succeeded.");
            
            //[self appendDataFrom:outFile to:output];
            //[self appendDataFrom:errFile to:error];
            
            result = 0;
        }
        else {
            DLog(@"Task failed. Error:%d",result);
            [error appendString:@"Task failed."];
        }
    }
    else {
        DLog(@"Exit with timeout.");
        [error appendString:@"Exit with timeout."];
        result = 1;
    }
    
    task_exit_code = result;
 
        
    return result;
    
    }
    @catch (NSException *exception) {
        NSRunAlertPanel(@"Exception", [NSString stringWithFormat:@"Error: %@", [exception reason]],@"OK",nil,nil);
        return 1;
    }
    
    
}

-(void)dealloc
{
    [task release];
    [super dealloc];
}


@end
