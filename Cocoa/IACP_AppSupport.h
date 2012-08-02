//
//  IACP_AppSupport.h
//  IACP_MAYFIS
//
//  Created by Grace on 12/5/7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IACP_AppSupport : NSObject
{

}

-(id)init;
-(void)dealloc;

- (NSString *)applicationSupportFolder;

//use iacp_bsqldb
- (NSArray *)queryDataUseIACPBsqldb:(NSString *)userName password:(NSString *)passWord servername:(NSString *)serverName dbname:(NSString *)dbName commands:(NSString *)command;

- (NSArray *)queryDataRetWithSemicolon:(NSString *)userName password:(NSString *)passWord servername:(NSString *)serverName dbname:(NSString *)dbName commands:(NSString *)command;

@end
