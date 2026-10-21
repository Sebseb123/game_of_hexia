# Game of Hexia

Game of Hexia ist ein in Dart und Flutter entwickeltes, von Siedler inspiriertes
Spiel. Aktuell liegt der Schwerpunkt auf dem Spielfeld und der Spiellogik. Eine
vollständige Benutzeroberfläche ist noch nicht umgesetzt.

## Aktueller Stand

- Hexagonales Spielfeld mit frei wählbarem Radius
- Geschlossenes Board aus eindeutigen Hexagons, Knoten (`Node`) und Kanten
  (`Edge`)
- Zufällige Verteilung der Ressourcenfelder und spiralförmige Platzierung der
  Zahlenchips
- Ermittlung benachbarter Knoten, Kanten und Hexagons
- Getrennter Spielzustand (`GameState`) und Regelsteuerung (`GameController`)
- Spieler, aktiver Spieler und einfacher Spielerwechsel
- Würfeln und Ressourcenproduktion für Siedlungen und Städte
- Grundlegende Platzierungs-, Upgrade- und Bezahlregeln für Gebäude und Straßen
- Ressourcenbank mit 19 Karten pro Rohstoff und kontrollierter Entnahme
- Vollständige Räubermechanik für die Konsole: Karten abwerfen, Zielfeld wählen,
  Räuber versetzen, Opfer auswählen und eine zufällige Karte stehlen
- Blockierte Ressourcenproduktion auf dem Feld des Räubers
- Entwicklungskartendeck mit Kaufmechanik sowie Effekten für Ritter, Monopol,
  Straßenbau und Erfindung
- Verdeckte Siegpunkte durch Entwicklungskarten
- Berechnung, Vergabe und Übertragung der größten Rittermacht
- Konsolenprototyp für Spielaufbau und einzelne Spielaktionen
- 36 automatisierte Tests und eine fehlerfreie statische Analyse
- Zufällige Verteilung der Häfen

### Bekannte Lücken

- Die größte Rittermacht wird berechnet und getestet, aber nach einer gespielten
  Ritterkarte noch nicht automatisch aktualisiert.
- Die längste Straße ist noch nicht implementiert. Im `GameState` existiert
  bisher nur der zukünftige Besitzerzustand `longestRoadOwner`.
- Die Ressourcenbank wird bereits für Karteneffekte verwendet, aber noch nicht
  vollständig in Produktion, Baukosten und Rückgaben eingebunden.
- Es gibt noch keinen vollständigen Zugablauf, keine vollständige Anfangsphase
  und keine Prüfung auf das Spielende.
- Eine grafische Benutzeroberfläche ist noch nicht umgesetzt.

Ein Standard-Board mit Radius 2 besteht aus:

- 19 Hexagons
- 54 Knoten
- 72 Kanten

## Projektstruktur

```text
bin/
└── test_game.dart

lib/
└── src/
    ├── logic/
    │   ├── dice.dart
    │   └── game_controller.dart
    └── models/
        ├── bank_of_resource.dart
        ├── building_type.dart
        ├── development_card_deck.dart
        ├── development_card_type.dart
        ├── edge.dart
        ├── game_state.dart
        ├── hexagon.dart
        ├── hexagon_board.dart
        ├── node.dart
        ├── player.dart
        ├── robber.dart
        └── resource_type.dart

test/
├── bank_of_resource_test.dart
├── development_card_test.dart
├── game_controller_test.dart
└── hexagon_board_test.dart
```

## Ausführen

Abhängigkeiten installieren:

```bash
flutter pub get
```

Den Konsolenprototyp starten:

```bash
dart run bin/test_game.dart
```

Alle Tests ausführen:

```bash
flutter test
```

Statische Codeanalyse ausführen:

```bash
flutter analyze
```

## Tests

Die derzeit 36 Tests prüfen unter anderem:

- Anzahl der Hexagons, Knoten und Kanten
- Gleichheit richtungsunabhängiger Kanten
- Benachbarte Knoten und Hexagons
- Würfelergebnisse und Ressourcenverteilung
- Berechnung und validiertes Abwerfen von Ressourcen bei einer 7
- Stehlen einer zufälligen Karte, auch bei leerer Hand des Opfers
- Blockierte Ressourcenproduktion auf dem Räuberfeld
- Grundregeln für die Platzierung von Siedlungen und Städten
- Zusammensetzung, Kauf und Effekte der Entwicklungskarten
- Ressourcenbank und begrenzte Kartenentnahme
- Vergabe und Wechsel der größten Rittermacht

## Nächste Schritte

### Spielfluss und Entwicklungskarten

- Vollständigen Zugablauf mit Würfeln, Aktionen und Zugwechsel umsetzen und
  testen
- Neu gekaufte Entwicklungskarten erst zu Beginn des nächsten eigenen Zugs
  spielbar machen
- Maximal eine Entwicklungskarte pro Zug erlauben
- Größte Rittermacht nach jeder gespielten Ritterkarte automatisch aktualisieren
- Tests für weniger als drei Ritter, Gleichstände und Besitzerwechsel ergänzen

### Bauen und Sonderpunkte

- Straßenverbindung bei der Platzierung von Siedlungen prüfen
- Regeln für die Anfangsphase mit zwei kostenlosen Siedlungen und Straßen
  ergänzen
- Startressourcen für die zweite Anfangssiedlung verteilen
- Längste Straße berechnen, Besitzerwechsel abbilden und Siegpunkte vergeben
- Platzierungs-, Upgrade- und Straßenregeln umfassender testen
- `BuildSuccess` als Rückgabewert der Baumethoden für die spätere GUI prüfen

### Ressourcen und Spielende

- Ressourcenbank in Produktion, Baukosten und Rückgaben einbinden
- Siegpunkte für Siedlungen und Städte vergeben
- Offene und versteckte Siegpunkte zu einem Gesamtwert zusammenführen
- Siegpunktkarten beim Spielende aufdecken
- Spielende bei zehn Siegpunkten erkennen

### Handel und Oberfläche

- Handel mit Bank unter Berücksichtigung der Häfen und mit Mitspielern implementieren
- Stabile Spieler-ID zusätzlich zur Spielerfarbe prüfen
- Benutzeroberfläche für Board und Spielaktionen entwickeln
