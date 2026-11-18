import CoreText
import SwiftUI

// Vertex voor SwiftUI: lettertype, kaart, tegel, balk, segment, chip en knoppen, naar de Figma-bibliotheek.

extension Vertex {
	/// Registreert Plus Jakarta Sans (variabel lettertype uit de bundel). Eén keer bij het starten van de app.
	static func registreerLettertype() {
		guard let url = Bundle.main.url(forResource: "PlusJakartaSans", withExtension: "ttf") else { return }
		CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
	}
}

extension Font {
	/// Lettertype van een Vertex-tekststijl.
	static func vertex(_ s: Vertex.Stijl) -> Font {
		let weight: Font.Weight = s.gewicht >= 700 ? .bold : s.gewicht >= 600 ? .semibold : s.gewicht >= 500 ? .medium : .regular
		return .custom("Plus Jakarta Sans", size: s.grootte).weight(weight)
	}
}

extension View {
	/// Tekststijl met regelhoogte, zoals in Figma.
	func vertexTekst(_ s: Vertex.Stijl) -> some View {
		font(.vertex(s)).lineSpacing(max(0, s.regelhoogte - s.grootte * 1.26))
	}

	/// Pagina-achtergrond met de gloed bovenaan, zoals alle schermen in het ontwerp.
	func vertexPagina() -> some View {
		background(alignment: .top) {
			ZStack(alignment: .top) {
				Vertex.Kleur.achtergrondPagina
				LinearGradient(colors: [Vertex.Kleur.gloed, Vertex.Kleur.gloed.opacity(0)], startPoint: .top, endPoint: .bottom)
					.frame(height: 360)
			}
			.ignoresSafeArea()
		}
	}

	/// Kaart op een hoogteniveau (1 tot 4): vlak, rand en schaduw.
	func vertexKaart(_ niveau: Int = 1, radius: CGFloat = Vertex.Vorm.xl) -> some View {
		modifier(VertexKaart(niveau: niveau, radius: radius))
	}
}

private struct VertexKaart: ViewModifier {
	let niveau: Int
	let radius: CGFloat

	private var vlak: Color {
		switch niveau { case 2: Vertex.Kleur.hoogte2Vlak; case 3: Vertex.Kleur.hoogte3Vlak; case 4: Vertex.Kleur.hoogte4Vlak; default: Vertex.Kleur.hoogte1Vlak }
	}
	private var rand: Color {
		switch niveau { case 2: Vertex.Kleur.hoogte2Rand; case 3: Vertex.Kleur.hoogte3Rand; case 4: Vertex.Kleur.hoogte4Rand; default: Vertex.Kleur.hoogte1Rand }
	}

	func body(content: Content) -> some View {
		let vorm = RoundedRectangle(cornerRadius: radius, style: .continuous)
		content
			.background(vlak, in: vorm)
			.overlay(vorm.strokeBorder(rand, lineWidth: 1))
			.vertexSchaduw(niveau)
	}
}

extension View {
	/// Schaduw van een hoogteniveau. CSS-spreiding bestaat niet in SwiftUI; de straal is daarom wat kleiner gekozen.
	@ViewBuilder func vertexSchaduw(_ niveau: Int) -> some View {
		switch niveau {
		case 2: shadow(color: Vertex.Kleur.schaduw, radius: 6, y: 4)
		case 3: shadow(color: Vertex.Kleur.schaduw, radius: 10, y: 7)
		case 4: shadow(color: Vertex.Kleur.schaduw, radius: 8, y: 4).shadow(color: Vertex.Kleur.schaduw, radius: 18, y: 12)
		default: shadow(color: Vertex.Kleur.schaduw, radius: 6, y: 2)
		}
	}

	/// Schaduw van een knop of kaart met verloop.
	func vertexAccentSchaduw() -> some View {
		shadow(color: Color(UIColor(hex: "#6b54db")).opacity(0.32), radius: 8, y: 6)
	}
}

