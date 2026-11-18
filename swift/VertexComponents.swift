import CoreText
import SwiftUI

// Vertex voor SwiftUI: lettertype, kaart, tegel, balk, segment, chip en knoppen, naar de Figma-bibliotheek.

extension Vertex {
	/// Registreert Plus Jakarta Sans (variabel lettertype uit de bundel). Eén keer bij het starten van de app.
	static func registreerLettertype() {
		if let url = Bundle.main.url(forResource: "PlusJakartaSans", withExtension: "ttf") {
			CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
		}
		stelNavigatiebalkIn()
	}

	/// Navigatiebalk in Vertex-stijl: grote titel in Plus Jakarta Sans, doorzichtig tot er gescrold wordt, accentkleur voor knoppen.
	static func stelNavigatiebalkIn() {
		// Variabel lettertype: het gewicht staat op de as 'wght' (0x77676874).
		func font(_ size: CGFloat, _ gewicht: CGFloat) -> UIFont {
			let basis = UIFont(name: "Plus Jakarta Sans", size: size) ?? .systemFont(ofSize: size, weight: .bold)
			let variatie = UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String)
			return UIFont(descriptor: basis.fontDescriptor.addingAttributes([variatie: [2003265652: gewicht]]), size: size)
		}
		let tekst = UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: "#f4f0ef") : UIColor(hex: "#231f2b") }
		let scroll = UINavigationBarAppearance()
		scroll.configureWithDefaultBackground()
		scroll.titleTextAttributes = [.font: font(17, 600), .foregroundColor: tekst]
		scroll.largeTitleTextAttributes = [.font: font(34, 700), .foregroundColor: tekst]
		let rand = UINavigationBarAppearance()
		rand.configureWithTransparentBackground()
		rand.titleTextAttributes = scroll.titleTextAttributes
		rand.largeTitleTextAttributes = scroll.largeTitleTextAttributes
		UINavigationBar.appearance().standardAppearance = scroll
		UINavigationBar.appearance().compactAppearance = scroll
		UINavigationBar.appearance().scrollEdgeAppearance = rand
	}
}

extension Font {
	/// Lettertype van een Vertex-tekststijl.
	static func vertex(_ s: Vertex.Stijl) -> Font {
		let weight: Font.Weight = s.gewicht >= 700 ? .bold : s.gewicht >= 600 ? .semibold : s.gewicht >= 500 ? .medium : .regular
		return .custom("Plus Jakarta Sans", size: s.grootte).weight(weight)
	}
}

extension Font {
	/// Systeemstijlen vervangen door Vertex-tekst, zodat bestaande schermen meteen Plus Jakarta Sans krijgen.
	static let vBody = Font.vertex(Vertex.Tekst.body)
	static let vSub = Font.vertex(Vertex.Tekst.body)
	static let vKlein = Font.vertex(Vertex.Tekst.klein)
	static let vCaption = Font.vertex(Vertex.Stijl(grootte: 12, regelhoogte: 16, gewicht: 400))
	static let vCaption2 = Font.vertex(Vertex.Stijl(grootte: 11, regelhoogte: 14, gewicht: 400))
	static let vTitle3 = Font.vertex(Vertex.Tekst.kop)
	static let vHeadline = Font.vertex(Vertex.Tekst.subkop)
}

/// Sectie in een lijst of formulier met een Vertex-kaartvlak als rijachtergrond.
struct VSection<Content: View, Header: View, Footer: View>: View {
	let content: Content
	let header: Header
	let footer: Footer

	init(@ViewBuilder content: () -> Content, @ViewBuilder header: () -> Header, @ViewBuilder footer: () -> Footer) {
		self.content = content(); self.header = header(); self.footer = footer()
	}

	var body: some View {
		Section { content } header: {
			header.vertexTekst(Vertex.Tekst.label).foregroundStyle(Vertex.Kleur.tekstGedempt)
		} footer: {
			footer.vertexTekst(Vertex.Tekst.klein).foregroundStyle(Vertex.Kleur.tekstGedempt)
		}
			.listRowBackground(Vertex.Kleur.hoogte1Vlak)
			.listRowSeparatorTint(Vertex.Kleur.lijnStandaard)
	}
}

