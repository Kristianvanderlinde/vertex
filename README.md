# Ontwerpsysteem

Eén bron voor kleur, tekst, hoogte en vorm, en de componenten daarbovenop, voor Stax, Huis en wat er nog komt.

```
tokens/tokens.json      de bron: primitieven, semantische kleuren (licht/donker), hoogtes, schaduwen, verloop, tekst
scripts/maak-tokens.mjs maakt css/tokens.css (npm run tokens)
css/tokens.css          CSS-variabelen, klaar om te importeren
fonts/                  Plus Jakarta Sans (variabel)
web/                    Svelte 5-componenten (Knop, Icoonknop, Chip, Segmentbalk, Schakelaar, Zoekveld)
voorbeeld/              voorbeeldpagina (npm run voorbeeld → http://localhost:5191)
```

## Gebruik in een app

```json
"dependencies": { "ontwerpsysteem": "file:../ontwerpsysteem" }
```

```css
@import 'ontwerpsysteem/tokens.css';
```

```svelte
<script>
  import { Knop, Segmentbalk } from 'ontwerpsysteem/web';
</script>
```

Met Vite moet de map van het pakket bereikbaar zijn: `server: { fs: { allow: ['..'] } }`.

## Afspraken

- **Tokens zijn de waarheid voor waarden;** Figma laat het ontwerp zien. Kleur, tekst of schaduw aanpassen: eerst `tokens.json`, dan `npm run tokens`, dan in Figma bijwerken.
- **Twee lagen:** primitieven (`--paars-400`, geen betekenis) en semantische tokens (`--accent-standaard`, licht en donker). Componenten gebruiken alleen semantische tokens.
- **Hoogte:** vier niveaus met vlak, rand en schaduw (`--hoogte-1-vlak`, `--hoogte-1-rand`, `--schaduw-hoogte-1`). In donker bepaalt vooral de lichtheid de hoogte.
- **Donker:** volgt het systeem; `data-thema="licht"` of `"donker"` op een element forceert het.
- **Iconen:** geen icoonlettertype. Componenten krijgen een icoon als snippet, de app levert de SVG.
- **Namen** zijn gelijk aan Figma (Knop, Icoonknop, Chip, Segmentbalk, …) met dezelfde varianten.

## Nog te doen

SwiftUI-kant (kleuren, vormen en schaduwen als Swift uit `tokens.json`, componenten als views), meer componenten (Kaart, Banner, Rij, Tegel, Zijbalk, Tabbalk, Invoerveld), en publiceren zodat een Docker-build het pakket kan ophalen.
