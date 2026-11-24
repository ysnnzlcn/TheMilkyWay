//
//  FirebaseTrackerProvider.swift
//  CoreTrackerImpl
//

import CoreTracker

/// Where Firebase Analytics will plug in. Empty for now: the app has no Firebase project yet.
///
/// To turn it on:
/// 1. Add the Firebase Analytics package to this module only (`CoreTrackerImpl`), never to `CoreTracker` or a feature
///    module, so its types never leave this file.
/// 2. Call `FirebaseApp.configure()` once, when the provider is created.
/// 3. In `track(_:)`, send `event.asTrackable.eventName` with `params` through `Analytics.logEvent(_:parameters:)`.
///    For `.ui(.screenView)` use Firebase's `AnalyticsEventScreenView` with the screen name, so its screen reports
///    work.
/// Nothing else in the app changes: screens and reducers only know `TrackerService`.
struct FirebaseTrackerProvider: TrackerProvider {

    func track(_ event: TrackerEvent) {
        // Intentionally empty until Firebase is added (see above).
    }
}
