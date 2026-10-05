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
- Startposition des Räubers auf einem Wüstenfeld
- Berechnung, Konsolenauswahl und validiertes Abwerfen von Ressourcen bei einer 7
- Vollständiger Räuberzug: Abwerfen, Zielfeld wählen, Räuber versetzen, Opfer
  wählen und eine zufällige Karte stehlen
- Blockierte Ressourcenproduktion auf dem Feld des Räubers
- Regel, dass der Räuber auf ein anderes Feld versetzt werden muss
- Entwicklungskartendeck mit Kaufmechanik
- Effekte für Ritter, Monopol, Straßenbau und Erfindung
- Verdeckte Siegpunkte und Vergabe der größten Rittermacht
- Ressourcenbank mit 19 Karten pro Rohstoff und kontrollierter Entnahme

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
- Berechnung und validiertes Abwerfen von Ressourcen bei einer 7
- Stehlen einer zufälligen Karte, auch bei leerer Hand des Opfers
- Blockierte Ressourcenproduktion auf dem Räuberfeld
- Grundregeln für die Platzierung von Siedlungen und Städten
- Zusammensetzung, Kauf und Effekte der Entwicklungskarten
- Ressourcenbank und begrenzte Kartenentnahme
- Vergabe und Wechsel der größten Rittermacht

## Nächste Schritte

- Kommentare und Dokumentation im Code vereinheitlichen
- Spielzustand aus dem `GameController` in einen eigenen `GameState` auslagern
- später BuildSuccess enum implementieren als Rückgabewert
  für die Baumethoden, für die GUI
- Straßenprüfung bei Siedlungsbau
- längste Straße
- wahrscheinlich sinnvoll, noch eine SpielerID einzuführen
- Straßenverbindung bei der Platzierung von Siedlungen prüfen
- Regeln für die Platzierung in der Anfangsphase ergänzen
- Platzierungs- und Upgrade-Methoden nach den neuen Regeln testen
- Aktiven Spieler und Zugwechsel über einen vollständigen Zugablauf testen
- Neu gekaufte Entwicklungskarten zu Beginn des nächsten eigenen Zugs
  spielbar machen
- Maximal eine Entwicklungskarte pro Zug erlauben
- Ressourcenbank in Produktion, Baukosten und Rückgaben einbinden
- Benutzeroberfläche für Board und Spielaktionen entwickeln

### Weitere Siedler-Mechaniken

- Seehäfen mit 3:1- und 2:1-Tausch
- Handel mit Bank und Mitspielern
- „Längste Handelsstraße“
- Siegpunktkarten beim Spielende aufdecken
- Siegpunkte für Siedlungen und Städte
- Gesamtsiegpunkte aus offenen und versteckten Siegpunkten berechnen
- Spielende bei 10 Siegpunkten
- Anfangsphase mit zwei kostenlosen Siedlungen und Straßen
- Zweite Anfangssiedlung verteilt Startressourcen
- Begrenzter Vorrat an Gebäuden und Straßen
