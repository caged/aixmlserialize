#import <Foundation/Foundation.h>
#import "NSXMLElement+Serialize.h"
#import "NSXMLDocument+Serialize.h"

#define COUNT 2500

int main (int argc, const char * argv[]) {
    NSAutoreleasePool *outer = [NSAutoreleasePool new];
    
    NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
    BOOL showOutput = [args boolForKey:@"p"];
    BOOL logOutput = [args boolForKey:@"l"];
    NSString *filename = [args stringForKey:@"f"];
    NSInteger runs = [args integerForKey:@"c"];
    
    if(!runs|| runs <=0)
        runs = 2500;
    
    if (!filename) {
        printf("Usage: %s -f XML File\n Optional: -p to print results, -c how many times to run", argv[0]);
        return 1;
    }
    
    
    NSString *repr = [NSString stringWithContentsOfFile:filename];
    
    NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithXMLString:repr options:NSXMLDocumentValidate error:nil] autorelease];    
    NSDictionary *results;
    NSAutoreleasePool *inner = [NSAutoreleasePool new];
    NSDate *start = [NSDate date];
    for (int i = 0; i < runs; i++) 
    {
        results = [doc toDictionary];
    }
    double duration = -[start timeIntervalSinceNow];
    printf("toDictionary ran %i times in %f seconds\n",  runs, duration);
    if(showOutput)
        NSLog(@"Results:%@", results);
        
    if(logOutput)
        [[results description] writeToFile:@"log.log" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [inner release];
    
    [outer release];
    return 0;
}
