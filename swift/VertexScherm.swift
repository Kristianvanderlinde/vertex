import SwiftUI

// Vertex voor SwiftUI, deel 2: schermen, sectiekaarten, rijen en de tabbalk. Naar de Figma-bibliotheek;
// bewust niet de standaard iOS-lijsten, zodat elke kaart dezelfde rand, schaduw en rijhoogte heeft.

// MARK: - Scherm

private struct VertexAlsSheetKey: EnvironmentKey { static let defaultValue = false }
extension EnvironmentValues {
	/// Waar een scherm als sheet getoond wordt: de terugknop wordt dan "Sluit".
	var vertexAlsSheet: Bool {
		get { self[VertexAlsSheetKey.self] }
		set { self[VertexAlsSheetKey.self] = newValue }
	}
}

/// Eén scherm: pagina (met of zonder gloed), de kopregel en de inhoud.
/// - `titel`: grote titel (34, bold) in de inhoud. Bij scrollen verschijnt hij klein in een balk bovenaan.
/// - `terug`: tekst naast het pijltje op een scherm dat je opent; dat is de terugknop.
/// - `midden`: vaste kop met een kleine titel in het midden, voor sheets.
struct VertexScherm<Content: View>: View {
	var titel = ""
	var terug: String?
	var midden: String?
	var gloed = true
	var onderruimte: CGFloat = 120
	var leiding: AnyView?
	var acties: AnyView?
	@ViewBuilder let content: Content

	@Environment(\.dismiss) private var dismiss
	@Environment(\.vertexAlsSheet) private var alsSheet
	@State private var offset: CGFloat = 0

	init(
		titel: String = "", terug: String? = nil, midden: String? = nil, gloed: Bool = true, onderruimte: CGFloat = 120,
		leiding: AnyView? = nil, acties: AnyView? = nil, @ViewBuilder content: () -> Content
	) {
		self.titel = titel; self.terug = terug; self.midden = midden; self.gloed = gloed; self.onderruimte = onderruimte
		self.leiding = leiding; self.acties = acties; self.content = content()
	}

	private var kleinTitel: String { midden ?? titel }

	var body: some View {
		Group {
			if midden != nil {
				VStack(spacing: 0) {
					kopregel.padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 10)
					scroll
				}
			} else {
				scroll.overlay(alignment: .top) { balk }
			}
		}
		.font(.vBody)
		.foregroundStyle(Vertex.Kleur.tekstHoofd)
		.tint(Vertex.Kleur.accentStandaard)
		.vertexPagina(gloed: gloed)
		.toolbar(.hidden, for: .navigationBar)
	}

	private var scroll: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 16) {
				if midden == nil, terug != nil || (titel.isEmpty && acties != nil) {
					HStack { terugknop; Spacer(minLength: 8); acties }.frame(minHeight: 40)
				}
				if midden == nil, !titel.isEmpty {
					if terug == nil, let acties {
						HStack(alignment: .center) { grootTitel; Spacer(minLength: 8); acties }
					} else if terug != nil, let acties, false { acties } else { grootTitel }
				}
				content
			}
			.padding(.horizontal, 16)
			.padding(.top, midden == nil ? 12 : 4)
			.padding(.bottom, onderruimte)
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.scrollBounceBehavior(.basedOnSize)
		.scrollDismissesKeyboard(.interactively)
		.onScrollGeometryChange(for: CGFloat.self) { $0.contentOffset.y + $0.contentInsets.top } action: { _, nieuw in offset = nieuw }
	}

	private var grootTitel: some View {
		Text(titel).vertexTekst(Vertex.Tekst.titelL).foregroundStyle(Vertex.Kleur.tekstHoofd).lineLimit(2).minimumScaleFactor(0.7)
	}

	@ViewBuilder private var terugknop: some View {
		if alsSheet, terug != nil {
			Button { dismiss() } label: { Text("Sluit").vertexTekst(Vertex.Tekst.bodyVet).foregroundStyle(Vertex.Kleur.accentStandaard) }.buttonStyle(.plain)
		} else if let terug {
			Button { dismiss() } label: {
				HStack(spacing: 2) {
					Image(systemName: "chevron.left").font(.system(size: 15, weight: .semibold))
					Text(terug).vertexTekst(Vertex.Tekst.bodyVet)
				}
				.foregroundStyle(Vertex.Kleur.accentStandaard)
				.contentShape(Rectangle())
			}
			.buttonStyle(.plain)
			.accessibilityLabel("Terug naar \(terug)")
		}
	}

	/// Kop van een sheet: knop links, titel in het midden, knop rechts.
	private var kopregel: some View {
		ZStack {
			Text(kleinTitel).vertexTekst(Vertex.Tekst.bodyVet).foregroundStyle(Vertex.Kleur.tekstHoofd).lineLimit(1).padding(.horizontal, 90)
			HStack {
				if let leiding { leiding } else { terugknop }
				Spacer(minLength: 0)
				acties
			}
		}
		.frame(minHeight: 40)
	}

	/// Balk die bovenaan verschijnt als de grote titel uit beeld is.
	private var balk: some View {
		let zichtbaar = min(1, max(0, (offset - 36) / 24))
		return ZStack {
			Text(kleinTitel).vertexTekst(Vertex.Tekst.bodyVet).foregroundStyle(Vertex.Kleur.tekstHoofd).lineLimit(1).padding(.horizontal, 90)
			HStack { terugknop; Spacer(minLength: 0) }.padding(.horizontal, 16)
		}
		.frame(height: 44)
		.frame(maxWidth: .infinity)
		.background(.ultraThinMaterial.opacity(zichtbaar), ignoresSafeAreaEdges: .top)
		.overlay(alignment: .bottom) { Rectangle().fill(Vertex.Kleur.lijnStandaard).frame(height: 1).opacity(zichtbaar) }
		.opacity(zichtbaar > 0 ? 1 : 0)
		.allowsHitTesting(zichtbaar > 0.5)
	}
}

