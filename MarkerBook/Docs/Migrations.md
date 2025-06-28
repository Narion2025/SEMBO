# Core Data Migrations

> Version `2025-06-28-iteration-2`

| Version | Änderung | Beschreibung | Migration Schritte |
|---------|----------|--------------|-------------------|
| `1` | Initial | Marker, Category, MarkerExample, Project, Document, Coding | – |
| `2` | `MetaMarker` Entity | Speichert definierte Meta-Marker (Name, Beschreibung, Zutaten, Schwellenwert) | 1. Model Version `MarkerBookModel 2` anlegen <br>2. Neue Entity `MetaMarker` hinzufügen.<br>3. Beziehung `metaMarkers` ↔︎ `Project` (to-many) | 
| `3` | Attribute-Erweiterung `Document.language` | Sprachinfo für Analyse | Lightweight Migration |

---

## Aktuelle Model-Version

Die in `MarkerBookModel.xcdatamodeld` enthaltene Version heißt **`MarkerBookModel 1`**. Für jede Iteration, in der sich das Datenmodell ändert, wird eine neue Version erstellt und im Xcode-Model Editor als Current Version gesetzt.

## Migrationsstrategie

1. **Lightweight-Migration bevorzugen** – wenn nur Attribute/Entities hinzugefügt werden.
2. **Custom Migration** – wenn Beziehungen verschoben oder Attribute umbenannt werden (Mapping-Model erforderlich).
3. **Version Tagging** – jede Modell-Version erhält in Git ein Tag `model/vX`.

Dokument wird bei jeder Änderung erweitert. 