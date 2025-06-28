import SwiftUI

struct MarkerEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var markerRepository: MarkerRepository
    @EnvironmentObject var categoryRepository: CategoryRepository
    
    let marker: Marker?
    
    @State private var markerName: String = ""
    @State private var definition: String = ""
    @State private var ankerbeispiel: String = ""
    @State private var kodierregeln: String = ""
    @State private var selectedCategory: Category?
    @State private var tags: String = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(marker: Marker?) {
        self.marker = marker
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(marker == nil ? "Neuer Marker" : "Marker bearbeiten")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button("Abbrechen") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                
                Button("Speichern") {
                    saveMarker()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
                .disabled(markerName.isEmpty || definition.isEmpty || ankerbeispiel.isEmpty || kodierregeln.isEmpty)
            }
            .padding()
            
            Divider()
            
            // Formular
            Form {
                Section("Grundinformationen") {
                    TextField("Marker-Name", text: $markerName)
                        .help("Ein kurzer, prägnanter Name für den Marker")
                    
                    Picker("Kategorie", selection: $selectedCategory) {
                        Text("Keine Kategorie").tag(nil as Category?)
                        Divider()
                        ForEach(categoryRepository.categories, id: \.id) { category in
                            Text(category.name).tag(category as Category?)
                        }
                    }
                    
                    TextField("Tags (kommagetrennt)", text: $tags)
                        .help("z.B. manipulation, emotional, schuld")
                }
                
                Section("Definition") {
                    VStack(alignment: .leading) {
                        Text("Definition")
                            .font(.headline)
                        TextEditor(text: $definition)
                            .frame(minHeight: 80)
                            .help("Eine klare, eindeutige Beschreibung des Markers")
                    }
                }
                
                Section("Ankerbeispiel") {
                    VStack(alignment: .leading) {
                        Text("Ankerbeispiel")
                            .font(.headline)
                        TextEditor(text: $ankerbeispiel)
                            .frame(minHeight: 60)
                            .help("Ein idealtypisches Zitat, das den Marker perfekt repräsentiert")
                    }
                }
                
                Section("Kodierregeln & Abgrenzung") {
                    VStack(alignment: .leading) {
                        Text("Kodierregeln & Abgrenzung")
                            .font(.headline)
                        TextEditor(text: $kodierregeln)
                            .frame(minHeight: 80)
                            .help("Wann wird der Marker vergeben? Wie unterscheidet er sich von ähnlichen Markern?")
                    }
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .frame(width: 600, height: 700)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            loadMarkerData()
        }
        .alert("Fehler", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func loadMarkerData() {
        guard let marker = marker else { return }
        
        markerName = marker.markerName
        definition = marker.definition
        ankerbeispiel = marker.ankerbeispiel
        kodierregeln = marker.kodierregelnAbgrenzung
        selectedCategory = marker.category
        tags = marker.tags?.joined(separator: ", ") ?? ""
    }
    
    private func saveMarker() {
        do {
            let tagArray = tags.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            
            if let existingMarker = marker {
                // Update existing marker
                existingMarker.markerName = markerName
                existingMarker.definition = definition
                existingMarker.ankerbeispiel = ankerbeispiel
                existingMarker.kodierregelnAbgrenzung = kodierregeln
                existingMarker.category = selectedCategory
                existingMarker.tags = tagArray
                
                try markerRepository.updateMarker(existingMarker)
            } else {
                // Create new marker
                _ = try markerRepository.createMarker(
                    name: markerName,
                    definition: definition,
                    ankerbeispiel: ankerbeispiel,
                    kodierregeln: kodierregeln,
                    tags: tagArray,
                    category: selectedCategory
                )
            }
            
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
} 