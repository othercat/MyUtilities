//
//  ZNLog.m
//
//  Created by Li Richard on 09-6-23.
//

#import "ZNLog.h"


@implementation ZNLog

+ (void)file:(char*)sourceFile function:(char*)functionName lineNumber:(int)lineNumber format:(NSString*)format, ...
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    va_list ap;
    NSString *print, *file, *function;
    va_start(ap,format);
    file = [[NSString alloc] initWithBytes: sourceFile length: strlen(sourceFile) encoding: NSUTF8StringEncoding];
    
    function = [NSString stringWithCString: functionName encoding: NSUTF8StringEncoding ];
    print = [[NSString alloc] initWithFormat: format arguments: ap];
    va_end(ap);
    NSLog(@"%@:%d %@;\n%@", [file lastPathComponent], lineNumber, function, print);
    [print release];
    [file release];
    [pool release];
}

@end
