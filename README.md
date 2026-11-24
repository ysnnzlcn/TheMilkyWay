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

Browse and search NASA's images, and keep favorites on your phone.

> **Work in progress:** more is coming. Open `TheMilkyWay.xcworkspace` with Xcode 27.


## Technologies

* iOS 27+
* Swift 6 with strict concurrency
* SwiftUI
* The Composable Architecture (TCA)
* async/await
* SwiftData
* Swift Testing


## Architecture

* The Composable Architecture
* Modular Architecture (local Swift packages)


## Design choices

* **TCA**: every screen's state and logic sit in a reducer, tested with `TestStore`, separate from its SwiftUI view.

* **Modular**:
  * Less build-time when compiling after a change is made.
  * Clearer development areas/responsibilities.
  * Isolation of changes.


## Unit tests

  Unit tests can be found under the "\(Module)Tests" directory in each module.

## Dependency injection

 1. Feature modules see only the **CoreAPI** protocols (`ImageSearchApi`), never their implementations.
 2. **CoreAPIImpl** talks to NASA over `URLSession`. **CoreAPIStubs** serves offline data for tests.
 3. The app target picks one at launch in `AppInterface`. Each feature module declares what it needs, and its
    reducers read it through TCA dependencies, replaced by mocks in tests.
