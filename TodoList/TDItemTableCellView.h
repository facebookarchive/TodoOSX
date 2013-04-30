//
//  TDItemTableCellView.h
//  TodoList
//
//  Created by Christine Yen on 11/13/12.
//

#import <Cocoa/Cocoa.h>

@class PFObject;

@interface TDItemTableCellView : NSView
// The editable text field displaying the body of the To-Do item.
@property (weak, nonatomic) NSTextField *textField;

// The button allowing users to mark a given To-Do as "done" or "not done."
@property (weak, nonatomic) NSButton *button;

// Update UI based on the PFObject that this view represents.
- (void)configureWithTodo:(PFObject *)object;

@end
