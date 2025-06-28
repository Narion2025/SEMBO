import SwiftUI

struct ContentView: View {
    @State private var selectedModule: NavigationModule = .codebook
    @State private var sidebarVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $sidebarVisibility) {
            // Sidebar
            SidebarView(selectedModule: $selectedModule)
        } content: {
            // Content Area basierend auf ausgewähltem Modul
            switch selectedModule {
            case .codebook:
                CodebookView()
            case .coding:
                CodingView()
            case .analysis:
                AnalysisView()
            case .export:
                ExportView()
            }
        } detail: {
            // Detail View (für ausgewählte Items)
            Text("Detail-Ansicht")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.controlBackgroundColor))
        }
        .navigationSplitViewStyle(.balanced)
    }
}

// MARK: - Navigation Module
enum NavigationModule: String, CaseIterable {
    case codebook = "Codebuch"
    case coding = "Kodierung"
    case analysis = "Analyse"
    case export = "Export"
    
    var icon: String {
        switch self {
        case .codebook: return "book.closed"
        case .coding: return "pencil.and.outline"
        case .analysis: return "chart.xyaxis.line"
        case .export: return "square.and.arrow.up"
        }
    }
}

// MARK: - Sidebar View
struct SidebarView: View {
    @Binding var selectedModule: NavigationModule
    @EnvironmentObject var markerRepository: MarkerRepository
    @EnvironmentObject var categoryRepository: CategoryRepository
    
    var body: some View {
        List(selection: $selectedModule) {
            Section("Module") {
                ForEach(NavigationModule.allCases, id: \.self) { module in
                    NavigationLink(value: module) {
                        Label(module.rawValue, systemImage: module.icon)
                    }
                }
            }
            
            if selectedModule == .codebook {
                Section("Kategorien") {
                    CategoryTreeView(categories: categoryRepository.getCategoryTree())
                }
                
                Section("Schnellzugriff") {
                    Label("Alle Marker", systemImage: "tag")
                        .badge(markerRepository.markers.count)
                    Label("Ohne Kategorie", systemImage: "questionmark.folder")
                    Label("Zuletzt bearbeitet", systemImage: "clock")
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Marker Book")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
            }
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?
            .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

// MARK: - Category Tree View
struct CategoryTreeView: View {
    let categories: [CategoryNode]
    
    var body: some View {
        ForEach(categories, id: \.category.id) { node in
            DisclosureGroup {
                if !node.children.isEmpty {
                    CategoryTreeView(categories: node.children)
                }
            } label: {
                HStack {
                    Image(systemName: "folder")
                    Text(node.category.name)
                    Spacer()
                    if node.markerCount > 0 {
                        Text("\(node.markerCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Placeholder Views
struct CodebookView: View {
    var body: some View {
        MarkerListView()
    }
}

struct CodingView: View {
    var body: some View {
        Text("Kodierungs-Modul")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AnalysisView: View {
    var body: some View {
        Text("Analyse-Modul")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ExportView: View {
    var body: some View {
        Text("Export-Modul")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Einstellungen")
            .frame(width: 400, height: 300)
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(MarkerRepository(persistenceController: .preview))
            .environmentObject(CategoryRepository(persistenceController: .preview))
    }
} 