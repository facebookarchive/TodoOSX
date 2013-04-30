//
//  TDAuthWindowController.h
//  TodoList
//
//  Created by Christine Yen on 11/13/12.
//

#import <Cocoa/Cocoa.h>

@interface TDAuthWindowController : NSWindowController

// Button / View / Fields related to the signup form and revealing it
@property (weak) IBOutlet NSButton *signupToggle;
@property (weak) IBOutlet NSView *signupView;
@property (weak) IBOutlet NSTextField *signupEmailField;
@property (weak) IBOutlet NSTextField *signupUsernameField;
@property (weak) IBOutlet NSSecureTextField *signupPasswordField;

// Button / View / Fields related to the login form and revealing it
@property (weak) IBOutlet NSButton *loginToggle;
@property (weak) IBOutlet NSView *loginView;
@property (weak) IBOutlet NSTextField *loginEmailField;
@property (weak) IBOutlet NSSecureTextField *loginPasswordField;

// Button / View / Fields related to the Forgot Password form and revealing it
@property (weak) IBOutlet NSButton *forgotToggle;
@property (weak) IBOutlet NSView *forgotPasswordView;
@property (weak) IBOutlet NSTextField *forgotEmailField;
@end
