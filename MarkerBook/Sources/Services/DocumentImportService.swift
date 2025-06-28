import Foundation
import UniformTypeIdentifiers
import CoreData

/// Service zum Importieren von Textdokumenten in das Core-Data-Modell.
/// Unterstützt .txt und .md (UTF-8).
class DocumentImportService {
    enum ImportError: LocalizedError {
        case unsupportedType
        case readFailed
    }
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    /// Öffnet einen Dateiauswahldialog und importiert das Dokument.
    @MainActor
    func importDocumentViaOpenPanel(completion: @escaping (Result<Document, Error>) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [UTType.plainText, UTType.markdown]
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            Task {
                do {
                    let doc = try self.importDocument(from: url)
                    completion(.success(doc))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Importiert eine Datei von URL.
    func importDocument(from url: URL) throws -> Document {
        guard url.pathExtension.lowercased() == "txt" || url.pathExtension.lowercased() == "md" else {
            throw ImportError.unsupportedType
        }
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            throw ImportError.readFailed
        }
        let document = Document(context: context)
        document.name = url.deletingPathExtension().lastPathComponent
        document.originalFilename = url.lastPathComponent
        document.importDate = Date()
        document.content = content
        document.textLength = Int32(content.count)
        document.codingStatus = .notStarted
        // Sprache kann später via NLLanguageRecognizer ermittelt werden
        try context.save()
        return document
    }
} 