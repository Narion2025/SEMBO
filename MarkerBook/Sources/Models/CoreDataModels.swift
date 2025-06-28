import Foundation
import CoreData

// MARK: - Marker
@objc(Marker)
public class Marker: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var markerName: String
    @NSManaged public var definition: String
    @NSManaged public var ankerbeispiel: String
    @NSManaged public var kodierregelnAbgrenzung: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var tags: [String]?
    @NSManaged public var category: Category?
    @NSManaged public var examples: Set<MarkerExample>?
    @NSManaged public var codings: Set<Coding>?
    @NSManaged public var codingsMany: Set<Coding>?
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        createdAt = Date()
        updatedAt = Date()
    }
}

// MARK: - MarkerExample
@objc(MarkerExample)
public class MarkerExample: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var text: String
    @NSManaged public var kontext: String?
    @NSManaged public var beziehungstyp: String?
    @NSManaged public var subtilitaet: Int16
    @NSManaged public var createdAt: Date
    @NSManaged public var marker: Marker
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        createdAt = Date()
        subtilitaet = 3
    }
}

// MARK: - Category
@objc(Category)
public class Category: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var beschreibung: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var markers: Set<Marker>?
    @NSManaged public var parent: Category?
    @NSManaged public var subcategories: Set<Category>?
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        createdAt = Date()
    }
}

// MARK: - Project
@objc(Project)
public class Project: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var beschreibung: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var documents: Set<Document>?
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        createdAt = Date()
        updatedAt = Date()
    }
}

// MARK: - Document
@objc(Document)
public class Document: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var content: String
    @NSManaged public var createdAt: Date
    @NSManaged public var project: Project
    @NSManaged public var codings: Set<Coding>?
    @NSManaged public var originalFilename: String?
    @NSManaged public var importDate: Date?
    @NSManaged public var textLength: Int32
    @NSManaged public var language: String?
    @NSManaged public var codingStatusRaw: String?
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        createdAt = Date()
    }
    
    public var codingStatus: CodingStatus {
        get { CodingStatus(rawValue: codingStatusRaw ?? "notStarted") ?? .notStarted }
        set { codingStatusRaw = newValue.rawValue }
    }
}

// MARK: - Coding
@objc(Coding)
public class Coding: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var textSegment: String
    @NSManaged public var startIndex: Int32
    @NSManaged public var endIndex: Int32
    @NSManaged public var createdAt: Date
    @NSManaged public var document: Document
    @NSManaged public var marker: Marker
    @NSManaged public var markers: Set<Marker>
    @NSManaged public var memos: Set<Memo>?
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        createdAt = Date()
    }
}

// MARK: - Memo
@objc(Memo)
public class Memo: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var text: String
    @NSManaged public var createdAt: Date
    @NSManaged public var coding: Coding
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        createdAt = Date()
    }
}

// MARK: - MetaMarker
@objc(MetaMarker)
public class MetaMarker: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var beschreibung: String?
    @NSManaged public var zutaten: [String] // Marker-Namen als Strings
    @NSManaged public var threshold: Int16
    @NSManaged public var project: Project
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
    }
}

// MARK: - CodingStatus Enum (String-backed)
public enum CodingStatus: String {
    case notStarted
    case inProgress
    case done
}

// MARK: - Extensions für Set-Verwaltung
extension Marker {
    @objc(addExamplesObject:)
    @NSManaged public func addToExamples(_ value: MarkerExample)
    
    @objc(removeExamplesObject:)
    @NSManaged public func removeFromExamples(_ value: MarkerExample)
    
    @objc(addExamples:)
    @NSManaged public func addToExamples(_ values: NSSet)
    
    @objc(removeExamples:)
    @NSManaged public func removeFromExamples(_ values: NSSet)
}

extension Coding {
    @objc(addMarkersObject:)
    @NSManaged public func addToMarkers(_ value: Marker)
    
    @objc(removeMarkersObject:)
    @NSManaged public func removeFromMarkers(_ value: Marker)
    
    @objc(addMarkers:)
    @NSManaged public func addToMarkers(_ values: NSSet)
    
    @objc(removeMarkers:)
    @NSManaged public func removeFromMarkers(_ values: NSSet)
} 