// MARK: - Sectie, rijen

private struct VZonderPaddingKey: ContainerValueKey {
	static let defaultValue = false
}
extension ContainerValues {
	var vzonderPadding: Bool {
		get { self[VZonderPaddingKey.self] }
		set { self[VZonderPaddingKey.self] = newValue }
	}
}
extension View {
	/// Een rij die zijn eigen opvulling meeneemt (bijvoorbeeld een link die over de hele rij te tikken is).
	func vzonderPadding() -> some View { containerValue(\.vzonderPadding, true) }
}

/// Kaart met rijen en een lijn ertussen, met een kleine kop erboven en een voetnoot eronder.
struct VSection<Content: View, Header: View, Footer: View>: View {
	let content: Content
	let header: Header
	let footer: Footer

	init(@ViewBuilder content: () -> Content, @ViewBuilder header: () -> Header, @ViewBuilder footer: () -> Footer) {
		self.content = content(); self.header = header(); self.footer = footer()
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			if Header.self != EmptyView.self {
				header.vertexTekst(Vertex.Tekst.label).foregroundStyle(Vertex.Kleur.tekstGedempt).padding(.horizontal, 4)
			}
			Group(subviews: content) { subs in
				if !subs.isEmpty {
					VStack(spacing: 0) {
						ForEach(Array(subs.enumerated()), id: \.element.id) { i, sub in
							if i > 0 { Rectangle().fill(Vertex.Kleur.lijnStandaard).frame(height: 1) }
							if sub.containerValues.vzonderPadding {
								sub.frame(maxWidth: .infinity, alignment: .leading)
							} else {
								sub.padding(.horizontal, 16).padding(.vertical, 12).frame(maxWidth: .infinity, minHeight: 46, alignment: .leading)
							}
						}
					}
					.vertexKaart()
				}
			}
			if Footer.self != EmptyView.self {
				footer.vertexTekst(Vertex.Tekst.klein).foregroundStyle(Vertex.Kleur.tekstGedempt).padding(.horizontal, 4)
			}
		}
	}
}

extension VSection where Header == EmptyView, Footer == EmptyView {
	init(@ViewBuilder content: () -> Content) { self.init(content: content, header: { EmptyView() }, footer: { EmptyView() }) }
}
extension VSection where Header == Text, Footer == EmptyView {
	init(_ titel: String, @ViewBuilder content: () -> Content) { self.init(content: content, header: { Text(titel.uppercased()) }, footer: { EmptyView() }) }
}
extension VSection where Footer == EmptyView {
	init(@ViewBuilder content: () -> Content, @ViewBuilder header: () -> Header) { self.init(content: content, header: header, footer: { EmptyView() }) }
}
extension VSection where Header == EmptyView {
	init(@ViewBuilder content: () -> Content, @ViewBuilder footer: () -> Footer) { self.init(content: content, header: { EmptyView() }, footer: footer) }
}

/// Rij met een grijs label links en de waarde rechts in semibold.
struct VWaarde<Waarde: View>: View {
	let label: String
	let waarde: Waarde

	init(_ label: String, @ViewBuilder content: () -> Waarde) { self.label = label; self.waarde = content() }

