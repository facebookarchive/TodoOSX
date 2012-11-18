OS X Todo
============

This is a sample application that showcases the Parse iOS / OS X SDK. It contains an Objective-C solution that shows how easy it is to get started creating and storing data using Parse as your backend for your Cocoa application.

How to Run
----------

1. Clone the repository and open the Xcode project at `TodoList.xcodeproj`.

2. Create an app at [Parse](https://parse.com/apps).

3. Copy your new app's application id and client key into `TDAppDelegate.m`:

  ```objective-c
  [Parse setApplicationId:@"APPLICATION_ID" clientKey:@"CLIENT_KEY"];
  ```
4. Build and run.

