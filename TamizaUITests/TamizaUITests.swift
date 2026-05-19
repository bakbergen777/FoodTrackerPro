//
//  TamizaUITests.swift
//  TamizaUITests
//
//  Created by AI Assistant on 2025-07-28.
//

import XCTest

final class TamizaUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }

    // MARK: - Basic App Launch Tests
    
    func testAppLaunch() throws {
        // Test that the app launches successfully
        XCTAssertTrue(app.staticTexts["Tamiza"].exists)
        XCTAssertTrue(app.buttons["plus.circle.fill"].exists)
    }
    
    func testMainUIElements() throws {
        // Test that main UI elements are present
        XCTAssertTrue(app.staticTexts["Tamiza"].exists, "App title should be visible")
        XCTAssertTrue(app.staticTexts["Daily Total"].exists, "Daily total section should be visible")
        XCTAssertTrue(app.staticTexts["Today's Meals"].exists, "Today's meals section should be visible")
    }
    
    // MARK: - Add Meal Flow Tests
    
    func testAddMealFlow() throws {
        // UI flow: open app → add meal → confirm
        
        // Step 1: Tap the add button
        let addButton = app.buttons["plus.circle.fill"]
        XCTAssertTrue(addButton.exists, "Add button should exist")
        addButton.tap()
        
        // Step 2: Verify Add Meal view is presented
        XCTAssertTrue(app.navigationBars["Add Meal"].exists, "Add Meal navigation bar should be visible")
        XCTAssertTrue(app.staticTexts["Meal Information"].exists, "Meal Information section should be visible")
        XCTAssertTrue(app.staticTexts["Nutrition Facts"].exists, "Nutrition Facts section should be visible")
        
        // Step 3: Fill in meal details
        let nameField = app.textFields["Enter meal name"]
        XCTAssertTrue(nameField.exists, "Name field should exist")
        nameField.tap()
        nameField.typeText("Test Meal")
        
        // Fill in nutrition values
        let caloriesField = app.textFields["0"].firstMatch
        caloriesField.tap()
        caloriesField.typeText("250")
        
        // Find and fill protein field
        let proteinField = app.textFields.matching(identifier: "0.0").element(boundBy: 0)
        proteinField.tap()
        proteinField.typeText("20.5")
        
        // Find and fill fat field
        let fatField = app.textFields.matching(identifier: "0.0").element(boundBy: 1)
        fatField.tap()
        fatField.typeText("8.0")
        
        // Find and fill carbs field
        let carbsField = app.textFields.matching(identifier: "0.0").element(boundBy: 2)
        carbsField.tap()
        carbsField.typeText("25.0")
        
        // Step 4: Save the meal
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.exists, "Save button should exist")
        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled with valid data")
        saveButton.tap()
        
        // Step 5: Verify meal was added
        XCTAssertTrue(app.staticTexts["Test Meal"].exists, "Added meal should appear in the list")
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS '250 kcal'")).element.exists, "Meal calories should be visible")
    }
    
    func testAddMealValidation() throws {
        // Test form validation
        
        // Open add meal view
        app.buttons["plus.circle.fill"].tap()
        
        // Verify save button is initially disabled
        let saveButton = app.buttons["Save"]
        XCTAssertFalse(saveButton.isEnabled, "Save button should be disabled with empty form")
        
        // Fill only name field
        let nameField = app.textFields["Enter meal name"]
        nameField.tap()
        nameField.typeText("Incomplete Meal")
        
        // Save button should still be disabled
        XCTAssertFalse(saveButton.isEnabled, "Save button should be disabled with incomplete form")
        
        // Cancel and return to main view
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.staticTexts["Tamiza"].exists, "Should return to main view")
    }
    
    func testQuickAddButtons() throws {
        // Test quick add functionality
        
        // Open add meal view
        app.buttons["plus.circle.fill"].tap()
        
        // Scroll to quick add section
        app.swipeUp()
        
        // Tap on a quick add button (Apple)
        let appleButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Apple'")).element
        if appleButton.exists {
            appleButton.tap()
            
            // Verify fields are populated
            XCTAssertTrue(app.textFields["Apple"].exists, "Name field should be populated with Apple")
            XCTAssertTrue(app.buttons["Save"].isEnabled, "Save button should be enabled after quick add")
        }
    }
    
    // MARK: - Calendar Toggle Tests
    
    func testCalendarToggle() throws {
        // Test calendar view toggle
        
        // Find and tap calendar toggle button
        let calendarButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'calendar' OR identifier CONTAINS 'list.bullet'")).element
        if calendarButton.exists {
            calendarButton.tap()
            
            // Should show calendar picker
            XCTAssertTrue(app.datePickers.element.exists, "Calendar picker should be visible")
            
            // Toggle back to list view
            let listButton = app.buttons["list.bullet"]
            if listButton.exists {
                listButton.tap()
                XCTAssertTrue(app.staticTexts["Today's Meals"].exists, "Should return to meals list")
            }
        }
    }
    
    // MARK: - Meal Deletion Tests
    
    func testMealDeletion() throws {
        // First add a meal to delete
        testAddMealFlow()
        
        // Find the meal in the list
        let mealCell = app.staticTexts["Test Meal"]
        XCTAssertTrue(mealCell.exists, "Test meal should exist")
        
        // Swipe to delete
        mealCell.swipeLeft()
        
        // Tap delete button
        let deleteButton = app.buttons["Delete"]
        if deleteButton.exists {
            deleteButton.tap()
            
            // Verify meal is removed
            XCTAssertFalse(app.staticTexts["Test Meal"].exists, "Test meal should be deleted")
        }
    }
    
    // MARK: - Navigation Tests
    
    func testNavigationFlow() throws {
        // Test basic navigation flows
        
        // Test add meal navigation
        app.buttons["plus.circle.fill"].tap()
        XCTAssertTrue(app.navigationBars["Add Meal"].exists)
        
        // Test cancel navigation
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.staticTexts["Tamiza"].exists)
        
        // Test that we're back to main view
        XCTAssertTrue(app.buttons["plus.circle.fill"].exists)
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibility() throws {
        // Test that key elements have accessibility labels
        
        let addButton = app.buttons["plus.circle.fill"]
        XCTAssertTrue(addButton.exists)
        XCTAssertTrue(addButton.isHittable, "Add button should be accessible")
        
        // Test that text elements are accessible
        let titleText = app.staticTexts["Tamiza"]
        XCTAssertTrue(titleText.exists)
        XCTAssertTrue(titleText.isHittable, "Title should be accessible")
    }
    
    // MARK: - Performance Tests
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testScrollPerformance() throws {
        // Add multiple meals first
        for i in 1...5 {
            app.buttons["plus.circle.fill"].tap()
            
            let nameField = app.textFields["Enter meal name"]
            nameField.tap()
            nameField.typeText("Test Meal \(i)")
            
            let caloriesField = app.textFields["0"].firstMatch
            caloriesField.tap()
            caloriesField.typeText("100")
            
            let proteinField = app.textFields.matching(identifier: "0.0").element(boundBy: 0)
            proteinField.tap()
            proteinField.typeText("10.0")
            
            let fatField = app.textFields.matching(identifier: "0.0").element(boundBy: 1)
            fatField.tap()
            fatField.typeText("5.0")
            
            let carbsField = app.textFields.matching(identifier: "0.0").element(boundBy: 2)
            carbsField.tap()
            carbsField.typeText("15.0")
            
            app.buttons["Save"].tap()
        }
        
        // Test scrolling performance
        measure {
            for _ in 1...10 {
                app.swipeUp()
                app.swipeDown()
            }
        }
    }
}