//
//  ZNLog.m
//
//  Created by Li Richard on 09-6-23.
//

<<<<<<< HEAD
#import "ZNLog.h"
=======
#import "ZNLogARC.h"
>>>>>>> b35e44774213d6200baacc78e4c21b291823afe0


@implementation ZNLogARC

+ (void)file:(char*)sourceFile function:(char*)functionName lineNumber:(int)lineNumber format:(NSString*)format, ...
{
    va_list ap;
    NSString *print, *file, *function;
    va_start(ap,format);
    file = [[NSString alloc] initWithBytes: sourceFile length: strlen(sourceFile) encoding: NSUTF8StringEncoding];
    
    function = [NSString stringWithCString: functionName encoding: NSUTF8StringEncoding ];
    print = [[NSString alloc] initWithFormat: format arguments: ap];
    va_end(ap);
    NSLog(@"%@:%d %@;\n%@", [file lastPathComponent], lineNumber, function, print);
}

@end
