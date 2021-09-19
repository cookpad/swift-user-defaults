/// MIT License
///
/// Copyright (c) 2021 Liam Nichols
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import ExampleKit
import SwiftUserDefaults
import XCTest

class ExampleUITests: XCTestCase {
    func testNoItemsPlaceholder() {
        // Configure UserDefaults to ensure that there are no items
        // Use the UserDefaults.Key constants from ExampleKit to keep test code in sync
        let userDefaults: [UserDefaults.Key: UserDefaultsStorable] = [
            .contentTitle: "Example App",
            .contentItems: Array<Date>()
        ]

        // Launch the app with the user defaults
        let app = XCUIApplication()
        app.launchArguments = UserDefaults.launchArguments(from: userDefaults)
        app.launch()

        // Ensure the placeholder is set properly
        XCTAssertTrue(app.navigationBars["Example App"].exists)
        XCTAssertTrue(app.staticTexts["No Items"].exists)
    }

    func testDeleteItem() {
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2021, month: 6, day: 1, hour: 9, minute: 10))!

        // Configure UserDefaults to contain items with known dates
        // Use 'String' keys for a simplified extension (avoiding UserDefaults.Key)
        let userDefaults: [String: UserDefaultsStorable] = [
            "AppleLanguages": ["fr_FR"],
            "ContentTitle": "Example App",
            "ContentItems": [
                startDate,
                calendar.date(byAdding: .day, value: 1, to: startDate)!,
                calendar.date(byAdding: .day, value: 2, to: startDate)!,
                calendar.date(byAdding: .day, value: 3, to: startDate)!,
                calendar.date(byAdding: .day, value: 4, to: startDate)!,
                calendar.date(byAdding: .day, value: 5, to: startDate)!
            ]
        ]

        // Launch the app with the user defaults
        let app = XCUIApplication()
        app.launchArguments = UserDefaults.launchArguments(from: userDefaults)
        app.launch()

        // Find a known cell, ensure it exists
        let fourthJune = app.staticTexts["4 juin 2021 à 09:10"]
        XCTAssertTrue(fourthJune.exists)

        // Swipe to delete
        fourthJune.swipeLeft()
        app.buttons["Delete"].tap()

        // Confirm deletion
        XCTAssertFalse(fourthJune.exists)
    }
}
