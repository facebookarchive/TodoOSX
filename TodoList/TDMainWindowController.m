//
//  TDMainWindowController.m
//  TodoList
//
//  Created by Christine Yen on 11/1/12.
//

#import "TDMainWindowController.h"
#import "TDItemTableCellView.h"

#import <ParseOSX/Parse.h>

typedef enum {
    // Corresponds to the 1st segment of the segmented control: "All" todos
    TD_ViewModeAll,
    // Corresponds to the 2nd segment of the segmented control: "Pending" todos
	TD_ViewModePending,
    // Corresponds to the 2nd segment of the segmented control: "Done" todos
	TD_ViewModeDone
} TD_ViewMode;

@interface TDMainWindowController ()
@property (nonatomic) TD_ViewMode mode;
@property (strong, nonatomic) NSMutableArray *data;

- (void)doneButtonClicked:(id)sender;
- (void)refreshTodos:(void(^)(void))callback;
@end

@implementation TDMainWindowController

static const CGFloat kCellHeight = 20.0f;

#pragma mark NSWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName {
    if (self = [super initWithWindowNibName:windowNibName]) {
        self.data = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    // Configure the visual style of the NSTableView
    self.tableView.rowHeight = kCellHeight;
    self.tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
    self.tableView.gridStyleMask = NSTableViewDashedHorizontalGridLineMask;

    // Kick off a Parse fetch of To-Dos.
    [self refreshTodos:nil];
}

#pragma mark - NSTextDelegate methods

// This method is called if editing ends in either the "Todo entry" text field
// or any of the text fields displaying To-Dos in the NSTableView.
//
// If editing ends in the "Todo entry" field, we try to create a new To-Do;
// otherwise we try to update or delete the edited To-Do.
- (void)controlTextDidEndEditing:(NSNotification *)notification {
    NSTextField *field = [notification object];
    if (self.todoField == field) {
        [self addItem:self];
        return;
    }

    NSInteger row = [self.tableView rowForView:[field superview]];
    if (row < 0) {
        // Invalid row index - this cellView is not a subview of a table row.
        return;
    }

    PFObject *object = [self.data objectAtIndex:row];
    if ([field.stringValue isEqualToString:[object objectForKey:@"body"]]) {
        // If the To-Do's text has not changed, consider this a no-op.
        return;
    }

    if ([field.stringValue length] == 0) {
        // If the user cleared the body of the To-Do, treat like a deletion
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self.data removeObject:object];
                [self refreshTodos:nil];
            }
        }];
        return;
    }

    NSString *oldBody = [object objectForKey:@"body"];
    [object setObject:[field stringValue] forKey:@"body"];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            // Revert state on save error.
            [object setObject:oldBody forKey:@"body"];
            field.stringValue = oldBody;
        }
    }];
}

#pragma mark - NSTableViewDataSource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.data count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    static NSString *cellIdentifier = @"TodoCellView";

    // Get an existing cell with the TodoCellView identifier if it exists
    TDItemTableCellView *result = [tableView makeViewWithIdentifier:cellIdentifier owner:self];

    PFObject *object = [self.data objectAtIndex:row];
    if (result == nil) { // It doesn't exist, create a new one
        // New Cell with the width of the table. Note that height doesn't matter,
        // as the tableView's rowHeight will override the height. If this app
        // wasn't ARC-enabled, we would want to make sure this cell was returned
        // as an autoreleased object.
        NSRect cellFrame = NSMakeRect(0.0f, 0.0f, self.tableView.frame.size.width, kCellHeight);
        result = [[TDItemTableCellView alloc] initWithFrame:cellFrame];
        result.identifier = cellIdentifier;

        // Allow this controller to listen for the textField's didEndEditing events
        result.textField.delegate = self;

        // Connect this controller's -doneButtonClicked: as the "done" button's action
        result.button.target = self;
        result.button.action = @selector(doneButtonClicked:);
    }
    [result configureWithTodo:object];

    return result;
}

#pragma mark TDMainWindowController

// Triggered when the user either clicks the "Add" button to add a new To-Do,
// or ends editing in the text field. Creates a new To-Do and handles related UI
// changes.
- (IBAction)addItem:(id)sender {
    NSString *todoValue = self.todoField.stringValue;
    if ([todoValue length] == 0) {
        // Do nothing if the text field is empty.
        return;
    }

    // Temporarily disable the UI while the app is saving.
    [self.todoField setEnabled:NO];
    [self.addButton setEnabled:NO];

    // Create a new PFObject to represent this To-Do item.
    PFObject *todo = [PFObject objectWithClassName:@"Todo"];
    [todo setObject:todoValue forKey:@"body"];
    [todo setObject:[PFUser currentUser] forKey:@"user"];
    [todo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // Kick off the new query, refresh the table, and then - once that's all
        // taken care of - re-enable the item entry UI.
        [self refreshTodos:^{
            self.todoField.stringValue = @"";
            [self.todoField setEnabled:YES];
            [self.addButton setEnabled:YES];
        }];
    }];
}

// Triggered by a click on the "All | Pending | Done" segmented control. Sets
// the app's "mode" and refreshes our data if necessary.
- (IBAction)segmentedControlClicked:(id)sender {
    NSInteger clickedSegment = [sender selectedSegment];
    if (self.mode == clickedSegment) {
        return;
    }
    self.mode = clickedSegment;
    [self refreshTodos:nil];
}

#pragma mark ()

// Triggered by a click on a To-Do's "mark as (un)done" button. Sets the
// "done' status of a To-Do and refreshes the visual appearance of the table
// row.
- (void)doneButtonClicked:(id)sender {
    TDItemTableCellView *cellView = (TDItemTableCellView *)[sender superview];
    NSInteger row = [self.tableView rowForView:cellView];
    if (row < 0) {
        // Invalid row index - this cellView is not a subview of a table row.
        return;
    }

    PFObject *object = [self.data objectAtIndex:row];
    NSDate *oldDone = [object objectForKey:@"done"];
    if (oldDone) {
        [object removeObjectForKey:@"done"];
    } else {
        [object setObject:[NSDate date] forKey:@"done"];
    }
    [cellView configureWithTodo:object];

    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            // If saving the new "done" state fails, reset its status and update
            // the UI.
            [object setObject:oldDone forKey:@"done"];
            [cellView configureWithTodo:object];
        }
    }];
}

// Encapsulates everything around fetching fresh data from Parse - constructing
// the PFQuery, fetching the items, updating our local data structures, and
// finally refreshing the NSTableView. This method also takes a callback, in
// order to trigger post-refresh behavior (like updating UI, in the case of
// creating a new To-Do).
- (void)refreshTodos:(void (^)(void))callback {
    PFQuery *query = [PFQuery queryWithClassName:@"Todo"];

    // If no objects are loaded into memory, we look at the cache first to try
    // and fill the table before querying against the network.
    if ([self.data count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query orderByAscending:@"createdAt"];
    if (self.mode == TD_ViewModePending) {
        [query whereKeyDoesNotExist:@"done"];
    } else if (self.mode == TD_ViewModeDone) {
        [query whereKeyExists:@"done"];
    }

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (query.cachePolicy != kPFCachePolicyCacheOnly && error.code == kPFErrorCacheMiss) {
            // No-op on cache miss - since the policy is not CacheOnly, this
            // block will be called again upon receiving results from the network.
            return;
        }

        [self.data removeAllObjects];
        [self.data addObjectsFromArray:objects];
        [self.tableView reloadData];
        if (callback) {
            callback();
        }
    }];
}

@end
