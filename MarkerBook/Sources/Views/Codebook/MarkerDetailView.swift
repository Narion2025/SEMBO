import SwiftUI

struct MarkerDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var markerRepository: MarkerRepository
    
    let marker: Marker
    
    @State private var showingEditSheet = false
    @State private var showingAddExampleSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(marker.markerName)
                        .font(.largeTitle)
                        .bold()
                    
                    if let category = marker.category {
                        Label(category.name, systemImage: "folder")
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: { showingEditSheet = true }) {
                        Label("Bearbeiten", systemImage: "pencil")
                    }
                    
                    Button(action: { showingDeleteAlert = true }) {
                        Label("Löschen", systemImage: "trash")
                    }
                    .foregroundColor(.red)
                    
                    Button("Schließen") {
                        dismiss()
                    }
                    .keyboardShortcut(.escape)
                }
            }
            .padding()
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Tags
                    if let tags = marker.tags, !tags.isEmpty {
                        HStack {
                            ForEach(tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    
                    // Definition
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Definition", systemImage: "text.quote")
                                .font(.headline)
                            Text(marker.definition)
                                .textSelection(.enabled)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Ankerbeispiel
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Ankerbeispiel", systemImage: "bookmark")
                                .font(.headline)
                            Text(marker.ankerbeispiel)
                                .textSelection(.enabled)
                                .italic()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Kodierregeln
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Kodierregeln & Abgrenzung", systemImage: "checklist")
                                .font(.headline)
                            Text(marker.kodierregelnAbgrenzung)
                                .textSelection(.enabled)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Beispiele
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Weitere Beispiele", systemImage: "list.bullet.rectangle")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button(action: { showingAddExampleSheet = true }) {
                                    Label("Beispiel hinzufügen", systemImage: "plus.circle")
                                }
                                .buttonStyle(.link)
                            }
                            
                            if let examples = marker.examples, !examples.isEmpty {
                                ForEach(Array(examples), id: \.id) { example in
                                    ExampleRowView(example: example, marker: marker)
                                }
                            } else {
                                Text("Noch keine weiteren Beispiele vorhanden")
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Metadaten
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Metadaten", systemImage: "info.circle")
                                .font(.headline)
                            
                            HStack {
                                Text("Erstellt:")
                                    .foregroundColor(.secondary)
                                Text(marker.createdAt.formatted())
                            }
                            
                            HStack {
                                Text("Zuletzt geändert:")
                                    .foregroundColor(.secondary)
                                Text(marker.updatedAt.formatted())
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
        }
        .frame(width: 700, height: 800)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showingEditSheet) {
            MarkerEditView(marker: marker)
        }
        .sheet(isPresented: $showingAddExampleSheet) {
            ExampleEditView(marker: marker, example: nil)
        }
        .alert("Marker löschen?", isPresented: $showingDeleteAlert) {
            Button("Abbrechen", role: .cancel) { }
            Button("Löschen", role: .destructive) {
                deleteMarker()
            }
        } message: {
            Text("Möchten Sie den Marker '\(marker.markerName)' wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.")
        }
    }
    
    private func deleteMarker() {
        do {
            try markerRepository.deleteMarker(marker)
            dismiss()
        } catch {
            // Fehlerbehandlung
            print("Fehler beim Löschen: \(error)")
        }
    }
}

// MARK: - Example Row View
struct ExampleRowView: View {
    let example: MarkerExample
    let marker: Marker
    @EnvironmentObject var markerRepository: MarkerRepository
    @State private var showingEditSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(example.text)
                .textSelection(.enabled)
            
            HStack(spacing: 16) {
                if let kontext = example.kontext {
                    Label(kontext, systemImage: "text.bubble")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let beziehung = example.beziehungstyp {
                    Label(beziehung, systemImage: "person.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Label("Subtilität: \(example.subtilitaet)/5", systemImage: "dial.low")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: { showingEditSheet = true }) {
                    Image(systemName: "pencil")
                }
                .buttonStyle(.plain)
                
                Button(action: { deleteExample() }) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .sheet(isPresented: $showingEditSheet) {
            ExampleEditView(marker: marker, example: example)
        }
    }
    
    private func deleteExample() {
        do {
            try markerRepository.removeExample(example, from: marker)
        } catch {
            print("Fehler beim Löschen des Beispiels: \(error)")
        }
    }
} 