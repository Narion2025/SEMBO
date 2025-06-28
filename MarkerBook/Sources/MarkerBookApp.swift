import SwiftUI

@main
struct MarkerBookApp: App {
    let persistenceController = PersistenceController.shared
    
    @StateObject private var markerRepository = MarkerRepository()
    @StateObject private var categoryRepository = CategoryRepository()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(markerRepository)
                .environmentObject(categoryRepository)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            SidebarCommands()
            
            CommandGroup(replacing: .newItem) {
                Button("Neuer Marker") {
                    // Wird später implementiert
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("Neue Kategorie") {
                    // Wird später implementiert
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
        }
        
        Settings {
            SettingsView()
        }
    }
} 