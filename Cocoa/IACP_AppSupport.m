//
//  IACP_AppSupport.m
//  IACP_MAYFIS
//
//  Created by Grace on 12/5/7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "IACP_AppSupport.h"

@implementation IACP_AppSupport


-(id)init
{
    self = [super init];
	if(!self)
		return nil;
	return self;
}

-(void)dealloc
{
	[super dealloc];
}


// 取得 IAC folder 路徑
- (NSString *)applicationSupportFolder
{
    NSString *UsersFolder = nil;
	NSString *IACFolder = nil;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSUserDirectory, NSAllDomainsMask, YES);
	
	if ( [paths count] == 0)
	{
		NSRunAlertPanel(@"Alert", @"Can't find Users folder", @"Quit", nil, nil);
	}
	else 
	{
		UsersFolder = [[paths objectAtIndex:0] stringByAppendingPathComponent:NSUserName()];
		IACFolder = [UsersFolder stringByAppendingPathComponent:@"IAC"];
	}
    
	//NSString *applicationSupportFolder = @"/Users/local/IAC";
	
	return IACFolder;
}


// use iacp_bsqldb
// 將 DB 回傳的結果以 \n 分割,存放於Array並回傳 
- (NSArray *)queryDataUseIACPBsqldb:(NSString *)userName password:(NSString *)passWord servername:(NSString *)serverName dbname:(NSString *)dbName commands:(NSString *)command
{
        NSTask *task = [[NSTask alloc] init];	
        
        //[task setLaunchPath:@"/usr/local/freetds/bin/iacp_bsqldb"];
        [task setLaunchPath:@"/usr/local/freetds/bin/bsqldb"];
        NSArray *args = [NSArray arrayWithObjects:@"-U", userName, @"-P", passWord, @"-S", serverName, @"-D", dbName, @"-I", command, nil];
        [task setArguments:args];
        
        // Create a new pipe
        NSPipe *pipe = [[NSPipe alloc] init];
        [task setStandardOutput:pipe];
        
        NSPipe *pipeErr = [[NSPipe alloc] init];
        [task setStandardError:pipeErr];
        
        // Star the process
        [task launch];
        
        NSData *dataErr = [[pipeErr fileHandleForReading] readDataToEndOfFile];
        NSString *aStringErr = [[NSString alloc] initWithData:dataErr encoding:NSUTF8StringEncoding];
        NSLog(@"%@",aStringErr);
        
        // Read the output
        NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
        
        [task waitUntilExit];
        [task release];
            
        // Convert to a string
        NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
        // Break the string into lines
        NSArray *queryDatas = [aString componentsSeparatedByString:@"\n"];
        
        [aString release];
        [pipe release];
        return queryDatas;    
}


// use iacp_bsqldb
// 將 DB 回傳的結果以 ; 分割,存放於Array並回傳 
- (NSArray *)queryDataRetWithSemicolon:(NSString *)userName password:(NSString *)passWord servername:(NSString *)serverName dbname:(NSString *)dbName commands:(NSString *)command
{	
        NSTask * task = [[NSTask alloc] init];
        //[task setLaunchPath:@"/usr/local/freetds/bin/iacp_bsqldb"];
        [task setLaunchPath:@"/usr/local/freetds/bin/bsqldb"];
        NSArray *args = [NSArray arrayWithObjects:@"-U", userName, @"-P", passWord, @"-S", serverName, @"-D", dbName, @"-I", command, nil];
        [task setArguments:args];
        
        // Create a new pipe
        NSPipe *pipe = [[NSPipe alloc] init];
        [task setStandardOutput:pipe];
        
        NSPipe *pipeErr = [[NSPipe alloc] init];
        [task setStandardError:pipeErr];
        
        // Star the process
        [task launch];
        
        NSData *dataErr = [[pipeErr fileHandleForReading] readDataToEndOfFile];
        NSString *aStringErr = [[NSString alloc] initWithData:dataErr encoding:NSUTF8StringEncoding];
        NSLog(@"%@",aStringErr);
        
        // Read the output
        NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
        
        [task waitUntilExit];
        [task release];
        
        // Convert to a string
        NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        // Break the string into lines
        NSArray *queryDatas = [aString componentsSeparatedByString:@";"];
		
        [aString release];
        [pipe release];
        return queryDatas;	
}

@end
