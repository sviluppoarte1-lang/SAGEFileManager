# Build Linux

## Dipendenze di sistema

Per `flutter build linux` servono **CMake**, **Ninja**, e le librerie GTK (es. `libgtk-3-dev` su Debian/Ubuntu).

### Errore: `ninja '--version' failed ... No such file or directory`

Succede spesso con **Flutter installato via snap**: CMake prova un `ninja` sotto `/snap/flutter/...` che non esiste.

**Nel progetto:** `linux/CMakeLists.txt` forza l’uso di `ninja` trovato nel **PATH** (es. `/usr/bin/ninja`) prima di `project()`. Lo script [`build_deb.sh`](build_deb.sh) esporta anche `CMAKE_MAKE_PROGRAM` se `ninja` è installato.

**Sul sistema:** installare Ninja e il resto del toolchain, ad esempio:

`sudo apt install ninja-build cmake clang pkg-config libgtk-3-dev liblzma-dev`

Poi `flutter clean` e `flutter build linux` (o `./build_deb.sh`).

In alternativa usare un **Flutter SDK non-snap** (tarball ufficiale o `git clone`).

## Avviso `file_picker:linux` / default plugin

Con Flutter recenti serviva `file_picker` **≥ 8.1.x**. Il progetto usa `file_picker: ^10.3.0` in `pubspec.yaml`. Se l’avviso compare ancora, eseguire `flutter pub upgrade file_picker` e `flutter clean`.
