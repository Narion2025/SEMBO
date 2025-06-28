# MarkerBook - Qualitative Inhaltsanalyse für macOS

MarkerBook ist eine native macOS-Anwendung für die qualitative Inhaltsanalyse (QDA). Das System ermöglicht die systematische Analyse von Textdaten durch ein wissenschaftlich fundiertes Kategoriensystem und die automatische Generierung von Python-Skripten für die Textanalyse.

## Features

### 🎯 Kernfunktionen

- **Codebuch-Verwaltung**: Erstellen und verwalten Sie Marker (Codes) mit detaillierten Definitionen, Ankerbeispielen und Kodierregeln
- **Hierarchische Kategorisierung**: Organisieren Sie Marker in einer flexiblen Baumstruktur mit Drag-and-Drop
- **Beispiel-Management**: Dokumentieren Sie die Bandbreite jedes Markers mit bewerteten Beispielen
- **YAML Import/Export**: Nahtlose Integration bestehender Marker-Sammlungen
- **Wissenschaftliche Methodik**: Unterstützt deduktive und induktive Vorgehensweisen der QDA

### 📊 Geplante Features (Iteration 2+)

- Kodier-Interface für Textanalyse
- Kookkurrenz-Analyse und Meta-Marker
- Python-Skript-Generierung
- Erweiterte Analysefunktionen

## Installation

### Voraussetzungen

- macOS 13.0 (Ventura) oder neuer
- Xcode 15.0 oder neuer
- Swift 5.9

### Build-Anleitung

1. Repository klonen:
```bash
git clone https://github.com/Narion2025/SEMBO.git
cd SEMBO_Semantic_marker_book/MarkerBook
```

2. Dependencies installieren:
```bash
swift package resolve
```

3. Projekt in Xcode öffnen:
```bash
open Package.swift
```

4. Build und Run (⌘+R)

## Verwendung

### Marker erstellen

1. Klicken Sie auf "Neuer Marker" in der Toolbar
2. Füllen Sie die Pflichtfelder aus:
   - **Marker-Name**: Prägnanter, eindeutiger Name
   - **Definition**: Klare Beschreibung des Konzepts
   - **Ankerbeispiel**: Idealtypisches Beispiel
   - **Kodierregeln**: Abgrenzung zu ähnlichen Markern
3. Optional: Tags und Kategorie zuweisen
4. Speichern

### Kategorien verwalten

1. Navigieren Sie zur Kategorie-Verwaltung
2. Erstellen Sie neue Kategorien mit "Neue Kategorie"
3. Organisieren Sie per Drag-and-Drop
4. Unterkategorien durch Ziehen auf Elternkategorien erstellen

### YAML Import

1. Bereiten Sie YAML-Dateien im folgenden Format vor:

```yaml
marker_name: "Schuldgefühle erzeugen"
definition: "Aussagen, die beim Gegenüber Schuldgefühle hervorrufen sollen"
ankerbeispiel: "Wenn du mich wirklich lieben würdest, dann..."
kodierregeln_abgrenzung: "Nur wenn explizit oder implizit Schuld zugewiesen wird"
tags:
  - manipulation
  - emotional
examples:
  - text: "Nach allem, was ich für dich getan habe..."
    kontext: "Partnerschaft"
    subtilitaet: 3
```

2. Nutzen Sie die Import-Funktion im Menü
3. Wählen Sie die YAML-Datei(en) aus

## Architektur

### Tech Stack

- **UI**: SwiftUI
- **Persistenz**: Core Data
- **Architektur**: MVVM mit Repository Pattern
- **Testing**: XCTest (Unit & UI Tests)

### Projektstruktur

```
MarkerBook/
├── Sources/
│   ├── Models/          # Core Data Entities
│   ├── Views/           # SwiftUI Views
│   ├── ViewModels/      # View Models
│   ├── Repositories/    # Data Access Layer
│   ├── Services/        # Business Logic
│   └── Utils/           # Hilfsfunktionen
├── Tests/
│   ├── UnitTests/       # Unit Tests
│   └── UITests/         # UI Tests
└── Resources/           # Assets, Lokalisierung
```

## Testing

### Unit Tests ausführen

```bash
swift test
```

### UI Tests ausführen

In Xcode: Product → Test (⌘+U)

### Test Coverage

Aktuelle Coverage: ~80% für Core-Funktionalität

## Entwicklung

### Code Style

Das Projekt verwendet SwiftLint für konsistenten Code-Stil. Konfiguration in `.swiftlint.yml`.

### Branching Strategy

- `main`: Stabiler Release-Branch
- `develop`: Entwicklungs-Branch
- `feature/*`: Feature-Branches
- `bugfix/*`: Bugfix-Branches

### Commit Messages

Folgen Sie dem Conventional Commits Standard:
- `feat:` Neue Features
- `fix:` Bugfixes
- `docs:` Dokumentation
- `test:` Tests
- `refactor:` Refactoring

## Mitwirken

1. Fork des Repositories erstellen
2. Feature Branch erstellen (`git checkout -b feature/AmazingFeature`)
3. Änderungen committen (`git commit -m 'feat: Add some AmazingFeature'`)
4. Branch pushen (`git push origin feature/AmazingFeature`)
5. Pull Request erstellen

## Lizenz

Dieses Projekt ist lizenziert unter der MIT License - siehe [LICENSE](LICENSE) für Details.

## Kontakt

Projektleitung: [Ihr Name]

Projekt Link: [https://github.com/Narion2025/SEMBO](https://github.com/Narion2025/SEMBO)

## Danksagungen

- Inspiration durch professionelle QDA-Software wie MAXQDA und ATLAS.ti
- Swift Community für exzellente Open-Source-Pakete
- Alle Mitwirkenden und Tester 