	var body: some View {
		HStack(spacing: 12) {
			Text(label).foregroundStyle(Vertex.Kleur.tekstGedempt)
			Spacer(minLength: 8)
			waarde.vertexTekst(Vertex.Tekst.bodyVet).foregroundStyle(Vertex.Kleur.tekstHoofd).multilineTextAlignment(.trailing)
		}
	}
}
extension VWaarde where Waarde == Text {
	init(_ label: String, value: String) { self.init(label) { Text(value) } }
}

/// Link naar een ander scherm: rij met chevron, over de hele rij te tikken.
struct VNavigationLink<Label: View>: View {
	let link: AnyView

	init(@ViewBuilder destination: () -> some View, @ViewBuilder label: () -> Label) {
		let l = label()
		link = AnyView(NavigationLink(destination: destination) { VNavRij(label: l) }.buttonStyle(.plain))
	}
	init<V: Hashable>(value: V, @ViewBuilder label: () -> Label) {
		let l = label()
		link = AnyView(NavigationLink(value: value) { VNavRij(label: l) }.buttonStyle(.plain))
	}

	var body: some View { link.vzonderPadding() }
}

private struct VNavRij<Label: View>: View {
	let label: Label
	var body: some View {
		HStack(spacing: 12) {
			label.frame(maxWidth: .infinity, alignment: .leading)
			Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(Vertex.Kleur.tekstVaag)
		}
		.padding(.horizontal, 16).padding(.vertical, 12)
		.frame(minHeight: 46)
		.contentShape(Rectangle())
	}
}

/// Rij die een knop is: over de hele rij te tikken.
struct VKnopRij<Label: View>: View {
	let actie: () -> Void
	let label: Label
	init(actie: @escaping () -> Void, @ViewBuilder label: () -> Label) { self.actie = actie; self.label = label() }

	var body: some View {
		Button(action: actie) {
			label.frame(maxWidth: .infinity, alignment: .leading)
				.padding(.horizontal, 16).padding(.vertical, 12).frame(minHeight: 46).contentShape(Rectangle())
		}
		.buttonStyle(.plain)
		.vzonderPadding()
	}
}

// MARK: - Meldingen en knoppen

/// Melding in een zachte statuskleur, bijvoorbeeld "Back-up gemaakt".
struct VertexMelding: View {
	enum Toon { case positief, waarschuwing, negatief }
	let tekst: String
	var toon: Toon = .positief
	var icoon: String?

	private var kleur: (Color, Color, String) {
		switch toon {
		case .positief: (Vertex.Kleur.statusPositiefZacht, Vertex.Kleur.statusPositief, "checkmark.circle")
		case .waarschuwing: (Vertex.Kleur.statusWaarschuwingZacht, Vertex.Kleur.statusWaarschuwing, "exclamationmark.triangle")
		case .negatief: (Vertex.Kleur.statusNegatiefZacht, Vertex.Kleur.statusNegatief, "exclamationmark.circle")
		}
	}

	var body: some View {
		HStack(alignment: .top, spacing: 10) {
			Image(systemName: icoon ?? kleur.2).font(.system(size: 18, weight: .medium))
			Text(tekst).vertexTekst(toon == .positief ? Vertex.Tekst.bodyVet : Vertex.Tekst.body).multilineTextAlignment(.leading)
			Spacer(minLength: 0)
		}
		.foregroundStyle(kleur.1)
		.padding(14)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(kleur.0, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
	}
}

/// Zachte knop met een rode tekst, voor verwijderen en terugzetten.
struct VertexDestructieveKnop: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.vertexTekst(Vertex.Tekst.subkop)
			.foregroundStyle(Vertex.Kleur.statusNegatief)
			.frame(maxWidth: .infinity, minHeight: 52)
			.background(Vertex.Kleur.statusNegatiefZacht, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
			.opacity(configuration.isPressed ? 0.8 : 1)
	}
}

/// Tekstknop in de kop van een sheet ("Annuleer", "Bewaar").
struct VertexKopKnop: View {
	let titel: String
	var vet = false
	var uit = false
	let actie: () -> Void

	var body: some View {
		Button(action: actie) {
			Text(titel).vertexTekst(vet ? Vertex.Tekst.bodyVet : Vertex.Tekst.body)
				.foregroundStyle(uit ? Vertex.Kleur.tekstVaag : Vertex.Kleur.accentStandaard)
		}
		.buttonStyle(.plain)
		.disabled(uit)
	}
}

/// Zoekveld in de inhoud, zoals in het ontwerp: wit vlak met een vergrootglas.
struct VertexZoekveld: View {
	let prompt: String
	@Binding var tekst: String
	var onSubmit: () -> Void = {}

