//
//  ClipLikeUITests.swift
//  ClipLikeUITests
//
//  Created by henery on 2026/2/2.
//

import XCTest
import AppKit

final class ClipLikeUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        let bundleID = "henery.ClipLike"
        let apps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
        for app in apps where !app.isTerminated {
            app.terminate()
        }
        
        let deadline = Date().addingTimeInterval(2.0)
        while Date() < deadline {
            let stillRunning = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).contains { !$0.isTerminated }
            if !stillRunning { break }
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        
        let remaining = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
        for app in remaining where !app.isTerminated {
            app.forceTerminate()
        }

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
