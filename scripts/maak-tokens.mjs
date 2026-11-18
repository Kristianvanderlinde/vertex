// Maakt css/tokens.css uit tokens/tokens.json.
//   npm run tokens
// De semantische kleuren verwijzen naar primitieven; licht is de standaard, donker volgt het systeem
// (of data-thema="donker" op een element). Met data-thema="licht" forceer je licht.
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
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

// ---- Swift (SwiftUI): dezelfde tokens voor de iOS-apps. ----
const hex = (ref) => {
	const [fam, stap] = ref.split('/');
	return t.primitieven[fam][stap];
};
const camel = (n) =>
	n
		.split(/[\/-]/)
		.map((d, i) => (i === 0 ? d : d[0].toUpperCase() + d.slice(1)))
		.join('');
const kleurRegels = semantisch.map(([n, [l, d]]) => `\t\tstatic let ${camel(n)} = dynamisch("${hex(l)}", "${hex(d)}")`).join('\n');
const ruimteSwift = Object.entries(t.ruimte).map(([k, v]) => `\t\tstatic let r${k}: CGFloat = ${v}`).join('\n');
const vormSwift = Object.entries(t.vorm).map(([k, v]) => `\t\tstatic let ${k}: CGFloat = ${v}`).join('\n');
const stijlSwift = Object.entries(t.tekst.stijlen)
	.map(([k, st]) => `\t\tstatic let ${camel(k)} = Stijl(grootte: ${st.grootte}, regelhoogte: ${st.regelhoogte}, gewicht: ${st.gewicht})`)
	.join('\n');
const rgbaGloed = (g) => g.match(/#([0-9a-f]{6})|rgb\((\d+) (\d+) (\d+) \/ ([\d.]+)\)/i);
const gloedKleur = (g) => {
	const m = rgbaGloed(g);
	if (m[1]) return { hex: '#' + m[1], alpha: 1 };
	const h = [m[2], m[3], m[4]].map((x) => (+x).toString(16).padStart(2, '0')).join('');
	return { hex: '#' + h, alpha: +m[5] };
};
const gl = t.verloop.gloed.map(gloedKleur);
const accentVerloop = t.verloop.accent.match(/#[0-9a-f]{6}/gi);

const swift = `// Gemaakt met scripts/maak-tokens.mjs uit tokens.json. Niet met de hand aanpassen.
import SwiftUI
import UIKit

/// Vertex: tokens voor kleur (licht en donker), ruimte, vorm en tekst.
enum Vertex {
\tstatic func dynamisch(_ licht: String, _ donker: String) -> Color {
\t\tColor(UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: donker) : UIColor(hex: licht) })
\t}

\tenum Kleur {
${kleurRegels}
\t\tstatic let schaduw = Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.black.withAlphaComponent(0.4) : UIColor(hex: "#241a33").withAlphaComponent(0.10) })
\t\tstatic let gloed = Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: "${gl[1].hex}").withAlphaComponent(${gl[1].alpha}) : UIColor(hex: "${gl[0].hex}").withAlphaComponent(${gl[0].alpha}) })
\t}

\t/// Het verloop van accentkleuren (diagonaal), voor knoppen en gekleurde kaarten.
\tstatic let verloopAccent = LinearGradient(colors: [Color(UIColor(hex: "${accentVerloop[0]}")), Color(UIColor(hex: "${accentVerloop[1]}"))], startPoint: .topLeading, endPoint: .bottomTrailing)

\tenum Ruimte {
${ruimteSwift}
\t}

\tenum Vorm {
${vormSwift}
\t}

\tstruct Stijl {
\t\tlet grootte: CGFloat
\t\tlet regelhoogte: CGFloat
\t\tlet gewicht: Int
\t}

\tenum Tekst {
${stijlSwift}
\t}
}

extension UIColor {
\tconvenience init(hex: String) {
\t\tlet s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
\t\tvar v: UInt64 = 0
\t\tScanner(string: s).scanHexInt64(&v)
\t\tself.init(red: CGFloat((v >> 16) & 0xff) / 255, green: CGFloat((v >> 8) & 0xff) / 255, blue: CGFloat(v & 0xff) / 255, alpha: 1)
\t}
}
`;
mkdirSync(join(root, 'swift'), { recursive: true });
writeFileSync(join(root, 'swift/VertexTokens.swift'), swift);
console.log('VertexTokens.swift gemaakt.');
