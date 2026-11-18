# Vertex

Eén bron voor kleur, tekst, hoogte en vorm, en de componenten daarbovenop, voor Stax, Huis en wat er nog komt.

```
tokens/tokens.json      de bron: primitieven, semantische kleuren (licht/donker), hoogtes, schaduwen, verloop, tekst
scripts/maak-tokens.mjs maakt css/tokens.css (npm run tokens)
css/tokens.css          CSS-variabelen, klaar om te importeren
fonts/                  Plus Jakarta Sans (variabel)
web/                    Svelte 5-componenten (Knop, Icoonknop, Terugknop, Chip, Segmentbalk, Schakelaar, Zoekveld)
voorbeeld/              voorbeeldpagina (npm run voorbeeld → http://localhost:5191)
```

## Gebruik in een app

```json
"dependencies": { "vertex": "file:../vertex" }
```

```css
@import 'vertex/tokens.css';
```

```svelte
<script>
  import { Knop, Segmentbalk } from 'vertex/web';
</script>
```

Met Vite moet de map van het pakket bereikbaar zijn: `server: { fs: { allow: ['..'] } }`.

## Afspraken

- **Figma is leidend.** Het ontwerp in Figma (Huis-bestand, pagina's `design system`, `stax web`, `stax ios`) bepaalt hoe iets eruitziet, ook ruimtes en maten. De code volgt: bij verschil wint Figma. Een waarde die verandert, verandert eerst in Figma; daarna worden `tokens/tokens.json` en `npm run tokens` bijgewerkt. Controleer een scherm in een app altijd tegen het bijbehorende Figma-scherm.
- **Twee lagen:** primitieven (`--paars-400`, geen betekenis) en semantische tokens (`--accent-standaard`, licht en donker). Componenten gebruiken alleen semantische tokens.
- **Hoogte:** vier niveaus met vlak, rand en schaduw (`--hoogte-1-vlak`, `--hoogte-1-rand`, `--schaduw-hoogte-1`). In donker bepaalt vooral de lichtheid de hoogte.
- **Donker:** volgt het systeem; `data-thema="licht"` of `"donker"` op een element forceert het.
- **Iconen:** geen icoonlettertype. Componenten krijgen een icoon als snippet, de app levert de SVG.
- **Namen** zijn gelijk aan Figma (Knop, Icoonknop, Chip, Segmentbalk, …) met dezelfde varianten.

## Nog te doen

SwiftUI-kant (kleuren, vormen en schaduwen als Swift uit `tokens.json`, componenten als views), meer componenten (Kaart, Banner, Rij, Tegel, Zijbalk, Tabbalk, Invoerveld), en publiceren zodat een Docker-build het pakket kan ophalen.

## SwiftUI
`npm run tokens` maakt ook `swift/VertexTokens.swift` (kleuren licht/donker, ruimte, vorm, tekststijlen). `swift/VertexComponents.swift` bevat lettertype-registratie, kaart, tegel, balk, chip, segmentbalk, icoonknop en primaire knop. Een app kopieert `swift/*.swift` en `fonts/PlusJakartaSans.ttf` naar zijn eigen doelmap (Stax: `ios/Stax/Vertex/`) en roept `Vertex.registreerLettertype()` aan bij het starten.
