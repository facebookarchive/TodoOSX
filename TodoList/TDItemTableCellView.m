//
//  TDItemTableCellView.m
//  TodoList
//
//  Created by Christine Yen on 11/13/12.
//

#import "TDItemTableCellView.h"

#import <ParseOSX/Parse.h>

@interface TDItemTableCellView ()
@property (strong, nonatomic) NSBox *strikethrough;
@end

@implementation TDItemTableCellView

#pragma mark NSView

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Construct + configure the NSTableView cell's subviews.

        NSRect textFieldRect = NSMakeRect(0.0f, 0.0f, frame.size.width - 50.0f, frame.size.height);
        NSTextField *textField = [[NSTextField alloc] initWithFrame:textFieldRect];
        [textField setBezeled:NO];
        [textField setEditable:YES];
        [self addSubview:textField];
        self.textField = textField;

        NSRect buttonRect = NSMakeRect(frame.size.width - 50.0f, 0.0f, 40.0f, frame.size.height);
        NSButton *button = [[NSButton alloc] initWithFrame:buttonRect];
        button.font = [NSFont boldSystemFontOfSize:20.0f];
        [self addSubview:button];
        self.button = button;
    }

    return self;
}

#pragma mark TDItemTableCellView

- (void)configureWithTodo:(PFObject *)object {
    self.textField.stringValue = [object objectForKey:@"body"];

    if ([object objectForKey:@"done"]) {
        [self.button setTitle:@"☑"];
        [self addSubview:self.strikethrough];
    } else {
        [self.button setTitle:@"☐"];
        [self.strikethrough removeFromSuperview];
    }
}

// Alternatively, we could use a custom NSView subclass to encapsulate custom
// drawing code (via drawRect:) and add that as a subview (after the NSTextField
// and NSButton) to self. We use an NSBox here for simplicity.
- (NSBox *)strikethrough {
    if (_strikethrough == nil) {
        NSRect frame = NSMakeRect(5.0f, self.frame.size.height / 2.0f, self.frame.size.width - 60.0f, 1.0f);
        _strikethrough = [[NSBox alloc] initWithFrame:frame];
        _strikethrough.boxType = NSBoxCustom;
        _strikethrough.borderWidth = 1.0f;
        _strikethrough.borderType = NSLineBorder;
        _strikethrough.borderColor = [NSColor blackColor];
    }
    return _strikethrough;
}

@end
