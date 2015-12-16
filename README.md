[Archive] OS X Todo
============

**Note:** *This repository is not under active development.*

This is a sample application that showcases the Parse iOS / OS X SDK. It contains an Objective-C solution that shows how easy it is to get started creating and storing data using Parse as your backend for your Cocoa application. It's targeted at 10.7, but the Parse SDK supports apps back to 10.6.

How to Run
----------

1. Clone the repository and open the Xcode project at `TodoList.xcodeproj`.

2. Create an app at [Parse](https://parse.com/apps).

3. Copy your new app's application id and client key into `TDAppDelegate.m`:

  ```objective-c
  [Parse setApplicationId:@"APPLICATION_ID" clientKey:@"CLIENT_KEY"];
  ```
4. Build and run.