	var body: some View {
		HStack(spacing: 10) {
			Image(systemName: "magnifyingglass").font(.system(size: 15, weight: .medium)).foregroundStyle(Vertex.Kleur.tekstGedempt)
			TextField("", text: $tekst, prompt: Text(prompt).foregroundStyle(Vertex.Kleur.tekstVaag))
				.vertexTekst(Vertex.Tekst.body)
				.submitLabel(.search)
				.onSubmit(onSubmit)
			if !tekst.isEmpty {
				Button { tekst = ""; onSubmit() } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(Vertex.Kleur.tekstVaag) }.buttonStyle(.plain)
			}
		}
		.padding(.horizontal, 14)
		.frame(height: 46)
		.vertexKaart(1, radius: 16)
	}
}

// MARK: - Tabbalk

/// Zwevende tabbalk: capsule op hoogte 3, actief item als zachte accentpil.
struct VertexTabbalk<Tab: Hashable>: View {
	struct Item: Identifiable {
		let tab: Tab
		let titel: String
		let icoon: String
		var teller = 0
		var id: String { titel }
	}
	let items: [Item]
	@Binding var gekozen: Tab

	var body: some View {
		HStack(spacing: 2) {
			ForEach(items) { item in
				let actief = item.tab == gekozen
				Button { gekozen = item.tab } label: {
					VStack(spacing: 3) {
						Image(item.icoon).renderingMode(.template).resizable().scaledToFit().frame(width: 24, height: 24)
						Text(item.titel).vertexTekst(Vertex.Stijl(grootte: 10, regelhoogte: 14, gewicht: 600)).lineLimit(1)
					}
					.foregroundStyle(actief ? Vertex.Kleur.accentStandaard : Vertex.Kleur.tekstGedempt)
					.frame(maxWidth: .infinity, minHeight: 59)
					.background(actief ? Vertex.Kleur.accentZacht : .clear, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
					.overlay(alignment: .topTrailing) {
						if item.teller > 0 {
							Text(item.teller > 99 ? "99+" : "\(item.teller)")
								.vertexTekst(Vertex.Stijl(grootte: 11, regelhoogte: 14, gewicht: 600))
								.foregroundStyle(Vertex.Kleur.tekstOpAccent)
								.padding(.horizontal, 5).frame(minWidth: 18, minHeight: 18)
								.background(Vertex.Kleur.accentVlak, in: Capsule())
								.padding(.top, 4).padding(.trailing, 20)
						}
					}
					.contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
				}
				.buttonStyle(.plain)
				.accessibilityLabel(item.titel)
				.accessibilityAddTraits(actief ? .isSelected : [])
			}
		}
		.padding(.horizontal, 4).padding(.vertical, 6)
		.vertexKaart(3, radius: 34)
		.padding(.horizontal, 16)
		.padding(.bottom, 6)
	}
}

// MARK: - Velden in rijen

/// Rij met een keuzemenu: grijs label links, de gekozen waarde rechts.
struct VKeuze<Waarde: Hashable, Opties: View>: View {
	let label: String
	@Binding var selection: Waarde
	@ViewBuilder let opties: Opties

	init(_ label: String, selection: Binding<Waarde>, @ViewBuilder opties: () -> Opties) {
		self.label = label; _selection = selection; self.opties = opties()
	}

	var body: some View {
		HStack(spacing: 12) {
			Text(label).foregroundStyle(Vertex.Kleur.tekstGedempt)
			Spacer(minLength: 8)
			Picker(label, selection: $selection) { opties }
				.labelsHidden()
				.pickerStyle(.menu)
				.tint(Vertex.Kleur.tekstGedempt)
		}
	}
}

/// Rij met een invoerveld: grijs label links, de waarde rechts in semibold.
struct VVeld: View {
	let label: String
	@Binding var tekst: String
	var prompt = ""
	var geheim = false

	init(_ label: String, tekst: Binding<String>, prompt: String = "", geheim: Bool = false) {
		self.label = label; _tekst = tekst; self.prompt = prompt; self.geheim = geheim
	}

	var body: some View {
		HStack(spacing: 12) {
			Text(label).foregroundStyle(Vertex.Kleur.tekstGedempt)
			Spacer(minLength: 8)
			Group {
				if geheim { SecureField("", text: $tekst, prompt: Text(prompt)) } else { TextField("", text: $tekst, prompt: Text(prompt)) }
			}
			.vertexTekst(Vertex.Tekst.bodyVet)
			.foregroundStyle(Vertex.Kleur.tekstHoofd)
			.multilineTextAlignment(.trailing)
		}
	}
}
