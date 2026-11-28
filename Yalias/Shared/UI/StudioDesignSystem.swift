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
    static let subheadline = Font.custom("AvenirNext-Medium", size: 17)
    static let body = Font.custom("AvenirNext-Regular", size: 17)
    static let footnote = Font.custom("AvenirNext-Regular", size: 14)
    static let button = Font.custom("AvenirNext-DemiBold", size: 18)
    static let label = Font.custom("AvenirNext-DemiBold", size: 12)
    static let compactLabel = Font.custom("AvenirNext-DemiBold", size: 11)
    static let paperDisplay = Font.custom("AvenirNext-Heavy", size: 58)
    static let paperTitle = Font.custom("AvenirNext-DemiBold", size: 24)
    static let paperControl = Font.custom("AvenirNext-DemiBold", size: 20)
    static let paperButton = Font.custom("AvenirNext-DemiBold", size: 25)
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

    // YALIAS handmade-paper direction. Keep the original semantic colors above
    // while the new visual language is rolled out screen by screen.
    static let homeCanvas = Color(red: 0.992, green: 0.882, blue: 0.776)
    static let paperCanvas = Color(red: 0.976, green: 0.925, blue: 0.851)
    static let paper = Color(red: 1.0, green: 0.953, blue: 0.871)
    static let paperHighlight = Color(red: 1.0, green: 0.974, blue: 0.925)
    static let paperInk = Color(red: 0.129, green: 0.118, blue: 0.098)
    static let olive = Color(red: 0.373, green: 0.478, blue: 0.176)
    static let mustard = Color(red: 0.949, green: 0.710, blue: 0.114)
    static let vermilion = Color(red: 0.851, green: 0.290, blue: 0.196)
    static let sky = Color(red: 0.471, green: 0.682, blue: 0.816)
    static let sage = Color(red: 0.608, green: 0.667, blue: 0.345)

    static func accentGradientColor(at progress: Double) -> Color {
        let progress = min(max(progress, 0), 1)
        return Color(
            red: 0.949 + (0.851 - 0.949) * progress,
            green: 0.710 + (0.290 - 0.710) * progress,
            blue: 0.114 + (0.196 - 0.114) * progress
        )
    }
}

struct YaliasPaperBackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                StudioTheme.paperCanvas

                RadialGradient(
                    colors: [StudioTheme.paperHighlight.opacity(0.34), .clear],
                    center: .center,
                    startRadius: 40,
                    endRadius: max(geometry.size.width, geometry.size.height) * 0.72
                )

                PaperGrain()
                    .stroke(StudioTheme.paperInk.opacity(0.022), lineWidth: 0.65)

                CornerPaperPatch(corner: .topLeading)
                    .fill(StudioTheme.olive)

                CornerPaperPatch(corner: .bottomLeading)
                    .fill(StudioTheme.sky)

                CornerPaperPatch(corner: .bottomTrailing)
                    .fill(StudioTheme.mustard)
            }
        }
        .ignoresSafeArea()
    }
}

private struct CornerPaperPatch: Shape {
    enum Corner {
        case topLeading
        case bottomLeading
        case bottomTrailing
    }

    let corner: Corner

    func path(in rect: CGRect) -> Path {
        var path = Path()

        switch corner {
        case .topLeading:
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.105))
            path.addCurve(
                to: CGPoint(x: rect.minX + rect.width * 0.28, y: rect.minY),
                control1: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.minY + rect.height * 0.085),
                control2: CGPoint(x: rect.minX + rect.width * 0.19, y: rect.minY + rect.height * 0.025)
            )
            path.closeSubpath()

        case .bottomLeading:
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - rect.height * 0.075))
            path.addCurve(
                to: CGPoint(x: rect.minX + rect.width * 0.22, y: rect.maxY),
                control1: CGPoint(x: rect.minX + rect.width * 0.07, y: rect.maxY - rect.height * 0.055),
                control2: CGPoint(x: rect.minX + rect.width * 0.14, y: rect.maxY - rect.height * 0.018)
            )
            path.closeSubpath()

        case .bottomTrailing:
            path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - rect.height * 0.12))
            path.addCurve(
                to: CGPoint(x: rect.maxX - rect.width * 0.25, y: rect.maxY),
                control1: CGPoint(x: rect.maxX - rect.width * 0.04, y: rect.maxY - rect.height * 0.085),
                control2: CGPoint(x: rect.maxX - rect.width * 0.16, y: rect.maxY - rect.height * 0.035)
            )
            path.closeSubpath()
        }

        return path
    }
}

struct PaperGrain: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let columns = max(Int(rect.width / 20), 1)
        let rows = max(Int(rect.height / 20), 1)

        for row in 0...rows {
            for column in 0...columns {
                let seed = Double(row * 37 + column * 19)
                let x = CGFloat(column) * 20 + CGFloat(sin(seed) * 7)
                let y = CGFloat(row) * 20 + CGFloat(cos(seed * 0.71) * 7)
                path.move(to: CGPoint(x: x, y: y))
                path.addLine(to: CGPoint(x: x + 3 + CGFloat(sin(seed * 0.3)), y: y + 1.5))
            }
        }
        return path
    }
}

