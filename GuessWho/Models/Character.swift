import Foundation

struct Character: Identifiable, Hashable {
    enum Build: String, Hashable {
        case slim
        case medium
        case broad
    }

    enum SkinTone: String, Hashable {
        case fair
        case light
        case medium
        case tan
        case deep
    }

    enum HairTexture: String, Hashable {
        case straight
        case wavy
        case curly
        case coily
    }

    enum HairLength: String, Hashable {
        case short
        case medium
        case long
    }

    let id: UUID
    let name: String
    let portraitAssetName: String
    let hairColor: String
    let accessory: String
    let wearsGlasses: Bool
    let hasFacialHair: Bool
    let build: Build
    let skinTone: SkinTone
    let hairTexture: HairTexture
    let hairLength: HairLength

    init(
        id: UUID = UUID(),
        name: String,
        portraitAssetName: String? = nil,
        hairColor: String,
        accessory: String,
        wearsGlasses: Bool,
        hasFacialHair: Bool,
        build: Build,
        skinTone: SkinTone,
        hairTexture: HairTexture,
        hairLength: HairLength
    ) {
        self.id = id
        self.name = name
        self.portraitAssetName = portraitAssetName ?? name
        self.hairColor = hairColor
        self.accessory = accessory
        self.wearsGlasses = wearsGlasses
        self.hasFacialHair = hasFacialHair
        self.build = build
        self.skinTone = skinTone
        self.hairTexture = hairTexture
        self.hairLength = hairLength
    }
}

extension Character {
    var visibleTraits: [String] {
        [
            localizedHairColor,
            skinTone.displayName,
            hairTexture.displayName,
            hairLength.displayName,
            build.displayName,
            wearsGlasses ? guessWhoLocalized("character.trait.glasses", fallback: "Glasses") : guessWhoLocalized("character.trait.no_glasses", fallback: "No Glasses"),
            hasFacialHair ? guessWhoLocalized("character.trait.facial_hair", fallback: "Facial Hair") : guessWhoLocalized("character.trait.clean_shaven", fallback: "Clean Shaven"),
            localizedAccessory
        ]
    }

    var boardTraits: [String] {
        [
            guessWhoLocalizedFormat("character.board.hair", fallback: "%@ %@ hair", localizedHairColor, hairLength.displayName.lowercased()),
            guessWhoLocalizedFormat("character.board.texture", fallback: "%@ texture", hairTexture.displayName),
            accessoryTrait
        ]
        .compactMap { $0 }
    }

    var boardSummary: String {
        guessWhoLocalizedFormat("character.board.summary", fallback: "%@ • %@ build", standoutFeature, build.displayName)
    }

    var accessibilitySummary: String {
        [
            guessWhoLocalizedFormat(
                "character.accessibility.hair",
                fallback: "%@ %@ %@ hair",
                localizedHairColor,
                hairLength.displayName.lowercased(),
                hairTexture.displayName.lowercased()
            ),
            skinTone.displayName.lowercased(),
            standoutFeature.lowercased()
        ]
        .joined(separator: ", ")
    }

    private var standoutFeature: String {
        if wearsGlasses {
            return guessWhoLocalized("character.trait.glasses", fallback: "Glasses")
        }

        if hasFacialHair {
            return guessWhoLocalized("character.trait.facial_hair", fallback: "Facial Hair")
        }

        return localizedAccessory
    }

    private var accessoryTrait: String? {
        localizedAccessory == standoutFeature ? nil : localizedAccessory
    }

    private var localizedHairColor: String {
        switch hairColor {
        case "Brown":
            return guessWhoLocalized("character.hair_color.brown", fallback: "Brown")
        case "Black":
            return guessWhoLocalized("character.hair_color.black", fallback: "Black")
        case "Blonde":
            return guessWhoLocalized("character.hair_color.blonde", fallback: "Blonde")
        case "Red":
            return guessWhoLocalized("character.hair_color.red", fallback: "Red")
        default:
            return hairColor
        }
    }

