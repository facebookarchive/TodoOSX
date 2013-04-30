//
//  TDAppDelegate.m
//  TodoList
//
//  Created by Christine Yen on 11/1/12.
//

#import "TDAppDelegate.h"
#import "TDMainWindowController.h"
#import "TDAuthWindowController.h"

#import <ParseOSX/Parse.h>

@implementation TDAppDelegate

#pragma mark NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // ****************************************************************************
    // Uncomment and fill in with your Parse credentials:
    // [Parse setApplicationId:@"your_application_id" clientKey:@"your_client_key"];
    // ****************************************************************************

    PFACL *defaultACL = [PFACL ACL];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

    // Launch the Authentication window if no user is logged in.
    if ([PFUser currentUser]) {
        [self.mainWindowController showWindow:self];
    } else {
        [self.authWindowController showWindow:self];
    }
}

#pragma mark TDAppDelegate

- (void)authSuccess {
    [[self.authWindowController window] close];
    self.authWindowController = nil;
    [self.mainWindowController showWindow:self];
}

- (IBAction)closeWindow:(id)sender {
    [[NSApp keyWindow] performClose:self];
}

- (IBAction)logout:(id)sender {
    [PFUser logOut];

    // Clean up state - close the main window and allow users to log in / sign up
    // as a different user.
    [[self.mainWindowController window] close];
    self.mainWindowController = nil;
    [self.authWindowController showWindow:self];
}

- (TDMainWindowController *)mainWindowController {
    if (_mainWindowController == nil) {
        _mainWindowController = [[TDMainWindowController alloc] initWithWindowNibName:@"TDMainWindowController"];
    }
    return _mainWindowController;
}

- (TDAuthWindowController *)authWindowController {
    if (_authWindowController == nil) {
        _authWindowController = [[TDAuthWindowController alloc] initWithWindowNibName:@"TDAuthWindowController"];
    }
    return _authWindowController;
}

@end
