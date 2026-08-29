import Foundation

struct Character: Identifiable, Hashable {
    let id: UUID
    let name: String
    let hairColor: String
    let accessory: String
    let wearsGlasses: Bool
    let hasFacialHair: Bool

    init(
        id: UUID = UUID(),
        name: String,
        hairColor: String,
        accessory: String,
        wearsGlasses: Bool,
        hasFacialHair: Bool
    ) {
        self.id = id
        self.name = name
        self.hairColor = hairColor
        self.accessory = accessory
        self.wearsGlasses = wearsGlasses
        self.hasFacialHair = hasFacialHair
    }
}

extension Character {
    static let starterRoster: [Character] = [
        Character(name: "Alex", hairColor: "Brown", accessory: "Beanie", wearsGlasses: false, hasFacialHair: false),
        Character(name: "Bailey", hairColor: "Black", accessory: "Scarf", wearsGlasses: true, hasFacialHair: false),
        Character(name: "Casey", hairColor: "Blonde", accessory: "Cap", wearsGlasses: false, hasFacialHair: true),
        Character(name: "Drew", hairColor: "Red", accessory: "Earrings", wearsGlasses: false, hasFacialHair: false),
        Character(name: "Elliot", hairColor: "Brown", accessory: "Tie", wearsGlasses: true, hasFacialHair: true),
        Character(name: "Finley", hairColor: "Black", accessory: "Bow", wearsGlasses: false, hasFacialHair: false),
        Character(name: "Gray", hairColor: "Blonde", accessory: "Headband", wearsGlasses: true, hasFacialHair: false),
        Character(name: "Harper", hairColor: "Red", accessory: "Jacket", wearsGlasses: false, hasFacialHair: false),
        Character(name: "Indigo", hairColor: "Brown", accessory: "Watch", wearsGlasses: false, hasFacialHair: true),
        Character(name: "Jules", hairColor: "Black", accessory: "Hoodie", wearsGlasses: true, hasFacialHair: false),
        Character(name: "Kai", hairColor: "Blonde", accessory: "Hat", wearsGlasses: false, hasFacialHair: false),
        Character(name: "Logan", hairColor: "Red", accessory: "Vest", wearsGlasses: false, hasFacialHair: true),
        Character(name: "Morgan", hairColor: "Brown", accessory: "Necklace", wearsGlasses: true, hasFacialHair: false),
        Character(name: "Nova", hairColor: "Black", accessory: "Pins", wearsGlasses: false, hasFacialHair: false),
        Character(name: "Oakley", hairColor: "Blonde", accessory: "Suspenders", wearsGlasses: true, hasFacialHair: true),
        Character(name: "Parker", hairColor: "Red", accessory: "Backpack", wearsGlasses: false, hasFacialHair: false),
        Character(name: "Quinn", hairColor: "Brown", accessory: "Tie Clip", wearsGlasses: false, hasFacialHair: false),
        Character(name: "Reese", hairColor: "Black", accessory: "Bracelet", wearsGlasses: true, hasFacialHair: true),
        Character(name: "Sawyer", hairColor: "Blonde", accessory: "Sweater", wearsGlasses: false, hasFacialHair: false),
        Character(name: "Taylor", hairColor: "Red", accessory: "Bandana", wearsGlasses: true, hasFacialHair: false),
        Character(name: "Urban", hairColor: "Brown", accessory: "Blazer", wearsGlasses: false, hasFacialHair: true),
        Character(name: "Vale", hairColor: "Black", accessory: "Collar", wearsGlasses: false, hasFacialHair: false),
        Character(name: "Winter", hairColor: "Blonde", accessory: "Brooch", wearsGlasses: true, hasFacialHair: false),
        Character(name: "Zion", hairColor: "Red", accessory: "Bow Tie", wearsGlasses: false, hasFacialHair: true)
    ]
}

