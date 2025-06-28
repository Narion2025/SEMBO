import Foundation
import Yams
import CoreData

/// Service für YAML Import/Export von Markern
class YAMLService {
    
    // MARK: - Data Models für YAML
    
    struct YAMLMarker: Codable {
        let marker_name: String
        let definition: String
        let ankerbeispiel: String
        let kodierregeln_abgrenzung: String
        let tags: [String]?
        let category: String?
        let examples: [YAMLExample]?
        
        struct YAMLExample: Codable {
            let text: String
            let kontext: String?
            let beziehungstyp: String?
            let subtilitaet: Int?
        }
    }
    
    struct YAMLCodebook: Codable {
        let version: String
        let created_at: String
        let markers: [YAMLMarker]
    }
    
    // MARK: - Export
    
    /// Exportiert Marker zu YAML
    static func exportToYAML(_ markers: [Marker]) throws -> Data {
        let yamlMarkers = markers.map { marker in
            YAMLMarker(
                marker_name: marker.markerName,
                definition: marker.definition,
                ankerbeispiel: marker.ankerbeispiel,
                kodierregeln_abgrenzung: marker.kodierregelnAbgrenzung,
                tags: marker.tags,
                category: marker.category?.name,
                examples: mapExamples(marker.examples)
            )
        }
        
        let codebook = YAMLCodebook(
            version: "1.0",
            created_at: ISO8601DateFormatter().string(from: Date()),
            markers: yamlMarkers
        )
        
        let encoder = YAMLEncoder()
        let yamlString = try encoder.encode(codebook)
        
        guard let data = yamlString.data(using: .utf8) else {
            throw YAMLError.encodingFailed
        }
        
        return data
    }
    
    /// Exportiert einen einzelnen Marker zu YAML
    static func exportSingleMarker(_ marker: Marker) throws -> Data {
        let yamlMarker = YAMLMarker(
            marker_name: marker.markerName,
            definition: marker.definition,
            ankerbeispiel: marker.ankerbeispiel,
            kodierregeln_abgrenzung: marker.kodierregelnAbgrenzung,
            tags: marker.tags,
            category: marker.category?.name,
            examples: mapExamples(marker.examples)
        )
        
        let encoder = YAMLEncoder()
        let yamlString = try encoder.encode(yamlMarker)
        
        guard let data = yamlString.data(using: .utf8) else {
            throw YAMLError.encodingFailed
        }
        
        return data
    }
    
    // MARK: - Import
    
    /// Importiert Marker aus YAML-Daten
    static func importFromYAML(_ data: Data, context: NSManagedObjectContext) throws -> [Marker] {
        guard let yamlString = String(data: data, encoding: .utf8) else {
            throw YAMLError.decodingFailed
        }
        
        let decoder = YAMLDecoder()
        var importedMarkers: [Marker] = []
        
        // Versuche zuerst als Codebook zu dekodieren
        if let codebook = try? decoder.decode(YAMLCodebook.self, from: yamlString) {
            for yamlMarker in codebook.markers {
                let marker = try createMarker(from: yamlMarker, context: context)
                importedMarkers.append(marker)
            }
        }
        // Versuche als Array von Markern
        else if let yamlMarkers = try? decoder.decode([YAMLMarker].self, from: yamlString) {
            for yamlMarker in yamlMarkers {
                let marker = try createMarker(from: yamlMarker, context: context)
                importedMarkers.append(marker)
            }
        }
        // Versuche als einzelnen Marker
        else if let yamlMarker = try? decoder.decode(YAMLMarker.self, from: yamlString) {
            let marker = try createMarker(from: yamlMarker, context: context)
            importedMarkers.append(marker)
        }
        else {
            throw YAMLError.invalidFormat
        }
        
        try context.save()
        return importedMarkers
    }
    
    // MARK: - Helper Methods
    
    private static func createMarker(from yamlMarker: YAMLMarker, context: NSManagedObjectContext) throws -> Marker {
        let marker = Marker(context: context)
        marker.markerName = yamlMarker.marker_name
        marker.definition = yamlMarker.definition
        marker.ankerbeispiel = yamlMarker.ankerbeispiel
        marker.kodierregelnAbgrenzung = yamlMarker.kodierregeln_abgrenzung
        marker.tags = yamlMarker.tags
        
        // Kategorie zuweisen falls vorhanden
        if let categoryName = yamlMarker.category {
            let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", categoryName)
            
            if let existingCategory = try context.fetch(fetchRequest).first {
                marker.category = existingCategory
            } else {
                // Neue Kategorie erstellen
                let newCategory = Category(context: context)
                newCategory.name = categoryName
                marker.category = newCategory
            }
        }
        
        // Beispiele hinzufügen
        if let examples = yamlMarker.examples {
            for yamlExample in examples {
                let example = MarkerExample(context: context)
                example.text = yamlExample.text
                example.kontext = yamlExample.kontext
                example.beziehungstyp = yamlExample.beziehungstyp
                example.subtilitaet = Int16(yamlExample.subtilitaet ?? 3)
                example.marker = marker
            }
        }
        
        return marker
    }
    
    private static func mapExamples(_ examples: Set<MarkerExample>?) -> [YAMLMarker.YAMLExample]? {
        guard let examples = examples, !examples.isEmpty else { return nil }
        
        return examples.map { example in
            YAMLMarker.YAMLExample(
                text: example.text,
                kontext: example.kontext,
                beziehungstyp: example.beziehungstyp,
                subtilitaet: Int(example.subtilitaet)
            )
        }
    }
}

// MARK: - Errors

enum YAMLError: LocalizedError {
    case encodingFailed
    case decodingFailed
    case invalidFormat
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Fehler beim Kodieren der YAML-Daten"
        case .decodingFailed:
            return "Fehler beim Dekodieren der YAML-Daten"
        case .invalidFormat:
            return "Ungültiges YAML-Format"
        }
    }
} 