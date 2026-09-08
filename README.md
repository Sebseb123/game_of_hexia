# game_of_hexia

Im bin Folder ist eine Datei zum Testen des Boards. Kann man über die Konsole mit 
dart run bin/test_game.dart starten

Unter lib/src findet sich der Rest. Bisher nur am HexagonBoard gearbeitet
Struktur dachte ich mir:

lib/
└── src/
    ├── exceptions/
    │   ├── 
    │   └── 
    │
    ├── logic/
    │   ├── game_controller.dart
    │   └──  
    │
    ├── models/
    │   ├── hexagon_board.dart
    │   ├── 
    │
    └── views/
        ├── 


Der Konstruktor von HexagonBoard erzeugt ein Spielbrett mit 19 Felder.
Wäre besser das zu verallgemeiern um ein Brett beliebiger Größe zu erstellen.