    private var localizedAccessory: String {
        switch accessory {
        case "Beanie":
            return guessWhoLocalized("character.accessory.beanie", fallback: "Beanie")
        case "Scarf":
            return guessWhoLocalized("character.accessory.scarf", fallback: "Scarf")
        case "Cap":
            return guessWhoLocalized("character.accessory.cap", fallback: "Cap")
        case "Earrings":
            return guessWhoLocalized("character.accessory.earrings", fallback: "Earrings")
        case "Tie":
            return guessWhoLocalized("character.accessory.tie", fallback: "Tie")
        case "Bow":
            return guessWhoLocalized("character.accessory.bow", fallback: "Bow")
        case "Headband":
            return guessWhoLocalized("character.accessory.headband", fallback: "Headband")
        case "Jacket":
            return guessWhoLocalized("character.accessory.jacket", fallback: "Jacket")
        case "Watch":
            return guessWhoLocalized("character.accessory.watch", fallback: "Watch")
        case "Hoodie":
            return guessWhoLocalized("character.accessory.hoodie", fallback: "Hoodie")
        case "Hat":
            return guessWhoLocalized("character.accessory.hat", fallback: "Hat")
        case "Vest":
            return guessWhoLocalized("character.accessory.vest", fallback: "Vest")
        case "Necklace":
            return guessWhoLocalized("character.accessory.necklace", fallback: "Necklace")
        case "Pins":
            return guessWhoLocalized("character.accessory.pins", fallback: "Pins")
        case "Suspenders":
            return guessWhoLocalized("character.accessory.suspenders", fallback: "Suspenders")
        case "Backpack":
            return guessWhoLocalized("character.accessory.backpack", fallback: "Backpack")
        case "Tie Clip":
            return guessWhoLocalized("character.accessory.tie_clip", fallback: "Tie Clip")
        case "Bracelet":
            return guessWhoLocalized("character.accessory.bracelet", fallback: "Bracelet")
        case "Sweater":
            return guessWhoLocalized("character.accessory.sweater", fallback: "Sweater")
        case "Bandana":
            return guessWhoLocalized("character.accessory.bandana", fallback: "Bandana")
        case "Blazer":
            return guessWhoLocalized("character.accessory.blazer", fallback: "Blazer")
        case "Collar":
            return guessWhoLocalized("character.accessory.collar", fallback: "Collar")
        case "Brooch":
            return guessWhoLocalized("character.accessory.brooch", fallback: "Brooch")
        case "Bow Tie":
            return guessWhoLocalized("character.accessory.bow_tie", fallback: "Bow Tie")
        default:
            return accessory
        }
    }