struct PaperPanel<Content: View>: View {
    private let content: Content
    private let padding: CGFloat
    private let cornerRadius: CGFloat

    init(
        padding: CGFloat = 18,
        cornerRadius: CGFloat = 24,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                StudioTheme.paper.opacity(0.96),
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(StudioTheme.paperInk.opacity(0.12), lineWidth: 1)
            }
            .shadow(color: StudioTheme.paperInk.opacity(0.13), radius: 8, x: 1, y: 6)
    }
}

struct TornPaperShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 10

        path.move(to: CGPoint(x: 8, y: 4))
        var x: CGFloat = 8
        var index = 0
        while x < rect.maxX - 8 {
            let y = 4 + CGFloat(sin(Double(index) * 1.7)) * 2.4
            path.addLine(to: CGPoint(x: x, y: y))
            x += step
            index += 1
        }
        path.addLine(to: CGPoint(x: rect.maxX - 5, y: 8))
        path.addLine(to: CGPoint(x: rect.maxX - 3, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - 7, y: rect.maxY - 6))

        x = rect.maxX - 8
        while x > 8 {
            let y = rect.maxY - 4 + CGFloat(cos(Double(index) * 1.41)) * 2.4
            path.addLine(to: CGPoint(x: x, y: y))
            x -= step
            index += 1
        }
        path.addLine(to: CGPoint(x: 5, y: rect.maxY - 8))
        path.addLine(to: CGPoint(x: 3, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

struct PaperActionButtonStyle: ButtonStyle {
    enum Kind {
        case filled(Color)
        case outlined
    }

    let kind: Kind

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StudioTypography.paperButton)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, minHeight: 60)
            .foregroundStyle(foregroundColor)
            .background { background(configuration: configuration) }
            .overlay { outline }
            .contentShape(TornPaperShape())
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .shadow(
                color: StudioTheme.paperInk.opacity(configuration.isPressed ? 0.10 : 0.18),
                radius: configuration.isPressed ? 3 : 7,
                x: 1,
                y: configuration.isPressed ? 2 : 5
            )
    }

    @ViewBuilder
    private func background(configuration: Configuration) -> some View {
        switch kind {
        case .filled(let color):
            TornPaperShape().fill(color.opacity(configuration.isPressed ? 0.84 : 1))
        case .outlined:
            TornPaperShape().fill(StudioTheme.paper.opacity(configuration.isPressed ? 0.82 : 0.96))
        }
    }

    @ViewBuilder
    private var outline: some View {
        switch kind {
        case .filled:
            EmptyView()
        case .outlined:
            TornPaperShape().stroke(StudioTheme.paperInk, lineWidth: 2.4)
        }
    }

    private var foregroundColor: Color {
        switch kind {
        case .filled: StudioTheme.paperHighlight
        case .outlined: StudioTheme.paperInk
        }
    }
}

struct PaperSlider: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let accessibilityValue: String
    var fillStyle: AnyShapeStyle = AnyShapeStyle(StudioTheme.olive)
    var thumbColor: Color = StudioTheme.mustard

    var body: some View {
        GeometryReader { geometry in
            let inset: CGFloat = 15
            let availableWidth = max(geometry.size.width - inset * 2, 1)
            let progress = CGFloat(value - range.lowerBound) / CGFloat(max(range.upperBound - range.lowerBound, 1))
            let thumbX = inset + availableWidth * progress
            let fillTrackWidth = max(availableWidth - 2, 1)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(StudioTheme.paperHighlight)
                    .overlay { Capsule().stroke(StudioTheme.paperInk, lineWidth: 2.4) }
                    .frame(height: 18)
                    .padding(.horizontal, inset)

                Capsule()
                    .fill(fillStyle)
                    .frame(width: fillTrackWidth, height: 16)
                    .mask(alignment: .leading) {
                        Rectangle()
                            .frame(width: max(fillTrackWidth * progress, 1))
                    }
                    .offset(x: inset + 1)

                Circle()
                    .fill(thumbColor)
                    .overlay { Circle().stroke(StudioTheme.paperInk, lineWidth: 2.4) }
                    .frame(width: 30, height: 30)
                    .position(x: thumbX, y: geometry.size.height / 2)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let fraction = min(max((gesture.location.x - inset) / availableWidth, 0), 1)
                        value = range.lowerBound + Int((fraction * CGFloat(range.upperBound - range.lowerBound)).rounded())
                    }
            )
        }
        .frame(height: 38)
        .accessibilityElement()
        .accessibilityValue(accessibilityValue)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: value = min(value + 1, range.upperBound)
            case .decrement: value = max(value - 1, range.lowerBound)
            @unknown default: break
            }
        }
        .sensoryFeedback(.selection, trigger: value)
    }
}
