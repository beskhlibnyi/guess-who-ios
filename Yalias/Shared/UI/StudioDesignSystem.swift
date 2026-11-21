import SwiftUI

struct StudioBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [StudioTheme.canvasTop, StudioTheme.canvasBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(StudioTheme.gold.opacity(0.16))
                .frame(width: 260, height: 260)
                .blur(radius: 10)
                .offset(x: 150, y: -280)
            Circle()
                .fill(StudioTheme.coral.opacity(0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 18)
                .offset(x: -150, y: 290)
            Circle()
                .fill(StudioTheme.teal.opacity(0.11))
                .frame(width: 240, height: 240)
                .blur(radius: 18)
                .offset(x: 170, y: 360)
        }
    }
}

struct ActionButtonStyle: ButtonStyle {
    enum Kind {
        case filled(Color)
        case outlined(Color)
        case ghost
    }

    let kind: Kind

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StudioTypography.button)
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
            .frame(minHeight: 58)
            .background(background(configuration: configuration))
            .foregroundStyle(foregroundColor)
            .overlay {
                Capsule().strokeBorder(borderColor, lineWidth: borderWidth)
            }
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .shadow(
                color: shadowColor(configuration: configuration),
                radius: configuration.isPressed ? 4 : 10,
                x: 0,
                y: configuration.isPressed ? 2 : 6
            )
    }

    private func background(configuration: Configuration) -> some View {
        Group {
            switch kind {
            case .filled(let color):
                color.opacity(configuration.isPressed ? 0.86 : 1)
            case .outlined:
                Color.white.opacity(configuration.isPressed ? 0.9 : 1)
            case .ghost:
                StudioTheme.softWash.opacity(configuration.isPressed ? 0.76 : 1)
            }
        }
    }

    private var foregroundColor: Color {
        switch kind {
        case .filled: .white
        case .outlined(let color): color
        case .ghost: StudioTheme.ink
        }
    }

    private var borderColor: Color {
        switch kind {
        case .filled: .clear
        case .outlined(let color): color.opacity(0.32)
        case .ghost: StudioTheme.line
        }
    }

    private var borderWidth: CGFloat {
        switch kind {
        case .filled: 0
        case .outlined, .ghost: 1
        }
    }

    private func shadowColor(configuration: Configuration) -> Color {
        switch kind {
        case .filled(let color):
            color.opacity(configuration.isPressed ? 0.12 : 0.22)
        case .outlined, .ghost:
            StudioTheme.shadowSoft
        }
    }
}

enum StudioTypography {
    static let displaySmall = Font.custom("AvenirNext-Heavy", size: 34)
    static let brandTitle = Font.custom("Yakutovych", size: 64)
    static let title = Font.custom("AvenirNext-DemiBold", size: 22)
    static let subheadline = Font.custom("AvenirNext-Medium", size: 17)
    static let body = Font.custom("AvenirNext-Regular", size: 17)
    static let footnote = Font.custom("AvenirNext-Regular", size: 14)
    static let button = Font.custom("AvenirNext-DemiBold", size: 18)
    static let label = Font.custom("AvenirNext-DemiBold", size: 12)
    static let compactLabel = Font.custom("AvenirNext-DemiBold", size: 11)
}

enum StudioTheme {
    static let canvasTop = Color(red: 0.985, green: 0.965, blue: 0.925)
    static let canvasBottom = Color(red: 0.949, green: 0.92, blue: 0.872)
    static let card = Color(red: 0.997, green: 0.991, blue: 0.979)
    static let softWash = Color(red: 0.952, green: 0.94, blue: 0.914)
    static let line = Color(red: 0.866, green: 0.823, blue: 0.764)
    static let ink = Color(red: 0.152, green: 0.145, blue: 0.163)
    static let inkSoft = Color(red: 0.232, green: 0.228, blue: 0.243)
    static let muted = Color(red: 0.435, green: 0.44, blue: 0.458)
    static let coral = Color(red: 0.84, green: 0.352, blue: 0.278)
    static let teal = Color(red: 0.117, green: 0.47, blue: 0.447)
    static let gold = Color(red: 0.73, green: 0.58, blue: 0.27)
    static let shadowSoft = Color.black.opacity(0.08)
    static let shadowStrong = Color.black.opacity(0.12)
}
