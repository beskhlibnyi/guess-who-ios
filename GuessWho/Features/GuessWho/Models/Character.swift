import Foundation

private protocol CharacterLocalizedValue {
    var localizationKey: String { get }
    var fallback: String { get }
}

private extension CharacterLocalizedValue {
    func displayName(in language: GuessWhoLanguage = .active) -> String {
        guessWhoLocalized(localizationKey, fallback: fallback, language: language)
    }
}

struct Character: Identifiable, Hashable {
    enum HairColor: String, Hashable, CaseIterable, CharacterLocalizedValue {
        case brown
        case black
        case blonde
        case red

        var localizationKey: String {
            switch self {
            case .brown:
                return "character.hair_color.brown"
            case .black:
                return "character.hair_color.black"
            case .blonde:
                return "character.hair_color.blonde"
            case .red:
                return "character.hair_color.red"
            }
        }

        var fallback: String {
            switch self {
            case .brown:
                return "Brown"
            case .black:
                return "Black"
            case .blonde:
                return "Blonde"
            case .red:
                return "Red"
            }
        }
    }

    enum Accessory: String, Hashable, CaseIterable, CharacterLocalizedValue {
        case beanie
        case scarf
        case cap
        case earrings
        case tie
        case bow
        case headband
        case jacket
        case watch
        case hoodie
        case hat
        case vest
        case necklace
        case pins
        case suspenders
        case backpack
        case tieClip
        case bracelet
        case sweater
        case bandana
        case blazer
        case collar
        case brooch
        case bowTie

        var localizationKey: String {
            switch self {
            case .beanie:
                return "character.accessory.beanie"
            case .scarf:
                return "character.accessory.scarf"
            case .cap:
                return "character.accessory.cap"
            case .earrings:
                return "character.accessory.earrings"
            case .tie:
                return "character.accessory.tie"
            case .bow:
                return "character.accessory.bow"
            case .headband:
                return "character.accessory.headband"
            case .jacket:
                return "character.accessory.jacket"
            case .watch:
                return "character.accessory.watch"
            case .hoodie:
                return "character.accessory.hoodie"
            case .hat:
                return "character.accessory.hat"
            case .vest:
                return "character.accessory.vest"
            case .necklace:
                return "character.accessory.necklace"
            case .pins:
                return "character.accessory.pins"
            case .suspenders:
                return "character.accessory.suspenders"
            case .backpack:
                return "character.accessory.backpack"
            case .tieClip:
                return "character.accessory.tie_clip"
            case .bracelet:
                return "character.accessory.bracelet"
            case .sweater:
                return "character.accessory.sweater"
            case .bandana:
                return "character.accessory.bandana"
            case .blazer:
                return "character.accessory.blazer"
            case .collar:
                return "character.accessory.collar"
            case .brooch:
                return "character.accessory.brooch"
            case .bowTie:
                return "character.accessory.bow_tie"
            }
        }

        var fallback: String {
            switch self {
            case .beanie:
                return "Beanie"
            case .scarf:
                return "Scarf"
            case .cap:
                return "Cap"
            case .earrings:
                return "Earrings"
            case .tie:
                return "Tie"
            case .bow:
                return "Bow"
            case .headband:
                return "Headband"
            case .jacket:
                return "Jacket"
            case .watch:
                return "Watch"
            case .hoodie:
                return "Hoodie"
            case .hat:
                return "Hat"
            case .vest:
                return "Vest"
            case .necklace:
                return "Necklace"
            case .pins:
                return "Pins"
            case .suspenders:
                return "Suspenders"
            case .backpack:
                return "Backpack"
            case .tieClip:
                return "Tie Clip"
            case .bracelet:
                return "Bracelet"
            case .sweater:
                return "Sweater"
            case .bandana:
                return "Bandana"
            case .blazer:
                return "Blazer"
            case .collar:
                return "Collar"
            case .brooch:
                return "Brooch"
            case .bowTie:
                return "Bow Tie"
            }
        }
    }