/// Kleur van een groep; de budgetten erin krijgen dezelfde tint.
enum VertexHue: String {
	case accent, lucht, koraal, mint, zon

	init(_ naam: String?) { self = VertexHue(rawValue: naam ?? "") ?? .accent }

	/// Zachte tint voor tegel en achtergrond.
	var zacht: Color {
		switch self {
		case .accent: Vertex.Kleur.accentZacht
		case .lucht: Vertex.Kleur.categorieLuchtZacht
		case .koraal: Vertex.Kleur.categorieKoraalZacht
		case .mint: Vertex.Kleur.categorieMintZacht
		case .zon: Vertex.Kleur.categorieZonZacht
		}
	}
	/// Icoon- en tekstkleur op de zachte tint.
	var tekst: Color {
		switch self {
		case .accent: Vertex.Kleur.accentStandaard
		case .lucht: Vertex.Kleur.categorieLuchtTekst
		case .koraal: Vertex.Kleur.categorieKoraalTekst
		case .mint: Vertex.Kleur.categorieMintTekst
		case .zon: Vertex.Kleur.categorieZonTekst
		}
	}
	/// Effen vlak voor de groep zelf.
	var effen: AnyShapeStyle {
		switch self {
		case .accent: AnyShapeStyle(Vertex.verloopAccent)
		case .lucht: AnyShapeStyle(Vertex.Kleur.categorieLucht)
		case .koraal: AnyShapeStyle(Vertex.Kleur.categorieKoraal)
		case .mint: AnyShapeStyle(Vertex.Kleur.categorieMint)
		case .zon: AnyShapeStyle(Vertex.Kleur.categorieZon)
		}
	}
	/// Icoonkleur op het effen vlak: de zachte tint (wit in licht, donker in donker blijft leesbaar).
	var opEffen: Color { self == .accent ? Vertex.Kleur.tekstOpAccent : zacht }
}

/// Icoon in een afgeronde tegel: getint (budget) of effen (groep).
struct VertexTegel: View {
	let image: Image?
	var hue: VertexHue = .accent
	var effen = false
	var maat: CGFloat = 44

	var body: some View {
		ZStack {
			if let image {
				image
					.renderingMode(.template)
					.resizable()
					.scaledToFit()
					.frame(width: maat * 0.55, height: maat * 0.55)
					.foregroundStyle(effen ? hue.opEffen : hue.tekst)
			}
		}
		.frame(width: maat, height: maat)
		.background(effen ? hue.effen : AnyShapeStyle(hue.zacht), in: RoundedRectangle(cornerRadius: maat * 0.36, style: .continuous))
	}
}

/// Voortgangsbalk: 8 hoog, accent op een zacht spoor; rood als het budget over is.
struct VertexBalk: View {
	let pct: Double
	var over = false

	var body: some View {
		GeometryReader { geo in
			ZStack(alignment: .leading) {
				Capsule().fill(Vertex.Kleur.accentZacht)
				Capsule()
					.fill(over ? Vertex.Kleur.statusNegatief : Vertex.Kleur.accentVlak)
					.frame(width: geo.size.width * min(1, max(0, pct / 100)))
			}
		}
		.frame(height: 8)
	}
}

/// Kop boven een kaart: "Budgetten".
struct VertexSectiekop: View {
	let titel: String
	var body: some View {
		Text(titel).vertexTekst(Vertex.Tekst.kop).foregroundStyle(Vertex.Kleur.tekstHoofd).frame(maxWidth: .infinity, alignment: .leading)
	}
}

/// Kaart met rijen en een lijn ertussen.
struct VertexRijen<Item: Identifiable, Rij: View>: View {
	let items: [Item]
	@ViewBuilder let rij: (Item) -> Rij

