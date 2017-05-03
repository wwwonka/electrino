//
//  AppDelegate.m
//  Electrino
//
//  Created by Pauli Ojala on 03/05/17.
//  Copyright © 2017 Lacquer. All rights reserved.
//

#import "AppDelegate.h"
#import "ENOJavaScriptApp.h"


@interface AppDelegate ()

@end




@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString *appDir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"js-app"];
    NSString *mainJSPath = [appDir stringByAppendingPathComponent:@"main.js"];
    
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:mainJSPath]) {
        NSLog(@"** no main.js found in dir: %@", appDir);
        [NSApp terminate:nil]; // --
    }
    
    NSString *mainJS = [NSString stringWithContentsOfFile:mainJSPath encoding:NSUTF8StringEncoding error:NULL];
    ENOJavaScriptApp *jsApp = [ENOJavaScriptApp sharedApp];
    NSError *error = nil;
    
    // setup
    jsApp.jsContext[@"__dirname"] = appDir;
    
    // load code
    if ( ![jsApp loadMainJS:mainJS error:&error]) {
        NSLog(@"** could not load main.js: %@, path: %@", error, mainJSPath);
        
        [self _presentJSError:error message:@"Main program execution failed."];
        
        [NSApp terminate:nil]; // --
    }
    
    // start
    if ( ![jsApp.jsAppGlobalObject emitReady:&error]) {
        NSLog(@"** app.on('ready'): %@", error);
        
        [self _presentJSError:error message:@"Exception in app.on('ready')"];
    }
}

- (void)_presentJSError:(NSError *)error message:(NSString *)msg
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSCriticalAlertStyle;
    alert.messageText = msg ?: @"JavaScript error";
    alert.informativeText = [NSString stringWithFormat:@"\n%@\n\n(On line %@)", error.localizedDescription, error.userInfo[@"SourceLineNumber"]];
    
    [alert runModal];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    
}


@end