    enum Build: String, Hashable, CaseIterable, CharacterLocalizedValue {
        case slim
        case medium
        case broad

        var localizationKey: String {
            switch self {
            case .slim:
                return "character.build.slim"
            case .medium:
                return "character.build.medium"
            case .broad:
                return "character.build.broad"
            }
        }

        var fallback: String {
            switch self {
            case .slim:
                return "Slim"
            case .medium:
                return "Medium"
            case .broad:
                return "Broad"
            }
        }
    }

    enum SkinTone: String, Hashable, CaseIterable, CharacterLocalizedValue {
        case fair
        case light
        case medium
        case tan
        case deep

        var localizationKey: String {
            switch self {
            case .fair:
                return "character.skin.fair"
            case .light:
                return "character.skin.light"
            case .medium:
                return "character.skin.medium"
            case .tan:
                return "character.skin.tan"
            case .deep:
                return "character.skin.deep"
            }
        }

        var fallback: String {
            switch self {
            case .fair:
                return "Fair Skin"
            case .light:
                return "Light Skin"
            case .medium:
                return "Medium Skin"
            case .tan:
                return "Tan Skin"
            case .deep:
                return "Deep Skin"
            }
        }
    }

    enum HairTexture: String, Hashable, CaseIterable, CharacterLocalizedValue {
        case straight
        case wavy
        case curly
        case coily

        var localizationKey: String {
            switch self {
            case .straight:
                return "character.texture.straight"
            case .wavy:
                return "character.texture.wavy"
            case .curly:
                return "character.texture.curly"
            case .coily:
                return "character.texture.coily"
            }
        }

        var fallback: String {
            switch self {
            case .straight:
                return "Straight"
            case .wavy:
                return "Wavy"
            case .curly:
                return "Curly"
            case .coily:
                return "Coily"
            }
        }
    }

    enum HairLength: String, Hashable, CaseIterable, CharacterLocalizedValue {
        case short
        case medium
        case long

        var localizationKey: String {
            switch self {
            case .short:
                return "character.length.short"
            case .medium:
                return "character.length.medium"
            case .long:
                return "character.length.long"
            }
        }

        var fallback: String {
            switch self {
            case .short:
                return "Short"
            case .medium:
                return "Medium"
            case .long:
                return "Long"
            }
        }
    }

