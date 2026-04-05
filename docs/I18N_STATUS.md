# Stato internazionalizzazione (i18n)

## Implementato

- **Flutter gen-l10n** con file in `lib/l10n/` (`app_en.arb` template + `app_it`, `app_fr`, `app_de`, `app_es`).
- **`MaterialApp`** in `lib/main.dart` usa `locale`, `localizationsDelegates`, `supportedLocales`, `onGenerateTitle`.
- La preferenza **Lingua** in Impostazioni (`SharedPreferences` chiave `language`, valori `italiano` / `inglese` / `francese` / `tedesco` / `spagnolo`) è collegata a `Locale('it'|'en'|'fr'|'de'|'es')`.
- Al ritorno da **Preferenze** viene chiamato `onLocaleChanged` per ricaricare la lingua senza riavviare l’app.

## Stringhe localizzate (attuale)

- Menu principale e compatto, sottomenu ordinamento, barra di navigazione (tooltip), sezione **Generale** delle Preferenze (inclusi nomi lingue), tipi **Cartella/File** in vista dettagli/lista.

## Da estendere (opzionale)

- Resto delle Preferenze, dialoghi, snackbar sparsi, `Sidebar`, ricerca file, ecc. possono essere migrati aggiungendo chiavi negli ARB e sostituendo le stringhe hardcoded.
