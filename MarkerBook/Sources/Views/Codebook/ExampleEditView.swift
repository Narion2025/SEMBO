import SwiftUI

struct ExampleEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var markerRepository: MarkerRepository
    
    let marker: Marker
    let example: MarkerExample?
    
    @State private var text: String = ""
    @State private var kontext: String = ""
    @State private var beziehungstyp: String = ""
    @State private var subtilitaet: Int16 = 3
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(marker: Marker, example: MarkerExample?) {
        self.marker = marker
        self.example = example
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(example == nil ? "Neues Beispiel" : "Beispiel bearbeiten")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button("Abbrechen") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                
                Button("Speichern") {
                    saveExample()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
                .disabled(text.isEmpty)
            }
            .padding()
            
            Divider()
            
            // Formular
            Form {
                Section("Beispieltext") {
                    VStack(alignment: .leading) {
                        Text("Text")
                            .font(.headline)
                        TextEditor(text: $text)
                            .frame(minHeight: 100)
                            .help("Das konkrete Beispiel für den Marker")
                    }
                }
                
                Section("Metadaten") {
                    TextField("Kontext", text: $kontext)
                        .help("In welchem Kontext tritt dieses Beispiel auf?")
                    
                    TextField("Beziehungstyp", text: $beziehungstyp)
                        .help("z.B. Partner, Familie, Freunde, Arbeit")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Subtilität")
                        HStack {
                            Text("1")
                                .font(.caption)
                            Slider(value: Binding(
                                get: { Double(subtilitaet) },
                                set: { subtilitaet = Int16($0) }
                            ), in: 1...5, step: 1)
                            Text("5")
                                .font(.caption)
                        }
                        Text("Aktuell: \(subtilitaet) - \(subtilitaetBeschreibung)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Zugehöriger Marker") {
                    HStack {
                        Image(systemName: "tag")
                        Text(marker.markerName)
                            .font(.headline)
                    }
                    .padding(.vertical, 4)
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .frame(width: 500, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            loadExampleData()
        }
        .alert("Fehler", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var subtilitaetBeschreibung: String {
        switch subtilitaet {
        case 1: return "Sehr offensichtlich"
        case 2: return "Deutlich erkennbar"
        case 3: return "Mittel"
        case 4: return "Subtil"
        case 5: return "Sehr subtil"
        default: return ""
        }
    }
    
    private func loadExampleData() {
        guard let example = example else { return }
        
        text = example.text
        kontext = example.kontext ?? ""
        beziehungstyp = example.beziehungstyp ?? ""
        subtilitaet = example.subtilitaet
    }
    
    private func saveExample() {
        do {
            if example != nil {
                // Update existing example
                example?.text = text
                example?.kontext = kontext.isEmpty ? nil : kontext
                example?.beziehungstyp = beziehungstyp.isEmpty ? nil : beziehungstyp
                example?.subtilitaet = subtilitaet
                
                try markerRepository.updateMarker(marker)
            } else {
                // Create new example
                try markerRepository.addExample(
                    to: marker,
                    text: text,
                    kontext: kontext.isEmpty ? nil : kontext,
                    beziehungstyp: beziehungstyp.isEmpty ? nil : beziehungstyp,
                    subtilitaet: subtilitaet
                )
            }
            
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
} 