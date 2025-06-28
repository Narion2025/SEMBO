import Foundation
import CoreData
import Combine

/// Repository für Marker-Verwaltung
class MarkerRepository: ObservableObject {
    private let persistenceController: PersistenceController
    private let context: NSManagedObjectContext
    
    @Published var markers: [Marker] = []
    @Published var searchText: String = ""
    @Published var selectedTags: Set<String> = []
    
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        self.context = persistenceController.container.viewContext
        fetchMarkers()
    }
    
    // MARK: - CRUD Operations
    
    /// Erstellt einen neuen Marker
    func createMarker(
        name: String,
        definition: String,
        ankerbeispiel: String,
        kodierregeln: String,
        tags: [String] = [],
        category: Category? = nil
    ) throws -> Marker {
        let marker = Marker(context: context)
        marker.markerName = name
        marker.definition = definition
        marker.ankerbeispiel = ankerbeispiel
        marker.kodierregelnAbgrenzung = kodierregeln
        marker.tags = tags
        marker.category = category
        
        try context.save()
        fetchMarkers()
        return marker
    }
    
    /// Aktualisiert einen bestehenden Marker
    func updateMarker(_ marker: Marker) throws {
        marker.updatedAt = Date()
        try context.save()
        fetchMarkers()
    }
    
    /// Löscht einen Marker
    func deleteMarker(_ marker: Marker) throws {
        context.delete(marker)
        try context.save()
        fetchMarkers()
    }
    
    /// Lädt alle Marker aus der Datenbank
    func fetchMarkers() {
        let request: NSFetchRequest<Marker> = Marker.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Marker.markerName, ascending: true)]
        
        // Filter anwenden wenn Suchtext vorhanden
        var predicates: [NSPredicate] = []
        
        if !searchText.isEmpty {
            let searchPredicate = NSPredicate(
                format: "markerName CONTAINS[cd] %@ OR definition CONTAINS[cd] %@ OR ankerbeispiel CONTAINS[cd] %@",
                searchText, searchText, searchText
            )
            predicates.append(searchPredicate)
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        do {
            markers = try context.fetch(request)
        } catch {
            print("Fehler beim Laden der Marker: \(error)")
            markers = []
        }
    }
    
    /// Sucht Marker nach Tags
    func fetchMarkersByTags(_ tags: Set<String>) -> [Marker] {
        let request: NSFetchRequest<Marker> = Marker.fetchRequest()
        
        // Erstelle Prädikat für Tag-Suche
        let tagPredicates = tags.map { tag in
            NSPredicate(format: "ANY tags CONTAINS[cd] %@", tag)
        }
        
        if !tagPredicates.isEmpty {
            request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: tagPredicates)
        }
        
        do {
            return try context.fetch(request)
        } catch {
            print("Fehler beim Laden der Marker nach Tags: \(error)")
            return []
        }
    }
    
    /// Sucht Marker nach Kategorie
    func fetchMarkersByCategory(_ category: Category) -> [Marker] {
        let request: NSFetchRequest<Marker> = Marker.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Marker.markerName, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Fehler beim Laden der Marker nach Kategorie: \(error)")
            return []
        }
    }
    
    // MARK: - Beispiel-Verwaltung
    
    /// Fügt ein Beispiel zu einem Marker hinzu
    func addExample(
        to marker: Marker,
        text: String,
        kontext: String? = nil,
        beziehungstyp: String? = nil,
        subtilitaet: Int16 = 3
    ) throws {
        let example = MarkerExample(context: context)
        example.text = text
        example.kontext = kontext
        example.beziehungstyp = beziehungstyp
        example.subtilitaet = subtilitaet
        example.marker = marker
        
        marker.addToExamples(example)
        try updateMarker(marker)
    }
    
    /// Entfernt ein Beispiel von einem Marker
    func removeExample(_ example: MarkerExample, from marker: Marker) throws {
        marker.removeFromExamples(example)
        context.delete(example)
        try updateMarker(marker)
    }
    
    // MARK: - Import/Export
    
    /// Importiert Marker aus YAML-Daten
    func importFromYAML(_ yamlData: Data) throws -> [Marker] {
        let importedMarkers = try YAMLService.importFromYAML(yamlData, context: context)
        fetchMarkers()
        return importedMarkers
    }
    
    /// Exportiert Marker zu YAML
    func exportToYAML(_ markers: [Marker]) throws -> Data {
        return try YAMLService.exportToYAML(markers)
    }
    
    /// Exportiert alle Marker zu YAML
    func exportAllToYAML() throws -> Data {
        return try YAMLService.exportToYAML(markers)
    }
} 