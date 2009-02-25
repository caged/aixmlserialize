#import <Foundation/Foundation.h>
#import "NSXMLElement+Serialize.h"
#import "NSXMLDocument+Serialize.h"

#define COUNT 500

int main (int argc, const char * argv[]) {
    NSAutoreleasePool *outer = [NSAutoreleasePool new];
    
    NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
    BOOL showOutput = [args boolForKey:@"p"];
    NSString *filename = [args stringForKey:@"f"];
    
    if (!filename) {
        printf("Usage: %s -f XML File\n Optional: -p to print results", argv[0]);
        return 1;
    }
    
    NSString *repr = [NSString stringWithContentsOfFile:filename];
    
    NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithXMLString:repr options:NSXMLDocumentValidate error:nil] autorelease];    
    NSDictionary *results;
    NSAutoreleasePool *inner = [NSAutoreleasePool new];
    NSDate *start = [NSDate date];
    for (int i = 0; i < COUNT; i++) 
    {
        results = [doc toDictionary];
        [doc toDictionary];
        [doc toDictionary];
        [doc toDictionary];
        [doc toDictionary];
    }
    double duration = -[start timeIntervalSinceNow];
    printf("toDictionary ran 2500 times in %f seconds\n",  duration);
    if(showOutput)
        NSLog(@"Results:%@", results);
    [inner release];
    
    [outer release];
    return 0;
}
