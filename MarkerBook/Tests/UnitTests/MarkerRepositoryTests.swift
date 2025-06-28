import XCTest
import CoreData
@testable import MarkerBook

class MarkerRepositoryTests: XCTestCase {
    var sut: MarkerRepository!
    var persistenceController: PersistenceController!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        sut = MarkerRepository(persistenceController: persistenceController)
    }
    
    override func tearDown() {
        sut = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Create Tests
    
    func testCreateMarker_WithValidData_CreatesMarkerSuccessfully() throws {
        // Given
        let name = "Test Marker"
        let definition = "Test Definition"
        let ankerbeispiel = "Test Ankerbeispiel"
        let kodierregeln = "Test Kodierregeln"
        let tags = ["test", "unit"]
        
        // When
        let marker = try sut.createMarker(
            name: name,
            definition: definition,
            ankerbeispiel: ankerbeispiel,
            kodierregeln: kodierregeln,
            tags: tags
        )
        
        // Then
        XCTAssertNotNil(marker)
        XCTAssertEqual(marker.markerName, name)
        XCTAssertEqual(marker.definition, definition)
        XCTAssertEqual(marker.ankerbeispiel, ankerbeispiel)
        XCTAssertEqual(marker.kodierregelnAbgrenzung, kodierregeln)
        XCTAssertEqual(marker.tags, tags)
        XCTAssertNotNil(marker.createdAt)
        XCTAssertNotNil(marker.updatedAt)
    }
    
    func testCreateMarker_WithCategory_AssignsCategoryCorrectly() throws {
        // Given
        let category = Category(context: persistenceController.container.viewContext)
        category.name = "Test Category"
        try persistenceController.container.viewContext.save()
        
        // When
        let marker = try sut.createMarker(
            name: "Test Marker",
            definition: "Definition",
            ankerbeispiel: "Beispiel",
            kodierregeln: "Regeln",
            category: category
        )
        
        // Then
        XCTAssertEqual(marker.category, category)
    }
    
    // MARK: - Update Tests
    
    func testUpdateMarker_UpdatesTimestamp() throws {
        // Given
        let marker = try sut.createMarker(
            name: "Original",
            definition: "Definition",
            ankerbeispiel: "Beispiel",
            kodierregeln: "Regeln"
        )
        let originalDate = marker.updatedAt
        
        // Wait a moment to ensure timestamp difference
        Thread.sleep(forTimeInterval: 0.1)
        
        // When
        marker.markerName = "Updated"
        try sut.updateMarker(marker)
        
        // Then
        XCTAssertGreaterThan(marker.updatedAt, originalDate)
    }
    
    // MARK: - Delete Tests
    
    func testDeleteMarker_RemovesMarkerFromRepository() throws {
        // Given
        let marker = try sut.createMarker(
            name: "To Delete",
            definition: "Definition",
            ankerbeispiel: "Beispiel",
            kodierregeln: "Regeln"
        )
        XCTAssertEqual(sut.markers.count, 1)
        
        // When
        try sut.deleteMarker(marker)
        
        // Then
        XCTAssertEqual(sut.markers.count, 0)
    }
    
    // MARK: - Fetch Tests
    
    func testFetchMarkers_ReturnsAllMarkers() throws {
        // Given
        _ = try sut.createMarker(name: "Marker 1", definition: "Def 1", ankerbeispiel: "Bsp 1", kodierregeln: "Regel 1")
        _ = try sut.createMarker(name: "Marker 2", definition: "Def 2", ankerbeispiel: "Bsp 2", kodierregeln: "Regel 2")
        _ = try sut.createMarker(name: "Marker 3", definition: "Def 3", ankerbeispiel: "Bsp 3", kodierregeln: "Regel 3")
        
        // When
        sut.fetchMarkers()
        
        // Then
        XCTAssertEqual(sut.markers.count, 3)
    }
    
    func testFetchMarkers_WithSearchText_FiltersCorrectly() throws {
        // Given
        _ = try sut.createMarker(name: "Schuld", definition: "Schuldgefühle", ankerbeispiel: "Beispiel", kodierregeln: "Regel")
        _ = try sut.createMarker(name: "Angst", definition: "Angstmachen", ankerbeispiel: "Beispiel", kodierregeln: "Regel")
        _ = try sut.createMarker(name: "Freude", definition: "Positive Emotion", ankerbeispiel: "Beispiel", kodierregeln: "Regel")
        
        // When
        sut.searchText = "Schuld"
        sut.fetchMarkers()
        
        // Then
        XCTAssertEqual(sut.markers.count, 1)
        XCTAssertEqual(sut.markers.first?.markerName, "Schuld")
    }
    
    // MARK: - Tag Tests
    
    func testFetchMarkersByTags_ReturnsCorrectMarkers() throws {
        // Given
        _ = try sut.createMarker(name: "Marker 1", definition: "Def", ankerbeispiel: "Bsp", kodierregeln: "Regel", tags: ["emotion", "manipulation"])
        _ = try sut.createMarker(name: "Marker 2", definition: "Def", ankerbeispiel: "Bsp", kodierregeln: "Regel", tags: ["emotion", "positiv"])
        _ = try sut.createMarker(name: "Marker 3", definition: "Def", ankerbeispiel: "Bsp", kodierregeln: "Regel", tags: ["kognitiv"])
        
        // When
        let emotionMarkers = sut.fetchMarkersByTags(["emotion"])
        
        // Then
        XCTAssertEqual(emotionMarkers.count, 2)
    }
    
    // MARK: - Example Tests
    
    func testAddExample_AddsExampleToMarker() throws {
        // Given
        let marker = try sut.createMarker(
            name: "Test Marker",
            definition: "Definition",
            ankerbeispiel: "Beispiel",
            kodierregeln: "Regeln"
        )
        
        // When
        try sut.addExample(
            to: marker,
            text: "Beispieltext",
            kontext: "Partnerschaft",
            beziehungstyp: "Romantisch",
            subtilitaet: 4
        )
        
        // Then
        XCTAssertEqual(marker.examples?.count, 1)
        let example = marker.examples?.first as? MarkerExample
        XCTAssertEqual(example?.text, "Beispieltext")
        XCTAssertEqual(example?.kontext, "Partnerschaft")
        XCTAssertEqual(example?.beziehungstyp, "Romantisch")
        XCTAssertEqual(example?.subtilitaet, 4)
    }
    
    func testRemoveExample_RemovesExampleFromMarker() throws {
        // Given
        let marker = try sut.createMarker(
            name: "Test Marker",
            definition: "Definition",
            ankerbeispiel: "Beispiel",
            kodierregeln: "Regeln"
        )
        try sut.addExample(to: marker, text: "Beispiel 1")
        try sut.addExample(to: marker, text: "Beispiel 2")
        XCTAssertEqual(marker.examples?.count, 2)
        
        guard let exampleToRemove = marker.examples?.first as? MarkerExample else {
            XCTFail("No example found")
            return
        }
        
        // When
        try sut.removeExample(exampleToRemove, from: marker)
        
        // Then
        XCTAssertEqual(marker.examples?.count, 1)
    }
} 