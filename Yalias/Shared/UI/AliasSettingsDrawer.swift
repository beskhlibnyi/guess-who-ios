import SwiftUI

/// A compact settings sheet for the Alias home screen.
struct AliasSettingsDrawer: View {
    @Binding var languageOverride: String
    @Binding var playerOneName: String
    @Binding var playerTwoName: String
    @Binding var isPresented: Bool
    @State private var sheetDragOffset: CGFloat = 0

    private var selectedLanguage: AliasLanguage {
        AliasLanguage.resolved(override: languageOverride)
    }

    var body: some View {
        GeometryReader { geometry in
            let panelWidth = min(420, geometry.size.width - 20)
            let panelHeight = min(620, geometry.size.height * 0.84)
            let closedOffset = panelHeight + 40
            let sheetOffset = resolvedSheetOffset(closedOffset: closedOffset)
            let sheetProgress = 1 - (sheetOffset / closedOffset)

            ZStack(alignment: .bottom) {
                Color.black.opacity(0.24 * sheetProgress)
                    .ignoresSafeArea()
                    .allowsHitTesting(isPresented)
                    .onTapGesture(perform: dismiss)

                settingsPanel(
                    width: panelWidth,
                    height: panelHeight
                )
                .offset(y: sheetOffset)
                .padding(.bottom, 8)
            }
        }
    }

