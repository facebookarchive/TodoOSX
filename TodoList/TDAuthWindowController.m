//
//  TDAuthWindowController.m
//  TodoList
//
//  Created by Christine Yen on 11/13/12.
//

#import "TDAuthWindowController.h"
#import "TDAppDelegate.h"

#import <ParseOSX/Parse.h>

@interface TDAuthWindowController ()
// Hide all authentication views and deselect toggles, in preparation for showing
// a single signup / login / forgot password view.
- (void)hideAllAuthViews;
// Utility method to set a given UIView subclass at a particular Y-coordinate.
- (void)setButton:(UIView *)view atY:(CGFloat)y;
// Helper method to display an NSError from a Parse request.
- (void)displayPFErrorAlert:(NSError *)error;
@end

@implementation TDAuthWindowController

// Y-coordinate constants to move the "Log In" and "Forgot Password" buttons
// around. OS X uses a LLO (lower-left-origin) coordinate system.
static CGFloat kLoginPosition_ModeSignup = 37.0f;
static CGFloat kLoginPosition_ModeLoginForgot = 358.0f;
static CGFloat kForgotPosition_ModeSignupLogin = 0.0f;
static CGFloat kForgotPosition_ModeForgot = 321.0f;

#pragma mark TDAuthWindowController

- (IBAction)showSignup:(id)sender {
    [self hideAllAuthViews];

    [self setButton:self.loginToggle atY:kLoginPosition_ModeSignup];
    [self setButton:self.forgotToggle atY:kForgotPosition_ModeSignupLogin];
    [self.signupView setHidden:NO];
    [self.signupToggle setState:NSOnState];
}

- (IBAction)showLogin:(id)sender {
    [self hideAllAuthViews];

    [self setButton:self.loginToggle atY:kLoginPosition_ModeLoginForgot];
    [self setButton:self.forgotToggle atY:kForgotPosition_ModeSignupLogin];
    [self.loginView setHidden:NO];
    [self.loginToggle setState:NSOnState];
}

- (IBAction)showForgot:(id)sender {
    [self hideAllAuthViews];

    [self setButton:self.loginToggle atY:kLoginPosition_ModeLoginForgot];
    [self setButton:self.forgotToggle atY:kForgotPosition_ModeForgot];
    [self.forgotPasswordView setHidden:NO];
    [self.forgotToggle setState:NSOnState];
}

- (IBAction)signup:(id)sender {
    PFUser *user = [PFUser user];
    user.username = self.signupUsernameField.stringValue;
    user.email = self.signupEmailField.stringValue;
    user.password = self.signupPasswordField.stringValue;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            return [self displayPFErrorAlert:error];
        }

        if (succeeded) {
            // Tell app delegate that the user signed up successfully
            [(TDAppDelegate *)[NSApp delegate] authSuccess];
            return;
        }
        // If, somehow, neither of these cases are true, display an error
        NSAlert *alert = [NSAlert alertWithMessageText:@"App is in an unexpected state! Please try logging in again."
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:nil];
        [alert runModal];
    }];
}

- (IBAction)login:(id)sender {
    [PFUser logInWithUsernameInBackground:self.loginEmailField.stringValue
                                 password:self.loginPasswordField.stringValue
                                    block:^(PFUser *user, NSError *error) {
                                        if (error) {
                                            return [self displayPFErrorAlert:error];
                                        }

                                        // Tell app delegate that the user logged in successfully
                                        [(TDAppDelegate *)[NSApp delegate] authSuccess];
                                    }];
}

- (IBAction)forgotPassword:(id)sender {
    NSString *email = self.forgotEmailField.stringValue;
    [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Password Reset"
                                             defaultButton:@"OK"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"An email with reset instructions has been sent to %@", email];
            [alert runModal];
        } else {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Password Reset Failed"
                                             defaultButton:@"OK"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"The email address %@ is not registered", email];
            [alert runModal];
        }
    }];
}

#pragma mark ()

- (void)hideAllAuthViews {
    for (NSView *view in @[self.signupView, self.loginView, self.forgotPasswordView]) {
        [view setHidden:YES];
    }
    for (NSButton *button in @[self.signupToggle, self.loginToggle, self.forgotToggle]) {
        [button setState:NSOffState];
    }
}

- (void)setButton:(UIView *)view atY:(CGFloat)y {
    NSRect frame = view.frame;
    frame.origin.y = y;
    view.frame = frame;
}

- (void)displayPFErrorAlert:(NSError *)error {
    NSString *message = [[error userInfo] objectForKey:@"error"];
    NSAlert *alert = [NSAlert alertWithMessageText:@"Error logging in"
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"Error: %@", message];
    [alert runModal];
}

@end
