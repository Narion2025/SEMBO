import SwiftUI

/// SplitView für Text + Codebuch, inklusive Segmentierung & Kodierung.
struct CodingWorkspaceView: View {
    @State private var selectedDocument: Document?
    @State private var selectedTextRange: NSRange = .init(location: 0, length: 0)
    @State private var showMarkerSheet = false
    @EnvironmentObject var markerRepo: MarkerRepository
    @EnvironmentObject var importService: DocumentImportService
    
    var body: some View {
        NavigationSplitView {
            // Dokumentenliste (Platzhalter)
            Text("Dokumente-Liste (kommt in Iteration 2)")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } content: {
            // Textanzeige + Segmentierung (Platzhalter)
            Text("Textinhalt…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.textBackgroundColor))
                .contextMenu {
                    Button("Neuen Marker erstellen …") {
                        showMarkerSheet = true
                    }
                }
        } detail: {
            // Codebuch Panel (Wiederverwendung MarkerListView)
            MarkerListView()
        }
        .sheet(isPresented: $showMarkerSheet) {
            MarkerEditView(marker: nil)
        }
    }
}

struct CodingWorkspaceView_Previews: PreviewProvider {
    static var previews: some View {
        CodingWorkspaceView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(MarkerRepository(persistenceController: .preview))
            .environmentObject(DocumentImportService(context: PersistenceController.preview.container.viewContext))
    }
} 