    private func settingsPanel(
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        VStack(spacing: 8) {
            sheetHandle
            settingsHeader
            settingsContent
            doneButton
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .frame(width: width, height: height)
        .background {
            TornPaperShape()
                .fill(StudioTheme.paper)
        }
        .overlay {
            TornPaperShape()
                .stroke(StudioTheme.paperInk, lineWidth: 2)
        }
        .overlay(alignment: .topLeading) {
            tapeScrap
                .rotationEffect(.degrees(-12))
                .offset(x: 12, y: 4)
        }
        .overlay(alignment: .bottomTrailing) {
            tapeScrap
                .rotationEffect(.degrees(-17))
                .offset(x: -12, y: -9)
        }
        .shadow(color: StudioTheme.paperInk.opacity(0.20), radius: 14, x: 0, y: -4)
    }

    private var sheetHandle: some View {
        ZStack {
            Color.clear

            Capsule()
                .fill(StudioTheme.paperInk.opacity(0.46))
                .frame(width: 54, height: 6)
        }
        .frame(height: 30)
        .contentShape(Rectangle())
        .gesture(sheetDragGesture)
        .accessibilityLabel(copy("settings.close", fallback: "Close settings"))
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { dismiss() }
    }

    private var doneButton: some View {
        Button(action: dismiss) {
            Text(copy("common.done", fallback: "Done"))
        }
        .buttonStyle(PaperActionButtonStyle(kind: .filled(StudioTheme.vermilion)))
    }

    private var settingsContent: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 22) {
                playerSettings

                Capsule()
                    .fill(StudioTheme.paperInk)
                    .frame(height: 2)
                    .rotationEffect(.degrees(-0.4))

                languageSettings
            }
            .padding(.top, 2)
            .padding(.bottom, 12)
        }
        .scrollIndicators(.hidden)
    }

    private var settingsHeader: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(copy("settings.title", fallback: "Settings"))
                    .font(StudioTypography.paperTitle)
                    .foregroundStyle(StudioTheme.paperInk)
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .minimumScaleFactor(0.64)

                Capsule()
                    .fill(StudioTheme.mustard)
                    .frame(maxWidth: 190, minHeight: 5, maxHeight: 5)
                    .rotationEffect(.degrees(-1.2))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: dismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(StudioTheme.paperInk)
                    .frame(width: 44, height: 44)
                    .background(StudioTheme.paperHighlight, in: Circle())
                    .overlay { Circle().stroke(StudioTheme.paperInk, lineWidth: 2) }
                    .shadow(color: StudioTheme.paperInk.opacity(0.10), radius: 3, x: 1, y: 2)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(copy("settings.close", fallback: "Close settings"))
        }
    }

    private var playerSettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(copy("settings.players.title", fallback: "Players"))
                .font(StudioTypography.paperTitle)
                .foregroundStyle(StudioTheme.paperInk)
                .textCase(.uppercase)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            playerNameField(
                number: "1",
                title: copy("player.one", fallback: "Player 1"),
                text: $playerOneName,
                accent: StudioTheme.olive
            )
            playerNameField(
                number: "2",
                title: copy("player.two", fallback: "Player 2"),
                text: $playerTwoName,
                accent: StudioTheme.sky
            )
        }
    }

    private var languageSettings: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(copy("settings.language.label", fallback: "Language"))
                .font(StudioTypography.paperTitle)
                .foregroundStyle(StudioTheme.paperInk)
                .textCase(.uppercase)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            languageOption(
                .english,
                title: copy("settings.language.english", fallback: "English"),
                abbreviation: "EN",
                accent: StudioTheme.olive
            )
            languageOption(
                .ukrainian,
                title: copy("settings.language.ukrainian", fallback: "Ukrainian"),
                abbreviation: "UA",
                accent: StudioTheme.sky
            )
        }
    }

    private var tapeScrap: some View {
        TornPaperShape()
            .fill(StudioTheme.mustard.opacity(0.28))
            .frame(width: 62, height: 22)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    private func languageOption(
        _ language: AliasLanguage,
        title: String,
        abbreviation: String,
        accent: Color
    ) -> some View {
        let isSelected = selectedLanguage == language

        return Button {
            languageOverride = language.rawValue
        } label: {
            HStack(spacing: 12) {
                Text(abbreviation)
                    .font(StudioTypography.subheadline.weight(.bold))
                    .foregroundStyle(StudioTheme.paperInk)
                    .frame(width: 50, height: 40)
                    .background(TornPaperShape().fill(accent.opacity(0.88)))
                    .overlay {
                        TornPaperShape()
                            .stroke(StudioTheme.paperInk.opacity(0.62), lineWidth: 1.3)
                    }

                Text(title)
                    .font(StudioTypography.body.weight(.semibold))
                    .foregroundStyle(StudioTheme.paperInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .layoutPriority(1)

                Spacer()

                ZStack {
                    Circle()
                        .fill(StudioTheme.paperHighlight)
                    Circle()
                        .stroke(StudioTheme.paperInk, lineWidth: 2)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .black))
                            .foregroundStyle(StudioTheme.paperInk)
                    }
                }
                .frame(width: 32, height: 32)
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 62)
            .background {
                TornPaperShape()
                    .fill(isSelected ? accent.opacity(0.13) : StudioTheme.paperHighlight)
            }
            .overlay {
                TornPaperShape()
                    .stroke(StudioTheme.paperInk, lineWidth: 1.8)
            }
            .shadow(color: StudioTheme.paperInk.opacity(0.09), radius: 3, x: 1, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func playerNameField(
        number: String,
        title: String,
        text: Binding<String>,
        accent: Color
    ) -> some View {
        HStack(spacing: 12) {
            Text(number)
                .font(StudioTypography.paperControl)
                .foregroundStyle(StudioTheme.paperInk)
                .frame(width: 56, height: 56)
                .background(TornPaperShape().fill(accent.opacity(0.88)))
                .overlay {
                    TornPaperShape()
                        .stroke(StudioTheme.paperInk, lineWidth: 1.6)
                }

            TextField(copy("settings.player.placeholder", fallback: "Enter a name"), text: text)
                .font(StudioTypography.body)
                .foregroundStyle(StudioTheme.paperInk)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(TornPaperShape().fill(StudioTheme.paperHighlight))
                .overlay {
                    TornPaperShape()
                        .stroke(StudioTheme.paperInk, lineWidth: 1.7)
                }
                .accessibilityLabel(title)
        }
    }

    private func dismiss() {
        withAnimation(.snappy(duration: 0.28)) {
            isPresented = false
        }
    }

    private var sheetDragGesture: some Gesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .global)
            .onChanged { value in
                var transaction = Transaction(animation: nil)
                transaction.disablesAnimations = true

                withTransaction(transaction) {
                    sheetDragOffset = max(value.translation.height, 0)
                }
            }
            .onEnded { value in
                let shouldDismiss = value.translation.height > 72
                    || value.predictedEndTranslation.height > 110

                withAnimation(.snappy(duration: 0.24)) {
                    sheetDragOffset = 0
                    if shouldDismiss {
                        isPresented = false
                    }
                }
            }
    }

    private func resolvedSheetOffset(closedOffset: CGFloat) -> CGFloat {
        if isPresented {
            return min(sheetDragOffset, closedOffset)
        }

        return closedOffset
    }

    private func copy(_ key: String, fallback: String) -> String {
        aliasLocalized(key, fallback: fallback)
    }
}