	var body: some View {
		VStack(spacing: 0) {
			ForEach(Array(items.enumerated()), id: \.element.id) { i, item in
				if i > 0 { Rectangle().fill(Vertex.Kleur.lijnStandaard).frame(height: 1) }
				rij(item)
			}
		}
		.vertexKaart()
	}
}

/// Ronde knop met een icoon (bijvoorbeeld +): hoogte 2, accentkleur.
struct VertexIcoonknop: View {
	let systeemIcoon: String
	let label: String
	var maat: CGFloat = 40
	let actie: () -> Void

	var body: some View {
		Button(action: actie) {
			Image(systemName: systeemIcoon)
				.font(.system(size: 16, weight: .semibold))
				.foregroundStyle(Vertex.Kleur.accentStandaard)
				.frame(width: maat, height: maat)
				.background(Vertex.Kleur.hoogte2Vlak, in: Circle())
				.overlay(Circle().strokeBorder(Vertex.Kleur.hoogte2Rand, lineWidth: 1))
				.vertexSchaduw(2)
		}
		.buttonStyle(.plain)
		.accessibilityLabel(label)
	}
}

/// Chip: kleine pil met tekst in een zachte tint.
struct VertexChip: View {
	enum Toon { case accent, positief, waarschuwing, neutraal, negatief }
	let tekst: String
	var toon: Toon = .accent

	private var kleuren: (Color, Color) {
		switch toon {
		case .accent: (Vertex.Kleur.accentZacht, Vertex.Kleur.accentStandaard)
		case .positief: (Vertex.Kleur.statusPositiefZacht, Vertex.Kleur.statusPositief)
		case .waarschuwing: (Vertex.Kleur.statusWaarschuwingZacht, Vertex.Kleur.statusWaarschuwing)
		case .negatief: (Vertex.Kleur.statusNegatiefZacht, Vertex.Kleur.statusNegatief)
		case .neutraal: (Vertex.Kleur.achtergrondVlak, Vertex.Kleur.tekstGedempt)
		}
	}

	var body: some View {
		Text(tekst)
			.vertexTekst(Vertex.Tekst.label)
			.foregroundStyle(kleuren.1)
			.padding(.horizontal, 12)
			.padding(.vertical, 5)
			.background(kleuren.0, in: Capsule())
	}
}

/// Segmentbalk: wit actief segment met accenttekst op een zacht spoor.
struct VertexSegmentbalk<Waarde: Hashable>: View {
	let opties: [(Waarde, String)]
	@Binding var waarde: Waarde

	var body: some View {
		HStack(spacing: 2) {
			ForEach(Array(opties.enumerated()), id: \.offset) { _, optie in
				let actief = optie.0 == waarde
				Button { withAnimation(.easeOut(duration: 0.15)) { waarde = optie.0 } } label: {
					Text(optie.1)
						.vertexTekst(Vertex.Tekst.bodyVet)
						.foregroundStyle(actief ? Vertex.Kleur.accentStandaard : Vertex.Kleur.tekstGedempt)
						.lineLimit(1)
						.minimumScaleFactor(0.8)
						.frame(maxWidth: .infinity, minHeight: 36)
						.background(actief ? Vertex.Kleur.hoogte2Vlak : .clear, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
						.shadow(color: actief ? Vertex.Kleur.schaduw : .clear, radius: 3, y: 1)
				}
				.buttonStyle(.plain)
			}
		}
		.padding(4)
		.background(Vertex.Kleur.achtergrondVlak.opacity(0.7), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
	}
}

/// Primaire knop: verloop met accentschaduw.
struct VertexPrimaireKnop: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.vertexTekst(Vertex.Tekst.subkop)
			.foregroundStyle(Vertex.Kleur.tekstOpAccent)
			.frame(maxWidth: .infinity, minHeight: 52)
			.background(Vertex.verloopAccent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
			.vertexAccentSchaduw()
			.opacity(configuration.isPressed ? 0.85 : 1)
	}
}
