import SwiftUI

struct MarkerListView: View {
    @EnvironmentObject var markerRepository: MarkerRepository
    @State private var selectedMarker: Marker?
    @State private var showingCreateSheet = false
    @State private var searchText = ""
    @State private var sortOrder: MarkerSortOrder = .name
    
    var filteredMarkers: [Marker] {
        let markers = markerRepository.markers
        
        // Suchfilter anwenden
        let filtered = searchText.isEmpty ? markers : markers.filter { marker in
            marker.markerName.localizedCaseInsensitiveContains(searchText) ||
            marker.definition.localizedCaseInsensitiveContains(searchText) ||
            marker.ankerbeispiel.localizedCaseInsensitiveContains(searchText) ||
            (marker.tags?.contains { $0.localizedCaseInsensitiveContains(searchText) } ?? false)
        }
        
        // Sortierung anwenden
        return filtered.sorted { first, second in
            switch sortOrder {
            case .name:
                return first.markerName < second.markerName
            case .dateCreated:
                return first.createdAt > second.createdAt
            case .dateModified:
                return first.updatedAt > second.updatedAt
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                // Suchfeld
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Marker suchen...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                
                Spacer()
                
                // Sortierung
                Picker("Sortierung", selection: $sortOrder) {
                    Label("Name", systemImage: "textformat").tag(MarkerSortOrder.name)
                    Label("Erstellt", systemImage: "calendar").tag(MarkerSortOrder.dateCreated)
                    Label("Geändert", systemImage: "clock").tag(MarkerSortOrder.dateModified)
                }
                .pickerStyle(.menu)
                .frame(width: 150)
                
                // Neuer Marker Button
                Button(action: { showingCreateSheet = true }) {
                    Label("Neuer Marker", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            Divider()
            
            // Marker-Liste
            if filteredMarkers.isEmpty {
                VStack {
                    Image(systemName: "tag.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Keine Marker gefunden")
                        .font(.title2)
                        .padding(.top)
                    Text("Erstellen Sie einen neuen Marker oder ändern Sie Ihre Suchkriterien")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(selection: $selectedMarker) {
                    ForEach(filteredMarkers, id: \.id) { marker in
                        MarkerRowView(marker: marker)
                            .tag(marker)
                    }
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            MarkerEditView(marker: nil)
        }
        .sheet(item: $selectedMarker) { marker in
            MarkerDetailView(marker: marker)
        }
    }
}

// MARK: - Marker Row View
struct MarkerRowView: View {
    let marker: Marker
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(marker.markerName)
                    .font(.headline)
                
                Spacer()
                
                if let category = marker.category {
                    Text(category.name)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            Text(marker.definition)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            if let tags = marker.tags, !tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(tags.prefix(3), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    if tags.count > 3 {
                        Text("+\(tags.count - 3)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Sort Order
enum MarkerSortOrder {
    case name, dateCreated, dateModified
} 