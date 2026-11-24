# TheMilkyWay

## Table of contents
* [General info](#general-info)
* [Technologies](#technologies)
* [Architecture](#architecture)
* [Design choices](#design-choices)
* [Unit tests](#unit-tests)
* [Dependency injection](#dependency-injection)

## General info

This is a sample iOS project created using NASA search image API.

> **Migration in progress:** the app is moving from UIKit, MVVM-C and Combine to SwiftUI, TCA and Swift Concurrency.
> Open `TheMilkyWay.xcworkspace` with Xcode 27.


## Technologies

* iOS 27+
* Swift 6 with strict concurrency
* async/await
* UIKit (moving to SwiftUI)
* Combine (view bindings only, until the SwiftUI migration)


## Architecture

* MVVM-C
* Modular Architecture


## Design choices

I choosed **MVVM** for this sample project for testability and scalability. Preferred the **Coordinator Pattern** to be able to easily handle navigation.
**Modular Architecture** choice is made to be able to define development areas and responsibilities clearer.

* **MVVM**: 
  * Reduced complexity: MVVM makes the view controller simpler by moving a lot of business logic out of it.
  * Expressive: The view model better expresses the business logic for the view.
  * Testability: A view model is much easier to test than a view controller. You end up testing business logic without having to worry about view implementations.
  
* **Coordinator**: 
  * Using the coordinator pattern in iOS apps lets us remove the job of app navigation from our view controllers, helping make them more manageable and more reusable, while also letting us adjust our app's flow whenever we need.

* **Modular**:
  * Less build-time when compiling after a change is made.
  * Clearer development areas/responsibilities.
  * Isolation of changes.


## Unit tests

  Unit tests can be found under the "\(Module)Tests" directory in each module.

## Dependency injection

 1. Feature modules see only the **CoreAPI** protocols (`ImageSearchApi`), never their implementations.
 2. **CoreAPIImpl** talks to NASA over `URLSession`. **CoreAPIStubs** serves offline data for tests and previews.
 3. The app target picks one at launch in `AppInterface` and passes it down to the screens.
