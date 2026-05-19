//
//  TamizaTests.swift
//  TamizaTests
//
//  Created by AI Assistant on 2025-07-28.
//

import XCTest
@testable import Tamiza

final class TamizaTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Item Model Tests
    
    func testItemInitialization() throws {
        // Test default initialization
        let item = Item()
        
        XCTAssertNotNil(item.timestamp)
        XCTAssertEqual(item.name, "")
        XCTAssertEqual(item.calories, 0)
        XCTAssertEqual(item.protein, 0.0)
        XCTAssertEqual(item.fat, 0.0)
        XCTAssertEqual(item.carbs, 0.0)
        XCTAssertFalse(item.isValid)
    }
    
    func testItemWithValidData() throws {
        // Test initialization with valid data
        let timestamp = Date()
        let item = Item(
            timestamp: timestamp,
            name: "Grilled Chicken",
            calories: 231,
            protein: 43.5,
            fat: 5.0,
            carbs: 0.0
        )
        
        XCTAssertEqual(item.timestamp, timestamp)
        XCTAssertEqual(item.name, "Grilled Chicken")
        XCTAssertEqual(item.calories, 231)
        XCTAssertEqual(item.protein, 43.5)
        XCTAssertEqual(item.fat, 5.0)
        XCTAssertEqual(item.carbs, 0.0)
        XCTAssertTrue(item.isValid)
    }
    
    func testItemMacroCalculations() throws {
        let item = Item(
            name: "Test Food",
            calories: 300,
            protein: 20.0,
            fat: 10.0,
            carbs: 30.0
        )
        
        // Test macro calculations
        XCTAssertEqual(item.totalMacros, 60.0) // 20 + 10 + 30
        XCTAssertEqual(item.proteinCalories, 80.0) // 20 * 4
        XCTAssertEqual(item.fatCalories, 90.0) // 10 * 9
        XCTAssertEqual(item.carbCalories, 120.0) // 30 * 4
    }
    
    func testItemValidation() throws {
        // Test invalid item (empty name)
        let invalidItem1 = Item(name: "", calories: 100, protein: 10.0, fat: 5.0, carbs: 15.0)
        XCTAssertFalse(invalidItem1.isValid)
        
        // Test invalid item (zero calories)
        let invalidItem2 = Item(name: "Test", calories: 0, protein: 10.0, fat: 5.0, carbs: 15.0)
        XCTAssertFalse(invalidItem2.isValid)
        
        // Test valid item
        let validItem = Item(name: "Test", calories: 100, protein: 10.0, fat: 5.0, carbs: 15.0)
        XCTAssertTrue(validItem.isValid)
    }
    
    func testItemNutritionSummary() throws {
        let item = Item(
            name: "Test Food",
            calories: 250,
            protein: 15.5,
            fat: 8.2,
            carbs: 25.7
        )
        
        let summary = item.nutritionSummary
        XCTAssertTrue(summary.contains("250 kcal"))
        XCTAssertTrue(summary.contains("P: 15.5g"))
        XCTAssertTrue(summary.contains("F: 8.2g"))
        XCTAssertTrue(summary.contains("C: 25.7g"))
    }
    
    func testItemFormattedTimestamp() throws {
        let item = Item()
        let formattedTimestamp = item.formattedTimestamp
        
        // Should not be empty
        XCTAssertFalse(formattedTimestamp.isEmpty)
        
        // Should contain date and time components
        XCTAssertTrue(formattedTimestamp.count > 10) // Basic length check
    }
    
    // MARK: - Sample Data Tests
    
    func testSampleData() throws {
        let sampleItems = Item.sampleData
        
        XCTAssertEqual(sampleItems.count, 5)
        
        // Test that all sample items are valid
        for item in sampleItems {
            XCTAssertTrue(item.isValid, "Sample item '\(item.name)' should be valid")
            XCTAssertFalse(item.name.isEmpty, "Sample item name should not be empty")
            XCTAssertGreaterThan(item.calories, 0, "Sample item calories should be greater than 0")
        }
        
        // Test specific sample items
        let chickenBreast = sampleItems.first { $0.name.contains("Chicken") }
        XCTAssertNotNil(chickenBreast)
        XCTAssertEqual(chickenBreast?.calories, 231)
        XCTAssertEqual(chickenBreast?.protein, 43.5)
    }
    
    // MARK: - Performance Tests
    
    func testItemCreationPerformance() throws {
        measure {
            // Test performance of creating many items
            for i in 0..<1000 {
                let item = Item(
                    name: "Test Item \(i)",
                    calories: 100 + i,
                    protein: Double(i % 50),
                    fat: Double(i % 30),
                    carbs: Double(i % 40)
                )
                _ = item.isValid
                _ = item.nutritionSummary
            }
        }
    }
    
    func testMacroCalculationPerformance() throws {
        let items = (0..<1000).map { i in
            Item(
                name: "Test Item \(i)",
                calories: 100 + i,
                protein: Double(i % 50),
                fat: Double(i % 30),
                carbs: Double(i % 40)
            )
        }
        
        measure {
            for item in items {
                _ = item.totalMacros
                _ = item.proteinCalories
                _ = item.fatCalories
                _ = item.carbCalories
            }
        }
    }
}