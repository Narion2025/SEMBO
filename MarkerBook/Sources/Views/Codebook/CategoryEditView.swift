import SwiftUI

struct CategoryEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var categoryRepository: CategoryRepository
    
    let category: Category?
    let parentCategory: Category?
    
    @State private var name: String = ""
    @State private var beschreibung: String = ""
    @State private var selectedParent: Category?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(category: Category?, parentCategory: Category?) {
        self.category = category
        self.parentCategory = parentCategory
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(category == nil ? "Neue Kategorie" : "Kategorie bearbeiten")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button("Abbrechen") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                
                Button("Speichern") {
                    saveCategory()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty)
            }
            .padding()
            
            Divider()
            
            // Formular
            Form {
                Section("Grundinformationen") {
                    TextField("Kategorie-Name", text: $name)
                        .help("Ein eindeutiger Name für die Kategorie")
                    
                    Picker("Übergeordnete Kategorie", selection: $selectedParent) {
                        Text("Keine (Root-Kategorie)").tag(nil as Category?)
                        Divider()
                        ForEach(getAvailableParents(), id: \.id) { cat in
                            HStack {
                                ForEach(0..<getLevel(for: cat), id: \.self) { _ in
                                    Text("  ")
                                }
                                Text(cat.name)
                            }
                            .tag(cat as Category?)
                        }
                    }
                    .help("Die übergeordnete Kategorie in der Hierarchie")
                }
                
                Section("Beschreibung") {
                    VStack(alignment: .leading) {
                        Text("Beschreibung (optional)")
                            .font(.headline)
                        TextEditor(text: $beschreibung)
                            .frame(minHeight: 100)
                            .help("Eine optionale Beschreibung der Kategorie")
                    }
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
        .frame(width: 500, height: 400)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            loadCategoryData()
        }
        .alert("Fehler", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func loadCategoryData() {
        if let category = category {
            name = category.name
            beschreibung = category.beschreibung ?? ""
            selectedParent = category.parent
        } else {
            selectedParent = parentCategory
        }
    }
    
    private func saveCategory() {
        do {
            if let existingCategory = category {
                // Update existing category
                existingCategory.name = name
                existingCategory.beschreibung = beschreibung.isEmpty ? nil : beschreibung
                
                // Nur Parent ändern wenn es sich geändert hat
                if existingCategory.parent != selectedParent {
                    try categoryRepository.moveCategory(existingCategory, to: selectedParent)
                } else {
                    try categoryRepository.updateCategory(existingCategory)
                }
            } else {
                // Create new category
                _ = try categoryRepository.createCategory(
                    name: name,
                    beschreibung: beschreibung.isEmpty ? nil : beschreibung,
                    parent: selectedParent
                )
            }
            
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func getAvailableParents() -> [Category] {
        // Filtere die aktuelle Kategorie und ihre Unterkategorien aus
        guard let currentCategory = category else {
            return categoryRepository.categories
        }
        
        return categoryRepository.categories.filter { cat in
            // Nicht die aktuelle Kategorie selbst
            if cat.id == currentCategory.id {
                return false
            }
            
            // Nicht die Nachfahren der aktuellen Kategorie
            return !isDescendant(of: currentCategory, candidate: cat)
        }
    }
    
    private func isDescendant(of ancestor: Category, candidate: Category) -> Bool {
        var current: Category? = candidate
        while let parent = current?.parent {
            if parent.id == ancestor.id {
                return true
            }
            current = parent
        }
        return false
    }
    
    private func getLevel(for category: Category) -> Int {
        var level = 0
        var current: Category? = category
        while let parent = current?.parent {
            level += 1
            current = parent
        }
        return level
    }
} 