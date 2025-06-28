import XCTest
import CoreData
@testable import MarkerBook

class YAMLServiceTests: XCTestCase {
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }
    
    override func tearDown() {
        context = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Export Tests
    
    func testExportSingleMarker_GeneratesValidYAML() throws {
        // Given
        let marker = Marker(context: context)
        marker.markerName = "Schuldgefühle erzeugen"
        marker.definition = "Aussagen, die beim Gegenüber Schuldgefühle hervorrufen sollen"
        marker.ankerbeispiel = "Wenn du mich wirklich lieben würdest, dann..."
        marker.kodierregelnAbgrenzung = "Nur wenn explizit oder implizit Schuld zugewiesen wird"
        marker.tags = ["manipulation", "emotional"]
        
        // When
        let yamlData = try YAMLService.exportSingleMarker(marker)
        let yamlString = String(data: yamlData, encoding: .utf8)!
        
        // Then
        XCTAssertTrue(yamlString.contains("marker_name: Schuldgefühle erzeugen"))
        XCTAssertTrue(yamlString.contains("definition: Aussagen, die beim Gegenüber Schuldgefühle hervorrufen sollen"))
        XCTAssertTrue(yamlString.contains("ankerbeispiel: Wenn du mich wirklich lieben würdest, dann..."))
        XCTAssertTrue(yamlString.contains("manipulation"))
        XCTAssertTrue(yamlString.contains("emotional"))
    }
    
    func testExportMarkers_WithExamples_IncludesExamplesInYAML() throws {
        // Given
        let marker = Marker(context: context)
        marker.markerName = "Test Marker"
        marker.definition = "Test Definition"
        marker.ankerbeispiel = "Test Ankerbeispiel"
        marker.kodierregelnAbgrenzung = "Test Regeln"
        
        let example = MarkerExample(context: context)
        example.text = "Beispieltext"
        example.kontext = "Testkontext"
        example.beziehungstyp = "Partner"
        example.subtilitaet = 3
        example.marker = marker
        
        try context.save()
        
        // When
        let yamlData = try YAMLService.exportToYAML([marker])
        let yamlString = String(data: yamlData, encoding: .utf8)!
        
        // Then
        XCTAssertTrue(yamlString.contains("examples:"))
        XCTAssertTrue(yamlString.contains("text: Beispieltext"))
        XCTAssertTrue(yamlString.contains("kontext: Testkontext"))
        XCTAssertTrue(yamlString.contains("beziehungstyp: Partner"))
        XCTAssertTrue(yamlString.contains("subtilitaet: 3"))
    }
    
    // MARK: - Import Tests
    
    func testImportFromYAML_SingleMarker_CreatesMarkerCorrectly() throws {
        // Given
        let yamlString = """
        marker_name: Import Test
        definition: Test Definition
        ankerbeispiel: Test Beispiel
        kodierregeln_abgrenzung: Test Regeln
        tags:
          - test
          - import
        """
        let yamlData = yamlString.data(using: .utf8)!
        
        // When
        let markers = try YAMLService.importFromYAML(yamlData, context: context)
        
        // Then
        XCTAssertEqual(markers.count, 1)
        let marker = markers.first!
        XCTAssertEqual(marker.markerName, "Import Test")
        XCTAssertEqual(marker.definition, "Test Definition")
        XCTAssertEqual(marker.ankerbeispiel, "Test Beispiel")
        XCTAssertEqual(marker.kodierregelnAbgrenzung, "Test Regeln")
        XCTAssertEqual(marker.tags, ["test", "import"])
    }
    
    func testImportFromYAML_WithCategory_CreatesOrAssignsCategory() throws {
        // Given
        let yamlString = """
        marker_name: Kategorisierter Marker
        definition: Definition
        ankerbeispiel: Beispiel
        kodierregeln_abgrenzung: Regeln
        category: Emotionale Manipulation
        """
        let yamlData = yamlString.data(using: .utf8)!
        
        // When
        let markers = try YAMLService.importFromYAML(yamlData, context: context)
        
        // Then
        XCTAssertEqual(markers.count, 1)
        let marker = markers.first!
        XCTAssertNotNil(marker.category)
        XCTAssertEqual(marker.category?.name, "Emotionale Manipulation")
    }
    
    func testImportFromYAML_Codebook_ImportsMultipleMarkers() throws {
        // Given
        let yamlString = """
        version: "1.0"
        created_at: "2024-01-01T00:00:00Z"
        markers:
          - marker_name: Marker 1
            definition: Definition 1
            ankerbeispiel: Beispiel 1
            kodierregeln_abgrenzung: Regeln 1
          - marker_name: Marker 2
            definition: Definition 2
            ankerbeispiel: Beispiel 2
            kodierregeln_abgrenzung: Regeln 2
        """
        let yamlData = yamlString.data(using: .utf8)!
        
        // When
        let markers = try YAMLService.importFromYAML(yamlData, context: context)
        
        // Then
        XCTAssertEqual(markers.count, 2)
        XCTAssertEqual(markers[0].markerName, "Marker 1")
        XCTAssertEqual(markers[1].markerName, "Marker 2")
    }
    
    func testImportFromYAML_WithExamples_CreatesExamplesCorrectly() throws {
        // Given
        let yamlString = """
        marker_name: Marker mit Beispielen
        definition: Definition
        ankerbeispiel: Ankerbeispiel
        kodierregeln_abgrenzung: Regeln
        examples:
          - text: Erstes Beispiel
            kontext: Kontext 1
            subtilitaet: 2
          - text: Zweites Beispiel
            beziehungstyp: Partner
            subtilitaet: 4
        """
        let yamlData = yamlString.data(using: .utf8)!
        
        // When
        let markers = try YAMLService.importFromYAML(yamlData, context: context)
        
        // Then
        XCTAssertEqual(markers.count, 1)
        let marker = markers.first!
        XCTAssertEqual(marker.examples?.count, 2)
        
        let examples = Array(marker.examples as? Set<MarkerExample> ?? [])
            .sorted { $0.text < $1.text }
        
        XCTAssertEqual(examples[0].text, "Erstes Beispiel")
        XCTAssertEqual(examples[0].kontext, "Kontext 1")
        XCTAssertEqual(examples[0].subtilitaet, 2)
        
        XCTAssertEqual(examples[1].text, "Zweites Beispiel")
        XCTAssertEqual(examples[1].beziehungstyp, "Partner")
        XCTAssertEqual(examples[1].subtilitaet, 4)
    }
    
    // MARK: - Error Tests
    
    func testImportFromYAML_InvalidFormat_ThrowsError() {
        // Given
        let invalidYAML = "This is not valid YAML: [["
        let yamlData = invalidYAML.data(using: .utf8)!
        
        // When/Then
        XCTAssertThrows {
            _ = try YAMLService.importFromYAML(yamlData, context: context)
        }
    }
} 