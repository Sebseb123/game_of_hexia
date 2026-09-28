# game_of_hexia

Im bin Folder ist eine Datei zum Testen des Boards. Kann man über die Konsole mit
dart run bin/test_game.dart starten

Unter lib/src findet sich der Rest.
Habe am HexagonBoard weiter gearbeitet.
Jetzt kann man die Größe des Spielfelds frei wählen.
Größe wird beim Start des Konsolenprogramms abgefragt.
Die Verhältnisse der Ressourcen auf den Feldern bleibt ungefähr
so, wie es für 19 Felder implementiert war.
Alle 19 Felder kommt eine Wüste hinzu, das könnte man vll noch variieren.

Habe außerdem mit den Klassen Würfel, Spieler und
GameController begonnen.

Die größte neue Hauptfunktion ist das Würfeln und die Ressourcenverteilung
durch das Würfeln.

Die Enums building_type für Stadt/Siedlung und resource_type (vorher Hexagon_type)
habe ich als eigene Klassen geschrieben, damit versch. Klassen drauf zugreifen können.

Ein Node hat jetzt außerdem ggf. einen Besitzer (owner) und ein
Gebäude(buildingType), beide Attirbute können aber auch null sein.

Tests und Kommentare sind fast in Gänze von Opencode erstellt.

lib/
└── src/
    ├── exceptions/
    │   ├── 
    │   └── 
    │
    ├── logic/
    │   ├── game_controller.dart
    │   └── dice.dart
    │
    ├── models/
    │   ├── hexagon_board.dart
    │   ├── building_type.dart
    │   ├── player.dart
    │   ├── resource_type.dart

    │
    └── views/
        ├── 


Nächste Schritte könnten sein:

- die Klassen noch etwas strukturieren,
  (z.B. eig. Node Klasse, Hexagon Klasse usw.)
- Siedlungen über eine Spielaktion auf Nodes platzieren
- Aktiven Spieler und Zugwechsel in der Konsole testen
- Straßen und Kanten modellieren
- Kosten für Gebäude und Ressourcenverbrauch ergänzen
