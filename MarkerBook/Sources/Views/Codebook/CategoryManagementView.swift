import SwiftUI

struct CategoryManagementView: View {
    @EnvironmentObject var categoryRepository: CategoryRepository
    @EnvironmentObject var markerRepository: MarkerRepository
    @State private var selectedCategory: Category?
    @State private var showingCreateSheet = false
    @State private var showingEditSheet = false
    @State private var draggedCategory: Category?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Kategorie-Verwaltung")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button(action: { showingCreateSheet = true }) {
                    Label("Neue Kategorie", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            Divider()
            
            // Kategorie-Baum
            HStack(spacing: 0) {
                // Linke Seite: Kategorie-Hierarchie
                VStack(alignment: .leading, spacing: 0) {
                    Text("Kategorie-Hierarchie")
                        .font(.headline)
                        .padding()
                    
                    Divider()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(categoryRepository.getCategoryTree(), id: \.category.id) { node in
                                CategoryNodeView(
                                    node: node,
                                    selectedCategory: $selectedCategory,
                                    draggedCategory: $draggedCategory,
                                    level: 0
                                )
                            }
                            
                            // Drop-Zone für Root-Level
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 40)
                                .overlay(
                                    Text("Hierher ziehen für Root-Ebene")
                                        .foregroundColor(.secondary)
                                        .opacity(draggedCategory != nil ? 0.6 : 0)
                                )
                                .onDrop(of: [.text], isTargeted: nil) { providers in
                                    handleDrop(to: nil)
                                    return true
                                }
                        }
                        .padding()
                    }
                }
                .frame(width: 350)
                .background(Color(NSColor.controlBackgroundColor))
                
                Divider()
                
                // Rechte Seite: Details
                if let category = selectedCategory {
                    CategoryDetailView(category: category)
                        .id(category.id)
                } else {
                    VStack {
                        Image(systemName: "folder")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Keine Kategorie ausgewählt")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            CategoryEditView(category: nil, parentCategory: nil)
        }
    }
    
    private func handleDrop(to parent: Category?) -> Bool {
        guard let draggedCategory = draggedCategory else { return false }
        
        do {
            try categoryRepository.moveCategory(draggedCategory, to: parent)
            return true
        } catch {
            print("Fehler beim Verschieben: \(error)")
            return false
        }
    }
}

// MARK: - Category Node View
struct CategoryNodeView: View {
    let node: CategoryNode
    @Binding var selectedCategory: Category?
    @Binding var draggedCategory: Category?
    let level: Int
    
    @State private var isExpanded = true
    @State private var isTargeted = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                // Einrückung basierend auf Level
                ForEach(0..<level, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 20)
                }
                
                // Expand/Collapse Button
                if !node.children.isEmpty {
                    Button(action: { isExpanded.toggle() }) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 16)
                }
                
                // Kategorie-Item
                HStack {
                    Image(systemName: "folder")
                        .foregroundColor(selectedCategory?.id == node.category.id ? .white : .accentColor)
                    
                    Text(node.category.name)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if node.markerCount > 0 {
                        Text("\(node.markerCount)")
                            .font(.caption)
                            .foregroundColor(selectedCategory?.id == node.category.id ? .white : .secondary)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(selectedCategory?.id == node.category.id ? Color.accentColor : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isTargeted ? Color.accentColor : Color.clear, lineWidth: 2)
                )
                .onTapGesture {
                    selectedCategory = node.category
                }
                .draggable(node.category.id.uuidString) {
                    HStack {
                        Image(systemName: "folder")
                        Text(node.category.name)
                    }
                    .padding(4)
                    .background(Color.accentColor.opacity(0.2))
                    .cornerRadius(4)
                    .onAppear {
                        draggedCategory = node.category
                    }
                }
                .onDrop(of: [.text], isTargeted: $isTargeted) { providers in
                    guard draggedCategory?.id != node.category.id else { return false }
                    return handleDrop(to: node.category)
                }
            }
            
            // Kinder
            if isExpanded && !node.children.isEmpty {
                ForEach(node.children, id: \.category.id) { childNode in
                    CategoryNodeView(
                        node: childNode,
                        selectedCategory: $selectedCategory,
                        draggedCategory: $draggedCategory,
                        level: level + 1
                    )
                }
            }
        }
    }
    
    private func handleDrop(to target: Category) -> Bool {
        guard let draggedCategory = draggedCategory else { return false }
        
        do {
            try CategoryRepository().moveCategory(draggedCategory, to: target)
            return true
        } catch {
            print("Fehler beim Verschieben: \(error)")
            return false
        }
    }
}

// MARK: - Category Detail View
struct CategoryDetailView: View {
    let category: Category
    @EnvironmentObject var categoryRepository: CategoryRepository
    @EnvironmentObject var markerRepository: MarkerRepository
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var categoryMarkers: [Marker] {
        categoryRepository.getAllMarkers(for: category, includeSubcategories: false)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(category.name)
                        .font(.title)
                        .bold()
                    
                    if let parent = category.parent {
                        Label(parent.name, systemImage: "folder")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                HStack {
                    Button(action: { showingEditSheet = true }) {
                        Label("Bearbeiten", systemImage: "pencil")
                    }
                    
                    Button(action: { showingDeleteAlert = true }) {
                        Label("Löschen", systemImage: "trash")
                    }
                    .foregroundColor(.red)
                    .disabled(!(category.markers?.isEmpty ?? true) || !(category.subcategories?.isEmpty ?? true))
                }
            }
            .padding()
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Beschreibung
                    if let beschreibung = category.beschreibung {
                        GroupBox {
                            VStack(alignment: .leading) {
                                Label("Beschreibung", systemImage: "text.alignleft")
                                    .font(.headline)
                                Text(beschreibung)
                                    .textSelection(.enabled)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    // Marker in dieser Kategorie
                    GroupBox {
                        VStack(alignment: .leading) {
                            Label("Marker in dieser Kategorie", systemImage: "tag")
                                .font(.headline)
                            
                            if categoryMarkers.isEmpty {
                                Text("Keine Marker in dieser Kategorie")
                                    .foregroundColor(.secondary)
                                    .italic()
                            } else {
                                ForEach(categoryMarkers, id: \.id) { marker in
                                    HStack {
                                        Image(systemName: "tag.fill")
                                            .foregroundColor(.accentColor)
                                        Text(marker.markerName)
                                        Spacer()
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Statistiken
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Statistiken", systemImage: "chart.bar")
                                .font(.headline)
                            
                            HStack {
                                Text("Direkte Marker:")
                                    .foregroundColor(.secondary)
                                Text("\(category.markers?.count ?? 0)")
                            }
                            
                            HStack {
                                Text("Unterkategorien:")
                                    .foregroundColor(.secondary)
                                Text("\(category.subcategories?.count ?? 0)")
                            }
                            
                            HStack {
                                Text("Marker gesamt (inkl. Unterkategorien):")
                                    .foregroundColor(.secondary)
                                Text("\(categoryRepository.getAllMarkers(for: category).count)")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            CategoryEditView(category: category, parentCategory: category.parent)
        }
        .alert("Kategorie löschen?", isPresented: $showingDeleteAlert) {
            Button("Abbrechen", role: .cancel) { }
            Button("Löschen", role: .destructive) {
                deleteCategory()
            }
        } message: {
            Text("Möchten Sie die Kategorie '\(category.name)' wirklich löschen?")
        }
    }
    
    private func deleteCategory() {
        do {
            try categoryRepository.deleteCategory(category)
        } catch {
            print("Fehler beim Löschen: \(error)")
        }
    }
} 