    let id: UUID
    let name: String
    let portraitAssetName: String
    let hairColor: HairColor
    let accessory: Accessory
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
        hairColor: HairColor,
        accessory: Accessory,
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
        visibleTraits(in: .active)
    }

    var boardTraits: [String] {
        boardTraits(in: .active)
    }

    var boardSummary: String {
        boardSummary(in: .active)
    }

    var accessibilitySummary: String {
        accessibilitySummary(in: .active)
    }

    func visibleTraits(in language: GuessWhoLanguage) -> [String] {
        [
            hairColor.displayName(in: language),
            skinTone.displayName(in: language),
            hairTexture.displayName(in: language),
            hairLength.displayName(in: language),
            build.displayName(in: language),
            wearsGlasses
                ? guessWhoLocalized("character.trait.glasses", fallback: "Glasses", language: language)
                : guessWhoLocalized("character.trait.no_glasses", fallback: "No Glasses", language: language),
            hasFacialHair
                ? guessWhoLocalized("character.trait.facial_hair", fallback: "Facial Hair", language: language)
                : guessWhoLocalized("character.trait.clean_shaven", fallback: "Clean Shaven", language: language),
            accessory.displayName(in: language)
        ]
    }

    func boardTraits(in language: GuessWhoLanguage) -> [String] {
        [
            guessWhoLocalizedFormat(
                "character.board.hair",
                fallback: "%@ %@ hair",
                language: language,
                hairColor.displayName(in: language),
                localizedLowercase(hairLength.displayName(in: language), language: language)
            ),
            guessWhoLocalizedFormat(
                "character.board.texture",
                fallback: "%@ texture",
                language: language,
                hairTexture.displayName(in: language)
            ),
            accessoryTrait(in: language)
        ]
        .compactMap { $0 }
    }

    func boardSummary(in language: GuessWhoLanguage) -> String {
        guessWhoLocalizedFormat(
            "character.board.summary",
            fallback: "%@ • %@ build",
            language: language,
            standoutFeature(in: language),
            build.displayName(in: language)
        )
    }

    func accessibilitySummary(in language: GuessWhoLanguage) -> String {
        [
            guessWhoLocalizedFormat(
                "character.accessibility.hair",
                fallback: "%@ %@ %@ hair",
                language: language,
                hairColor.displayName(in: language),
                localizedLowercase(hairLength.displayName(in: language), language: language),
                localizedLowercase(hairTexture.displayName(in: language), language: language)
            ),
            localizedLowercase(skinTone.displayName(in: language), language: language),
            localizedLowercase(standoutFeature(in: language), language: language)
        ]
        .joined(separator: ", ")
    }

    private func standoutFeature(in language: GuessWhoLanguage) -> String {
        if wearsGlasses {
            return guessWhoLocalized("character.trait.glasses", fallback: "Glasses", language: language)
        }

        if hasFacialHair {
            return guessWhoLocalized("character.trait.facial_hair", fallback: "Facial Hair", language: language)
        }

        return accessory.displayName(in: language)
    }

    private func accessoryTrait(in language: GuessWhoLanguage) -> String? {
        let localizedAccessory = accessory.displayName(in: language)
        return localizedAccessory == standoutFeature(in: language) ? nil : localizedAccessory
    }

    private func localizedLowercase(_ string: String, language: GuessWhoLanguage) -> String {
        string.lowercased(with: language.locale)
    }

    static let starterRoster: [Character] = [
        Character(name: "Міша", portraitAssetName: "Alex", hairColor: .brown, accessory: .beanie, wearsGlasses: false, hasFacialHair: false, build: .medium, skinTone: .light, hairTexture: .wavy, hairLength: .medium),
        Character(name: "Михась", portraitAssetName: "Bailey", hairColor: .black, accessory: .scarf, wearsGlasses: true, hasFacialHair: false, build: .slim, skinTone: .light, hairTexture: .straight, hairLength: .medium),
        Character(name: "Мішок", portraitAssetName: "Casey", hairColor: .blonde, accessory: .cap, wearsGlasses: false, hasFacialHair: true, build: .medium, skinTone: .light, hairTexture: .wavy, hairLength: .medium),
        Character(name: "Мішаня", portraitAssetName: "Drew", hairColor: .red, accessory: .earrings, wearsGlasses: false, hasFacialHair: false, build: .slim, skinTone: .fair, hairTexture: .wavy, hairLength: .short),
        Character(name: "Мішель", portraitAssetName: "Elliot", hairColor: .brown, accessory: .tie, wearsGlasses: true, hasFacialHair: true, build: .medium, skinTone: .tan, hairTexture: .wavy, hairLength: .medium),
        Character(name: "Майкл", portraitAssetName: "Finley", hairColor: .black, accessory: .bow, wearsGlasses: false, hasFacialHair: false, build: .slim, skinTone: .medium, hairTexture: .curly, hairLength: .long),
        Character(name: "Михуїл", portraitAssetName: "Gray", hairColor: .blonde, accessory: .headband, wearsGlasses: true, hasFacialHair: false, build: .medium, skinTone: .fair, hairTexture: .straight, hairLength: .long),
        Character(name: "Мішутка", portraitAssetName: "Harper", hairColor: .red, accessory: .jacket, wearsGlasses: false, hasFacialHair: false, build: .broad, skinTone: .medium, hairTexture: .curly, hairLength: .short),
        Character(name: "Міха", portraitAssetName: "Indigo", hairColor: .brown, accessory: .watch, wearsGlasses: false, hasFacialHair: true, build: .medium, skinTone: .tan, hairTexture: .wavy, hairLength: .short),
        Character(name: "Міхалич", portraitAssetName: "Jules", hairColor: .black, accessory: .hoodie, wearsGlasses: true, hasFacialHair: false, build: .slim, skinTone: .deep, hairTexture: .coily, hairLength: .short),
        Character(name: "Мишко", portraitAssetName: "Kai", hairColor: .blonde, accessory: .hat, wearsGlasses: false, hasFacialHair: false, build: .medium, skinTone: .medium, hairTexture: .curly, hairLength: .medium),
        Character(name: "Міхан", portraitAssetName: "Logan", hairColor: .red, accessory: .vest, wearsGlasses: false, hasFacialHair: true, build: .broad, skinTone: .light, hairTexture: .wavy, hairLength: .short),
        Character(name: "Міхасько", portraitAssetName: "Morgan", hairColor: .brown, accessory: .necklace, wearsGlasses: true, hasFacialHair: false, build: .medium, skinTone: .tan, hairTexture: .curly, hairLength: .long),
        Character(name: "Міхо", portraitAssetName: "Nova", hairColor: .black, accessory: .pins, wearsGlasses: false, hasFacialHair: false, build: .slim, skinTone: .light, hairTexture: .straight, hairLength: .short),
        Character(name: "Мішелло", portraitAssetName: "Oakley", hairColor: .blonde, accessory: .suspenders, wearsGlasses: true, hasFacialHair: true, build: .broad, skinTone: .fair, hairTexture: .straight, hairLength: .medium),
        Character(name: "Міхал", portraitAssetName: "Parker", hairColor: .red, accessory: .backpack, wearsGlasses: false, hasFacialHair: false, build: .medium, skinTone: .deep, hairTexture: .coily, hairLength: .short),
        Character(name: "Михайло", portraitAssetName: "Quinn", hairColor: .brown, accessory: .tieClip, wearsGlasses: false, hasFacialHair: false, build: .medium, skinTone: .tan, hairTexture: .wavy, hairLength: .short),
        Character(name: "Мішелько", portraitAssetName: "Reese", hairColor: .black, accessory: .bracelet, wearsGlasses: true, hasFacialHair: true, build: .broad, skinTone: .medium, hairTexture: .wavy, hairLength: .medium),
        Character(name: "Мишан", portraitAssetName: "Sawyer", hairColor: .blonde, accessory: .sweater, wearsGlasses: false, hasFacialHair: false, build: .medium, skinTone: .light, hairTexture: .straight, hairLength: .long),
        Character(name: "Міхася", portraitAssetName: "Taylor", hairColor: .red, accessory: .bandana, wearsGlasses: true, hasFacialHair: false, build: .slim, skinTone: .medium, hairTexture: .curly, hairLength: .medium),
        Character(name: "Мішун", portraitAssetName: "Urban", hairColor: .brown, accessory: .blazer, wearsGlasses: false, hasFacialHair: true, build: .broad, skinTone: .deep, hairTexture: .coily, hairLength: .short),
        Character(name: "Міхайлик", portraitAssetName: "Vale", hairColor: .black, accessory: .collar, wearsGlasses: false, hasFacialHair: false, build: .medium, skinTone: .medium, hairTexture: .straight, hairLength: .medium),
        Character(name: "Мішико", portraitAssetName: "Winter", hairColor: .blonde, accessory: .brooch, wearsGlasses: true, hasFacialHair: false, build: .slim, skinTone: .light, hairTexture: .straight, hairLength: .long),
        Character(name: "Михайлик", portraitAssetName: "Zion", hairColor: .red, accessory: .bowTie, wearsGlasses: false, hasFacialHair: true, build: .broad, skinTone: .deep, hairTexture: .coily, hairLength: .short)
    ]
}
