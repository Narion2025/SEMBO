import CoreData
import Foundation

/// Zentrale Verwaltung des Core Data Stacks
class PersistenceController {
    static let shared = PersistenceController()
    
    // Preview-Instanz für SwiftUI Previews
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Beispieldaten für Previews
        let exampleCategory = Category(context: viewContext)
        exampleCategory.name = "Emotionale Manipulation"
        exampleCategory.beschreibung = "Strategien zur emotionalen Beeinflussung"
        
        let exampleMarker = Marker(context: viewContext)
        exampleMarker.markerName = "Schuldgefühle erzeugen"
        exampleMarker.definition = "Aussagen, die beim Gegenüber Schuldgefühle hervorrufen sollen"
        exampleMarker.ankerbeispiel = "Wenn du mich wirklich lieben würdest, dann..."
        exampleMarker.kodierregelnAbgrenzung = "Nur wenn explizit oder implizit Schuld zugewiesen wird"
        exampleMarker.tags = ["manipulation", "emotional", "schuld"]
        exampleMarker.category = exampleCategory
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MarkerBookModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Speicherort für die Datenbank festlegen
            let storeURL = getDocumentsDirectory().appendingPathComponent("MarkerBook.sqlite")
            container.persistentStoreDescriptions.first!.url = storeURL
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // Hilfsfunktion für Dokumente-Verzeichnis
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // Speichern des Kontexts
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
} 