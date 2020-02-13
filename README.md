# NYTViewer

Test coding app for a simple NY Times article viewer

This is a simple application for pulling down article lists from the NY Times API and displaying them.

## Build Requirements

- Xcode 11
- There are no external or third-party frameworks, so no Cocoapods or Carthage.
- iOS 13 device/simulator

## Architecture

All business logic is extracted into separate controllers.  If the controller is for general use, it will be located under the `Controllers` folder.  Otherwise, component specific controllers are located under the folder for that specific component: `Components` -> `<component name>`

UI is managed using a Composer/Router design.  When the app is first started, it creates a "MainRouter" which is responsible for creating initializing the appropriate datasources, creating the root view controller, and loading it into a provided UIWindow (used to be in `AppDelegate`, but now is done in `SceneDelegate`).  The main router is responsible for providing the View Controllers with the requisite datasource(s) and an object that can handle routing needs (which is normally the itself).

No ViewController should ever be aware of any other.  Instead, "routing" needs should be handled by protocol, and provided in the init (stored as weak reference to avoid retain cycles). This allows for full decoupling of the UI components and makes them "composable".  So, for instance, instead of a ViewController referencing its navigation controller and manually pushing another view controller in response to user input (ex: tapping on an article), it instead asks the router to handle it.  

All controller dependencies must be declared as protocols and provided in the `init` (direct dependency injection).  This allows for mocks to be easily injected for testing purposes.

## Known Issues

- There is a mismatch between the objects use and the API requirements.  This can lead to invalid API calls, which will return an error.  
- There is no Article Viewer (yet)

## TODOs

- Add Unit Tests
- Create Article Viewer.
- UI Needs polishing
- Fix api sections for Top stories.
- Finish documenting code
