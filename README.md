# Game of Hexia

Game of Hexia ist ein in Dart und Flutter entwickeltes, von Siedler inspiriertes
Spiel. Aktuell liegt der Schwerpunkt auf dem Spielfeld und der Spiellogik. Eine
vollständige Benutzeroberfläche ist noch nicht umgesetzt.

## Aktueller Stand

- Hexagonales Spielfeld mit frei wählbarem Radius
- Strukturierung der Klassen
- Korrekte Anordnung der Reihen zu einem geschlossenen Board
- Modellierung von Kanten
- Zufällige Verteilung der Ressourcenfelder
- Platzierung der Zahlenchips
- Eindeutige Knoten (`Node`) an den Hexagon-Ecken
- Eindeutige Kanten (`Edge`) zwischen benachbarten Knoten
- Ermittlung benachbarter Knoten und Hexagons
- Spieler und Spielerwechsel
- Würfeln und Verteilen von Ressourcen an Siedlungen und Städte
- Prüfung der grundlegenden Bedingungen für Siedlungen und Städte

Ein Standard-Board mit Radius 2 besteht aus:

- 19 Hexagons
- 54 Knoten
- 72 Kanten

## Projektstruktur

```text
lib/
└── src/
    ├── logic/
    │   ├── dice.dart
    │   └── game_controller.dart
    └── models/
        ├── building_type.dart
        ├── edge.dart
        ├── hexagon.dart
        ├── hexagon_board.dart
        ├── node.dart
        ├── player.dart
        └── resource_type.dart

test/
├── game_controller_test.dart
└── hexagon_board_test.dart
```

## Ausführen

Abhängigkeiten installieren:

```bash
flutter pub get
```

Die Konsolenausgabe des Boards starten:

```bash
dart run bin/test_game.dart
```

Alle Tests ausführen:

```bash
flutter test
```

Statische Codeanalyse ausführen:

```bash
dart analyze
```

## Tests

Die vorhandenen Tests prüfen unter anderem:

- Anzahl der Hexagons, Knoten und Kanten
- Gleichheit richtungsunabhängiger Kanten
- Benachbarte Knoten und Hexagons
- Würfelergebnisse und Ressourcenverteilung
- Grundregeln für die Platzierung von Siedlungen und Städten

## Nächste Schritte

- Straßen mit Besitzer und Platzierungsregeln implementieren
- Baukosten für Straßen, Siedlungen und Städte festlegen
- Ressourcen beim Bauen prüfen und vom Spieler abziehen
- Straßenverbindung bei der Platzierung von Siedlungen prüfen
- Regeln für die Platzierung in der Anfangsphase ergänzen
- Platzierungs- und Upgrade-Methoden nach den neuen Regeln testen
- Aktiven Spieler und Zugwechsel über einen vollständigen Zugablauf testen
- Benutzeroberfläche für Board und Spielaktionen entwickeln