extension VSection where Header == EmptyView, Footer == EmptyView {
	init(@ViewBuilder content: () -> Content) { self.init(content: content, header: { EmptyView() }, footer: { EmptyView() }) }
}
extension VSection where Footer == EmptyView {
	init(@ViewBuilder content: () -> Content, @ViewBuilder header: () -> Header) { self.init(content: content, header: header, footer: { EmptyView() }) }
}
extension VSection where Header == Text, Footer == EmptyView {
	init(_ titel: String, @ViewBuilder content: () -> Content) { self.init(content: content, header: { Text(titel.uppercased()) }, footer: { EmptyView() }) }
}
extension VSection where Header == EmptyView {
	init(@ViewBuilder content: () -> Content, @ViewBuilder footer: () -> Footer) { self.init(content: content, header: { EmptyView() }, footer: footer) }
}

extension View {
	/// Lijst of formulier op de Vertex-pagina: eigen achtergrond met gloed, kleur en lettertype.
	func vertexLijst(gloed: Bool = true) -> some View {
		scrollContentBackground(.hidden)
			.font(.vBody)
			.foregroundStyle(Vertex.Kleur.tekstHoofd)
			.tint(Vertex.Kleur.accentStandaard)
			.vertexPagina(gloed: gloed)
	}

	/// Tekststijl met regelhoogte, zoals in Figma.
	func vertexTekst(_ s: Vertex.Stijl) -> some View {
		font(.vertex(s)).lineSpacing(max(0, s.regelhoogte - s.grootte * 1.26))
	}

	/// Pagina-achtergrond met de gloed bovenaan, zoals alle schermen in het ontwerp.
	func vertexPagina(gloed: Bool = true) -> some View {
		background(alignment: .top) {
			ZStack(alignment: .top) {
				Vertex.Kleur.achtergrondPagina
				if gloed {
					LinearGradient(colors: [Vertex.Kleur.gloed, Vertex.Kleur.gloed.opacity(0)], startPoint: .top, endPoint: .bottom)
						.frame(height: 360)
				}
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
						.background(actief ? Vertex.Kleur.hoogte2Vlak : .clear, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
						.shadow(color: actief ? Vertex.Kleur.schaduw : .clear, radius: 3, y: 1)
				}
				.buttonStyle(.plain)
			}
		}
		.padding(4)
		.background(Vertex.Kleur.achtergrondVlak, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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

/// Secundaire knop: zachte accentkleur zonder schaduw.
struct VertexSecundaireKnop: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.vertexTekst(Vertex.Tekst.subkop)
			.foregroundStyle(Vertex.Kleur.accentStandaard)
			.frame(maxWidth: .infinity, minHeight: 52)
			.background(Vertex.Kleur.accentZacht, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
			.opacity(configuration.isPressed ? 0.8 : 1)
	}
}

/// Invoerveld met label erboven en een gevuld vlak.
struct VertexVeld<Inhoud: View>: View {
	let label: String
	@ViewBuilder let inhoud: Inhoud

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(label).vertexTekst(Vertex.Tekst.klein).foregroundStyle(Vertex.Kleur.tekstGedempt)
			inhoud
				.vertexTekst(Vertex.Tekst.body)
				.foregroundStyle(Vertex.Kleur.tekstHoofd)
				.padding(.horizontal, 14)
				.frame(minHeight: 46)
				.background(Vertex.Kleur.achtergrondKaart2, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
		}
	}
}

/// Het app-icoon als logo: afgerond vlak met verloop en de dollar.
struct VertexLogo: View {
	var maat: CGFloat = 72

	var body: some View {
		Image("Logo")
			.resizable()
			.frame(width: maat, height: maat)
			.clipShape(RoundedRectangle(cornerRadius: maat * 0.26, style: .continuous))
			.vertexAccentSchaduw()
	}
}
