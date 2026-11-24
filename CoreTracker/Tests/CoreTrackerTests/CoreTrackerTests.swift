//
//  CoreTrackerTests.swift
//  CoreTrackerTests
//

import CoreTracker
import Synchronization
import Testing
@testable import CoreTrackerImpl

struct CoreTrackerTests {

    // MARK: Events

    @Test(arguments: [
        (TrackerEvent.ui(.screenView(screen: .explore)), "screen_view {screen_name: explore}"),
        (.ui(.screenView(screen: .imageDetails)), "screen_view {screen_name: image_details}"),
        (
            .error(.errorShown(error: "network.offline", presentation: .header, screen: .favorites)),
            "error_shown {error: network.offline, presentation: header, screen_name: favorites}"
        ),
        (
            .error(.errorShown(error: "storage", presentation: .toast, screen: nil)),
            "error_shown {error: storage, presentation: toast}"
        ),
        (.product(.favoriteAdded(imageID: "PIA12235")), "favorite_added {image_id: PIA12235}"),
        (.product(.favoriteRemoved(imageID: "PIA12235")), "favorite_removed {image_id: PIA12235}"),
        (.product(.search(queryLength: 4)), "search {query_length: 4}"),
    ])
    func eventsHaveStableNamesAndParams(event: TrackerEvent, expected: String) {
        #expect(LogTrackerProvider.text(for: event) == expected)
    }

    // MARK: Service

    @Test func serviceSendsEveryEventToEachProviderInOrder() {
        let first = SpyProvider()
        let second = SpyProvider()
        let service = TrackerServiceImpl(providers: [first, second])
        let events: [TrackerEvent] = [.ui(.screenView(screen: .explore)), .product(.search(queryLength: 4))]

        events.forEach(service.track)

        #expect(first.events == events)
        #expect(second.events == events)
    }
}

private final class SpyProvider: TrackerProvider {

    private let recorded = Mutex<[TrackerEvent]>([])

    var events: [TrackerEvent] { recorded.withLock { $0 } }

    func track(_ event: TrackerEvent) {
        recorded.withLock { $0.append(event) }
    }
}
