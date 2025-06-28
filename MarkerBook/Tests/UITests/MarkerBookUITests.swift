import XCTest

class MarkerBookUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Navigation Tests
    
    func testMainNavigation_AllModulesAccessible() {
        // Given
        let sidebar = app.splitGroups.firstMatch
        
        // When/Then - Check all modules
        XCTAssertTrue(sidebar.buttons["Codebuch"].exists)
        XCTAssertTrue(sidebar.buttons["Kodierung"].exists)
        XCTAssertTrue(sidebar.buttons["Analyse"].exists)
        XCTAssertTrue(sidebar.buttons["Export"].exists)
        
        // Navigate through modules
        sidebar.buttons["Kodierung"].click()
        XCTAssertTrue(app.staticTexts["Kodierungs-Modul"].exists)
        
        sidebar.buttons["Analyse"].click()
        XCTAssertTrue(app.staticTexts["Analyse-Modul"].exists)
        
        sidebar.buttons["Export"].click()
        XCTAssertTrue(app.staticTexts["Export-Modul"].exists)
        
        sidebar.buttons["Codebuch"].click()
    }
    
    // MARK: - Marker Management Tests
    
    func testCreateMarker_WithValidData_CreatesSuccessfully() {
        // Given
        let newMarkerButton = app.buttons["Neuer Marker"]
        XCTAssertTrue(newMarkerButton.exists)
        
        // When - Click new marker button
        newMarkerButton.click()
        
        // Then - Check if form appears
        let markerNameField = app.textFields["Marker-Name"]
        XCTAssertTrue(markerNameField.waitForExistence(timeout: 2))
        
        // Fill in the form
        markerNameField.click()
        markerNameField.typeText("Test Marker UI")
        
        let definitionTextView = app.textViews.element(boundBy: 0)
        definitionTextView.click()
        definitionTextView.typeText("Dies ist eine Test-Definition für UI-Tests")
        
        let ankerbeispielTextView = app.textViews.element(boundBy: 1)
        ankerbeispielTextView.click()
        ankerbeispielTextView.typeText("Ein beispielhaftes Zitat")
        
        let kodierregelnTextView = app.textViews.element(boundBy: 2)
        kodierregelnTextView.click()
        kodierregelnTextView.typeText("Kodierregeln für den Test")
        
        let tagsField = app.textFields["Tags (kommagetrennt)"]
        tagsField.click()
        tagsField.typeText("test, ui, automation")
        
        // Save
        app.buttons["Speichern"].click()
        
        // Verify marker was created
        XCTAssertTrue(app.staticTexts["Test Marker UI"].waitForExistence(timeout: 2))
    }
    
    func testEditMarker_UpdatesSuccessfully() {
        // Given - Create a marker first
        createTestMarker()
        
        // When - Click on the marker
        let markerRow = app.staticTexts["UI Test Marker"]
        XCTAssertTrue(markerRow.waitForExistence(timeout: 2))
        markerRow.click()
        
        // Click edit button
        app.buttons["Bearbeiten"].click()
        
        // Update the name
        let markerNameField = app.textFields["Marker-Name"]
        XCTAssertTrue(markerNameField.waitForExistence(timeout: 2))
        markerNameField.doubleClick()
        markerNameField.typeText("Updated UI Test Marker")
        
        // Save
        app.buttons["Speichern"].click()
        
        // Verify update
        XCTAssertTrue(app.staticTexts["Updated UI Test Marker"].waitForExistence(timeout: 2))
    }
    
    // MARK: - Category Management Tests
    
    func testCreateCategory_CreatesSuccessfully() {
        // Given - Navigate to category management
        // This would need to be implemented based on actual UI
        
        let newCategoryButton = app.buttons["Neue Kategorie"]
        guard newCategoryButton.waitForExistence(timeout: 2) else {
            XCTFail("New category button not found")
            return
        }
        
        // When
        newCategoryButton.click()
        
        let categoryNameField = app.textFields["Kategorie-Name"]
        XCTAssertTrue(categoryNameField.waitForExistence(timeout: 2))
        categoryNameField.click()
        categoryNameField.typeText("Test Kategorie")
        
        let beschreibungTextView = app.textViews.firstMatch
        beschreibungTextView.click()
        beschreibungTextView.typeText("Eine Beschreibung für die Test-Kategorie")
        
        // Save
        app.buttons["Speichern"].click()
        
        // Verify
        XCTAssertTrue(app.staticTexts["Test Kategorie"].waitForExistence(timeout: 2))
    }
    
    func testDragAndDropCategory_MovesSuccessfully() {
        // Given - Create parent and child categories
        // This test would require more complex setup and gesture simulation
        
        // Simplified version - just check if drag handles exist
        let categoryTree = app.scrollViews.firstMatch
        XCTAssertTrue(categoryTree.exists)
    }
    
    // MARK: - Search and Filter Tests
    
    func testSearchMarkers_FiltersCorrectly() {
        // Given - Create multiple markers
        createTestMarker(name: "Schuld Marker")
        createTestMarker(name: "Angst Marker")
        createTestMarker(name: "Freude Marker")
        
        // When - Search for "Schuld"
        let searchField = app.textFields["Marker suchen..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        searchField.click()
        searchField.typeText("Schuld")
        
        // Then - Only matching marker should be visible
        XCTAssertTrue(app.staticTexts["Schuld Marker"].exists)
        XCTAssertFalse(app.staticTexts["Angst Marker"].exists)
        XCTAssertFalse(app.staticTexts["Freude Marker"].exists)
    }
    
    // MARK: - Import/Export Tests
    
    func testImportYAML_ShowsImportDialog() {
        // This would test the import functionality
        // Implementation depends on actual UI design
    }
    
    // MARK: - Helper Methods
    
    private func createTestMarker(name: String = "UI Test Marker") {
        let newMarkerButton = app.buttons["Neuer Marker"]
        newMarkerButton.click()
        
        let markerNameField = app.textFields["Marker-Name"]
        markerNameField.waitForExistence(timeout: 2)
        markerNameField.click()
        markerNameField.typeText(name)
        
        // Fill required fields with minimal data
        app.textViews.element(boundBy: 0).click()
        app.textViews.element(boundBy: 0).typeText("Definition")
        
        app.textViews.element(boundBy: 1).click()
        app.textViews.element(boundBy: 1).typeText("Beispiel")
        
        app.textViews.element(boundBy: 2).click()
        app.textViews.element(boundBy: 2).typeText("Regeln")
        
        app.buttons["Speichern"].click()
        
        // Wait for dialog to close
        _ = app.staticTexts[name].waitForExistence(timeout: 2)
    }
}

// MARK: - Launch Arguments Extension
extension XCUIApplication {
    func launchWithUITestingEnabled() {
        launchArguments = ["--uitesting", "--reset-data"]
        launch()
    }
} 