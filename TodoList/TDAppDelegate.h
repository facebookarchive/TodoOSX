//
//  TDAppDelegate.h
//  TodoList
//
//  Created by Christine Yen on 11/1/12.
//

#import <Cocoa/Cocoa.h>

@class TDMainWindowController, TDAuthWindowController;

@interface TDAppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) TDMainWindowController *mainWindowController;
@property (strong, nonatomic) TDAuthWindowController *authWindowController;

// Called on a successful signup or login - opens the main window of the app,
// which expects a currentUser.
- (void)authSuccess;

@end
