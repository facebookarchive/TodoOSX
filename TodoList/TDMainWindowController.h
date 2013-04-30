//
//  TDMainWindowController.h
//  TodoList
//
//  Created by Christine Yen on 11/1/12.
//

#import <Cocoa/Cocoa.h>

@interface TDMainWindowController : NSWindowController<NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate>

// The text field at the top of the window, into which users can type new To-Dos.
@property (weak) IBOutlet NSTextField *todoField;

// A button which, when clicked, will create a new To-Do from todoField.
@property (weak) IBOutlet NSButton *addButton;

// The NSTableView making up the main portion of the UI. This controller
// is both the Delegate and DataSource for this NSTableView.
@property (weak) IBOutlet NSTableView *tableView;

@end
