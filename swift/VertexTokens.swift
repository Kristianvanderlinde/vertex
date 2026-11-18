// Gemaakt met scripts/maak-tokens.mjs uit tokens.json. Niet met de hand aanpassen.
import SwiftUI
import UIKit

/// Vertex: tokens voor kleur (licht en donker), ruimte, vorm en tekst.
enum Vertex {
	static func dynamisch(_ licht: String, _ donker: String) -> Color {
		Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: donker) : UIColor(hex: licht) })
	}

	enum Kleur {
		static let achtergrondPagina = dynamisch("#f5f1ec", "#1e1c1d")
		static let hoogte1Vlak = dynamisch("#ffffff", "#2c292b")
		static let hoogte2Vlak = dynamisch("#ffffff", "#373334")
		static let hoogte3Vlak = dynamisch("#ffffff", "#373334")
		static let hoogte4Vlak = dynamisch("#ffffff", "#3f3b3c")
		static let hoogte1Rand = dynamisch("#e7e0d8", "#3f3b3c")
		static let hoogte2Rand = dynamisch("#e7e0d8", "#413c3e")
		static let hoogte3Rand = dynamisch("#e7e0d8", "#413c3e")
		static let hoogte4Rand = dynamisch("#e7e0d8", "#575254")
		static let achtergrondKaart2 = dynamisch("#f5f1ec", "#373334")
		static let achtergrondVlak = dynamisch("#ece5dd", "#413c3e")
		static let achtergrondSpoor = dynamisch("#ece5dd", "#1e1c1d")
		static let tekstHoofd = dynamisch("#231f2b", "#f4f0ef")
		static let tekstGedempt = dynamisch("#6f6878", "#ada6a8")
		static let tekstVaag = dynamisch("#ada7b4", "#787174")
		static let tekstOpAccent = dynamisch("#ffffff", "#ffffff")
		static let lijnStandaard = dynamisch("#e7e0d8", "#3f3b3c")
		static let accentStandaard = dynamisch("#6a55dc", "#b9a9ff")
		static let accentVlak = dynamisch("#6a55dc", "#6a55dc")
		static let accentZacht = dynamisch("#eee9fc", "#373058")
		static let statusPositief = dynamisch("#248a3d", "#52d07f")
		static let statusPositiefZacht = dynamisch("#e4f3e8", "#243329")
		static let statusWaarschuwing = dynamisch("#b25000", "#ffb45e")
		static let statusWaarschuwingZacht = dynamisch("#fff1de", "#3c2e1b")
		static let statusNegatief = dynamisch("#d70015", "#ff8076")
		static let statusNegatiefZacht = dynamisch("#ffe6e8", "#3d2324")
		static let categorieZon = dynamisch("#f2b33d", "#ffc85c")
		static let categorieZonZacht = dynamisch("#fff3d6", "#3f321a")
		static let categorieZonTekst = dynamisch("#8a5a00", "#ffc85c")
		static let categorieKoraal = dynamisch("#e8604c", "#ff8a78")
		static let categorieKoraalZacht = dynamisch("#ffe9e4", "#3f2623")
		static let categorieKoraalTekst = dynamisch("#c4432f", "#ff8a78")
		static let categorieMint = dynamisch("#1f9d78", "#4fd1a5")
		static let categorieMintZacht = dynamisch("#ddf4ec", "#1f3a31")
		static let categorieMintTekst = dynamisch("#167a5c", "#4fd1a5")
		static let categorieLucht = dynamisch("#2f7fd8", "#6db3ff")
		static let categorieLuchtZacht = dynamisch("#e1eefc", "#1f3047")
		static let categorieLuchtTekst = dynamisch("#1f62b5", "#6db3ff")
		static let schaduw = Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.black.withAlphaComponent(0.4) : UIColor(hex: "#241a33").withAlphaComponent(0.10) })
		static let gloed = Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: "#5e49d0").withAlphaComponent(0.42) : UIColor(hex: "#e0d6ff").withAlphaComponent(1) })
	}

	/// Het verloop van accentkleuren (diagonaal), voor knoppen en gekleurde kaarten.
	static let verloopAccent = LinearGradient(colors: [Color(UIColor(hex: "#6a55dc")), Color(UIColor(hex: "#5a48c8"))], startPoint: .topLeading, endPoint: .bottomTrailing)

	enum Ruimte {
		static let r1: CGFloat = 4
		static let r2: CGFloat = 8
		static let r3: CGFloat = 12
		static let r4: CGFloat = 16
		static let r5: CGFloat = 20
		static let r6: CGFloat = 24
		static let r8: CGFloat = 32
		static let r10: CGFloat = 40
		static let r12: CGFloat = 48
	}

	enum Vorm {
		static let sm: CGFloat = 8
		static let md: CGFloat = 12
		static let lg: CGFloat = 16
		static let xl: CGFloat = 24
		static let xxl: CGFloat = 28
		static let pill: CGFloat = 999
	}

	struct Stijl {
		let grootte: CGFloat
		let regelhoogte: CGFloat
		let gewicht: Int
	}

	enum Tekst {
		static let titelL = Stijl(grootte: 34, regelhoogte: 40, gewicht: 700)
		static let titelM = Stijl(grootte: 28, regelhoogte: 34, gewicht: 700)
		static let kop = Stijl(grootte: 22, regelhoogte: 28, gewicht: 700)
		static let subkop = Stijl(grootte: 17, regelhoogte: 24, gewicht: 600)
		static let body = Stijl(grootte: 15, regelhoogte: 22, gewicht: 400)
		static let bodyVet = Stijl(grootte: 15, regelhoogte: 22, gewicht: 600)
		static let klein = Stijl(grootte: 13, regelhoogte: 18, gewicht: 400)
		static let label = Stijl(grootte: 12, regelhoogte: 16, gewicht: 600)
	}
}

extension UIColor {
	convenience init(hex: String) {
		let s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
		var v: UInt64 = 0
		Scanner(string: s).scanHexInt64(&v)
		self.init(red: CGFloat((v >> 16) & 0xff) / 255, green: CGFloat((v >> 8) & 0xff) / 255, blue: CGFloat(v & 0xff) / 255, alpha: 1)
	}
}