    static let starterRoster: [Character] = [
        Character(name: "Міша", portraitAssetName: "Alex", hairColor: "Brown", accessory: "Beanie", wearsGlasses: false, hasFacialHair: false, build: .medium, skinTone: .light, hairTexture: .wavy, hairLength: .medium),
        Character(name: "Михась", portraitAssetName: "Bailey", hairColor: "Black", accessory: "Scarf", wearsGlasses: true, hasFacialHair: false, build: .slim, skinTone: .light, hairTexture: .straight, hairLength: .medium),
        Character(name: "Мішок", portraitAssetName: "Casey", hairColor: "Blonde", accessory: "Cap", wearsGlasses: false, hasFacialHair: true, build: .medium, skinTone: .light, hairTexture: .wavy, hairLength: .medium),
        Character(name: "Мішаня", portraitAssetName: "Drew", hairColor: "Red", accessory: "Earrings", wearsGlasses: false, hasFacialHair: false, build: .slim, skinTone: .fair, hairTexture: .wavy, hairLength: .short),
        Character(name: "Мішель", portraitAssetName: "Elliot", hairColor: "Brown", accessory: "Tie", wearsGlasses: true, hasFacialHair: true, build: .medium, skinTone: .tan, hairTexture: .wavy, hairLength: .medium),
        Character(name: "Майкл", portraitAssetName: "Finley", hairColor: "Black", accessory: "Bow", wearsGlasses: false, hasFacialHair: false, build: .slim, skinTone: .medium, hairTexture: .curly, hairLength: .long),
        Character(name: "Михуїл", portraitAssetName: "Gray", hairColor: "Blonde", accessory: "Headband", wearsGlasses: true, hasFacialHair: false, build: .medium, skinTone: .fair, hairTexture: .straight, hairLength: .long),
        Character(name: "Мішутка", portraitAssetName: "Harper", hairColor: "Red", accessory: "Jacket", wearsGlasses: false, hasFacialHair: false, build: .broad, skinTone: .medium, hairTexture: .curly, hairLength: .short),
        Character(name: "Міха", portraitAssetName: "Indigo", hairColor: "Brown", accessory: "Watch", wearsGlasses: false, hasFacialHair: true, build: .medium, skinTone: .tan, hairTexture: .wavy, hairLength: .short),
        Character(name: "Міхалич", portraitAssetName: "Jules", hairColor: "Black", accessory: "Hoodie", wearsGlasses: true, hasFacialHair: false, build: .slim, skinTone: .deep, hairTexture: .coily, hairLength: .short),
        Character(name: "Мишко", portraitAssetName: "Kai", hairColor: "Blonde", accessory: "Hat", wearsGlasses: false, hasFacialHair: false, build: .medium, skinTone: .medium, hairTexture: .curly, hairLength: .medium),
        Character(name: "Міхан", portraitAssetName: "Logan", hairColor: "Red", accessory: "Vest", wearsGlasses: false, hasFacialHair: true, build: .broad, skinTone: .light, hairTexture: .wavy, hairLength: .short),
        Character(name: "Міхасько", portraitAssetName: "Morgan", hairColor: "Brown", accessory: "Necklace", wearsGlasses: true, hasFacialHair: false, build: .medium, skinTone: .tan, hairTexture: .curly, hairLength: .long),
        Character(name: "Міхо", portraitAssetName: "Nova", hairColor: "Black", accessory: "Pins", wearsGlasses: false, hasFacialHair: false, build: .slim, skinTone: .light, hairTexture: .straight, hairLength: .short),
        Character(name: "Мішелло", portraitAssetName: "Oakley", hairColor: "Blonde", accessory: "Suspenders", wearsGlasses: true, hasFacialHair: true, build: .broad, skinTone: .fair, hairTexture: .straight, hairLength: .medium),
        Character(name: "Міхал", portraitAssetName: "Parker", hairColor: "Red", accessory: "Backpack", wearsGlasses: false, hasFacialHair: false, build: .medium, skinTone: .deep, hairTexture: .coily, hairLength: .short),
        Character(name: "Михайло", portraitAssetName: "Quinn", hairColor: "Brown", accessory: "Tie Clip", wearsGlasses: false, hasFacialHair: false, build: .medium, skinTone: .tan, hairTexture: .wavy, hairLength: .short),
        Character(name: "Мішелько", portraitAssetName: "Reese", hairColor: "Black", accessory: "Bracelet", wearsGlasses: true, hasFacialHair: true, build: .broad, skinTone: .medium, hairTexture: .wavy, hairLength: .medium),
        Character(name: "Мишан", portraitAssetName: "Sawyer", hairColor: "Blonde", accessory: "Sweater", wearsGlasses: false, hasFacialHair: false, build: .medium, skinTone: .light, hairTexture: .straight, hairLength: .long),
        Character(name: "Міхася", portraitAssetName: "Taylor", hairColor: "Red", accessory: "Bandana", wearsGlasses: true, hasFacialHair: false, build: .slim, skinTone: .medium, hairTexture: .curly, hairLength: .medium),
        Character(name: "Мішун", portraitAssetName: "Urban", hairColor: "Brown", accessory: "Blazer", wearsGlasses: false, hasFacialHair: true, build: .broad, skinTone: .deep, hairTexture: .coily, hairLength: .short),
        Character(name: "Міхайлик", portraitAssetName: "Vale", hairColor: "Black", accessory: "Collar", wearsGlasses: false, hasFacialHair: false, build: .medium, skinTone: .medium, hairTexture: .straight, hairLength: .medium),
        Character(name: "Мішико", portraitAssetName: "Winter", hairColor: "Blonde", accessory: "Brooch", wearsGlasses: true, hasFacialHair: false, build: .slim, skinTone: .light, hairTexture: .straight, hairLength: .long),
        Character(name: "Михайлик", portraitAssetName: "Zion", hairColor: "Red", accessory: "Bow Tie", wearsGlasses: false, hasFacialHair: true, build: .broad, skinTone: .deep, hairTexture: .coily, hairLength: .short)
    ]
}

extension Character.Build {
    var displayName: String {
        switch self {
        case .slim:
            return guessWhoLocalized("character.build.slim", fallback: "Slim")
        case .medium:
            return guessWhoLocalized("character.build.medium", fallback: "Medium")
        case .broad:
            return guessWhoLocalized("character.build.broad", fallback: "Broad")
        }
    }
}

extension Character.SkinTone {
    var displayName: String {
        switch self {
        case .fair:
            return guessWhoLocalized("character.skin.fair", fallback: "Fair Skin")
        case .light:
            return guessWhoLocalized("character.skin.light", fallback: "Light Skin")
        case .medium:
            return guessWhoLocalized("character.skin.medium", fallback: "Medium Skin")
        case .tan:
            return guessWhoLocalized("character.skin.tan", fallback: "Tan Skin")
        case .deep:
            return guessWhoLocalized("character.skin.deep", fallback: "Deep Skin")
        }
    }
}

extension Character.HairTexture {
    var displayName: String {
        switch self {
        case .straight:
            return guessWhoLocalized("character.texture.straight", fallback: "Straight")
        case .wavy:
            return guessWhoLocalized("character.texture.wavy", fallback: "Wavy")
        case .curly:
            return guessWhoLocalized("character.texture.curly", fallback: "Curly")
        case .coily:
            return guessWhoLocalized("character.texture.coily", fallback: "Coily")
        }
    }
}

extension Character.HairLength {
    var displayName: String {
        switch self {
        case .short:
            return guessWhoLocalized("character.length.short", fallback: "Short")
        case .medium:
            return guessWhoLocalized("character.length.medium", fallback: "Medium")
        case .long:
            return guessWhoLocalized("character.length.long", fallback: "Long")
        }
    }
}
