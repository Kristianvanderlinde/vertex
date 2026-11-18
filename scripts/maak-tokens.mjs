// Maakt css/tokens.css uit tokens/tokens.json.
//   npm run tokens
// De semantische kleuren verwijzen naar primitieven; licht is de standaard, donker volgt het systeem
// (of data-thema="donker" op een element). Met data-thema="licht" forceer je licht.
import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const t = JSON.parse(readFileSync(join(root, 'tokens/tokens.json'), 'utf8'));

const naam = (s) => s.replace(/\//g, '-');
const semantisch = Object.entries(t.semantisch);
const kleurBlok = (modus) =>
	semantisch.map(([n, [l, d]]) => `\t--${naam(n)}: var(--${naam(modus === 0 ? l : d)});`).join('\n');
const prim = Object.entries(t.primitieven)
	.flatMap(([fam, schaal]) => Object.entries(schaal).map(([stap, hex]) => `\t--${fam}-${stap}: ${hex};`))
	.join('\n');
const ruimte = Object.entries(t.ruimte).map(([k, v]) => `\t--ruimte-${k}: ${v}px;`).join('\n');
const vorm = Object.entries(t.vorm).map(([k, v]) => `\t--vorm-${k}: ${v}px;`).join('\n');
const schaduw = Object.entries(t.schaduw).map(([k, v]) => `\t--schaduw-${k}: ${v};`).join('\n');
const verloop = Object.entries(t.verloop)
	.filter(([, v]) => typeof v === 'string')
	.map(([k, v]) => `\t--verloop-${k}: ${v};`)
	.join('\n');
const stijlen = Object.entries(t.tekst.stijlen)
	.map(
		([k, s]) =>
			`.tekst-${k} {\n\tfont: ${s.gewicht} ${s.grootte}px/${s.regelhoogte}px var(--tekst-familie);\n}`
	)
	.join('\n');

const css = `/* Gemaakt met scripts/maak-tokens.mjs uit tokens.json. Niet met de hand aanpassen. */

@font-face {
	font-family: 'Plus Jakarta Sans';
	src: url('../fonts/PlusJakartaSans.ttf') format('truetype');
	font-weight: 200 800;
	font-display: swap;
}

/* Primitieven: het ruwe palet, zonder betekenis. */
:root {
${prim}
}

/* Vaste waarden. */
:root {
${ruimte}
${vorm}
${schaduw}
${verloop}
\t--tekst-familie: ${t.tekst.familie};
\t--verloop-gloed: ${t.verloop.gloed[0]};
}

/* Semantisch: licht. */
:root,
[data-thema='licht'] {
${kleurBlok(0)}
\t--schaduw-kleur: ${t.schaduwKleur[0]};
\t--verloop-gloed: ${t.verloop.gloed[0]};
\tcolor-scheme: light;
}

/* Semantisch: donker, volgt het systeem tenzij licht geforceerd is. */
@media (prefers-color-scheme: dark) {
\t:root:not([data-thema='licht']) {
${kleurBlok(1).replace(/^/gm, '\t')}
\t\t--schaduw-kleur: ${t.schaduwKleur[1]};
\t\t--verloop-gloed: ${t.verloop.gloed[1]};
\t\tcolor-scheme: dark;
\t}
}

[data-thema='donker'] {
${kleurBlok(1)}
\t--schaduw-kleur: ${t.schaduwKleur[1]};
\t--verloop-gloed: ${t.verloop.gloed[1]};
\tcolor-scheme: dark;
}

/* Tekststijlen. */
${stijlen}
`;

writeFileSync(join(root, 'css/tokens.css'), css);
console.log(`tokens.css gemaakt: ${semantisch.length} semantische kleuren, ${Object.keys(t.primitieven).length} families.`);
