import Foundation
import CoreData
import Combine

/// Repository für Kategorie-Verwaltung
class CategoryRepository: ObservableObject {
    private let persistenceController: PersistenceController
    private let context: NSManagedObjectContext
    
    @Published var categories: [Category] = []
    @Published var rootCategories: [Category] = []
    
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        self.context = persistenceController.container.viewContext
        fetchCategories()
    }
    
    // MARK: - CRUD Operations
    
    /// Erstellt eine neue Kategorie
    func createCategory(
        name: String,
        beschreibung: String? = nil,
        parent: Category? = nil
    ) throws -> Category {
        let category = Category(context: context)
        category.name = name
        category.beschreibung = beschreibung
        category.parent = parent
        
        try context.save()
        fetchCategories()
        return category
    }
    
    /// Aktualisiert eine bestehende Kategorie
    func updateCategory(_ category: Category) throws {
        try context.save()
        fetchCategories()
    }
    
    /// Löscht eine Kategorie
    func deleteCategory(_ category: Category) throws {
        context.delete(category)
        try context.save()
        fetchCategories()
    }
    
    /// Lädt alle Kategorien aus der Datenbank
    func fetchCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        
        do {
            categories = try context.fetch(request)
            // Root-Kategorien separat filtern
            rootCategories = categories.filter { $0.parent == nil }
        } catch {
            print("Fehler beim Laden der Kategorien: \(error)")
            categories = []
            rootCategories = []
        }
    }
    
    /// Verschiebt eine Kategorie zu einem neuen Parent
    func moveCategory(_ category: Category, to newParent: Category?) throws {
        // Verhindere zirkuläre Referenzen
        if let newParent = newParent {
            if isDescendant(of: category, candidate: newParent) {
                throw CategoryError.circularReference
            }
        }
        
        category.parent = newParent
        try updateCategory(category)
    }
    
    /// Prüft ob eine Kategorie Nachfahre einer anderen ist
    private func isDescendant(of ancestor: Category, candidate: Category) -> Bool {
        var current: Category? = candidate
        while let parent = current?.parent {
            if parent == ancestor {
                return true
            }
            current = parent
        }
        return false
    }
    
    /// Fügt einen Marker zu einer Kategorie hinzu
    func addMarker(_ marker: Marker, to category: Category) throws {
        marker.category = category
        try context.save()
    }
    
    /// Entfernt einen Marker aus einer Kategorie
    func removeMarker(_ marker: Marker, from category: Category) throws {
        if marker.category == category {
            marker.category = nil
            try context.save()
        }
    }
    
    /// Gibt alle Marker einer Kategorie zurück (inkl. Unterkategorien)
    func getAllMarkers(for category: Category, includeSubcategories: Bool = true) -> [Marker] {
        var allMarkers: [Marker] = []
        
        // Direkte Marker der Kategorie
        if let markers = category.markers {
            allMarkers.append(contentsOf: markers)
        }
        
        // Marker aus Unterkategorien
        if includeSubcategories, let subcategories = category.subcategories {
            for subcategory in subcategories {
                allMarkers.append(contentsOf: getAllMarkers(for: subcategory, includeSubcategories: true))
            }
        }
        
        return allMarkers
    }
    
    /// Erstellt eine hierarchische Struktur für die Anzeige
    func getCategoryTree() -> [CategoryNode] {
        return rootCategories.map { buildCategoryNode($0) }
    }
    
    private func buildCategoryNode(_ category: Category) -> CategoryNode {
        let children = category.subcategories?.map { buildCategoryNode($0) } ?? []
        return CategoryNode(
            category: category,
            children: children.sorted { $0.category.name < $1.category.name }
        )
    }
}

// MARK: - Supporting Types

enum CategoryError: LocalizedError {
    case circularReference
    
    var errorDescription: String? {
        switch self {
        case .circularReference:
            return "Eine Kategorie kann nicht in ihre eigene Unterkategorie verschoben werden."
        }
    }
}

struct CategoryNode {
    let category: Category
    let children: [CategoryNode]
    
    var markerCount: Int {
        let directCount = category.markers?.count ?? 0
        let childCount = children.reduce(0) { $0 + $1.markerCount }
        return directCount + childCount
    }
} 