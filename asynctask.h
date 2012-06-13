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
 * limitations under the License.
 * 
 * Modified by Li Richard on 12-6-03.
 */

//#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <unistd.h>
#import <pthread.h>
#import <stdio.h>

#define ATASK_SUCCESS_VALUE 0

@interface FRCommandNew : NSObject {
    
    NSTask *task;
    NSString *path;
    NSArray *args;
    NSData *stdinData;   // ADDED
    NSMutableString *output;
    NSMutableString *error;
    BOOL terminated;
    NSFileHandle *outFile;
    NSFileHandle *errFile;
    NSFileHandle *stdinHandle;  // ADDED
    NSTimeInterval timeoutSecs; 
    
}


-(NSData *) availableDataOrError: (NSFileHandle *)file;
- (id) initWithPath:(NSString*)path;
- (void) setArgs:(NSArray*)args;
- (void) setInput:(NSData*)stdinData;        // ADDED
- (void) setError:(NSMutableString*)error;
- (void) setOutput:(NSMutableString*)output;
- (void) setTimeoutSecs:(int)timeoutSeconds;
- (int) execute;

@end
