import SwiftUI

/// A compact, edge-swipable settings drawer for the Alias home screen.
struct AliasSettingsDrawer: View {
    @Binding var languageOverride: String
    @Binding var playerOneName: String
    @Binding var playerTwoName: String
    @Binding var isPresented: Bool
    @GestureState private var drawerDragTranslation: CGFloat = 0

    private let railWidth: CGFloat = 48

    private var selectedLanguage: AliasLanguage {
        AliasLanguage.resolved(override: languageOverride)
    }

    var body: some View {
        GeometryReader { geometry in
            let panelWidth = min(380, geometry.size.width * 0.92)
            let closedOffset = panelWidth - railWidth
            let drawerOffset = resolvedDrawerOffset(closedOffset: closedOffset)
            let drawerProgress = 1 - (drawerOffset / closedOffset)

            ZStack(alignment: .trailing) {
                Color.black.opacity(0.18 * drawerProgress)
                    .ignoresSafeArea()
                    .allowsHitTesting(isPresented || drawerDragTranslation < 0)
                    .onTapGesture(perform: dismiss)

                settingsPanel(
                    width: panelWidth,
                    closedOffset: closedOffset
                )
                .offset(x: drawerOffset)
            }
            .transaction { transaction in
                if drawerDragTranslation != 0 {
                    transaction.animation = nil
                }
            }
        }
    }

    private func settingsPanel(
        width: CGFloat,
        closedOffset: CGFloat
    ) -> some View {
        let contentWidth = width - railWidth

        return HStack(spacing: 0) {
            settingsRail
                .gesture(railGesture(closedOffset: closedOffset))

            settingsContent
                .padding(.horizontal, 22)
                .padding(.top, 28)
                .padding(.bottom, 24)
                .frame(width: contentWidth)
                .frame(maxHeight: .infinity, alignment: .top)
                .background(
                    StudioTheme.card,
                    in: UnevenRoundedRectangle(topLeadingRadius: 30, bottomLeadingRadius: 30)
                )
                .overlay(alignment: .leading) { Rectangle().fill(StudioTheme.line.opacity(0.7)).frame(width: 1) }
                .shadow(color: StudioTheme.shadowStrong, radius: 10, x: -4, y: 0)
                .compositingGroup()
                .simultaneousGesture(drawerDragGesture(closedOffset: closedOffset))
        }
        .frame(width: width)
        .frame(maxHeight: .infinity, alignment: .trailing)
    }

    private var settingsContent: some View {
        VStack(alignment: .leading, spacing: 28) {
            Text(copy("settings.title", fallback: "Settings"))
                .font(StudioTypography.title)
                .foregroundStyle(StudioTheme.ink)

            settingsCard {
                VStack(alignment: .leading, spacing: 14) {
                    Text(copy("settings.players.title", fallback: "Player names"))
                        .font(StudioTypography.label)
                        .foregroundStyle(StudioTheme.muted)

                    Text(copy("settings.players.message", fallback: "These names appear everywhere in the round flow."))
                        .font(StudioTypography.footnote)
                        .foregroundStyle(StudioTheme.muted)

                    playerNameField(
                        title: copy("player.one", fallback: "Player 1"),
                        text: $playerOneName,
                        accent: StudioTheme.teal
                    )
                    playerNameField(
                        title: copy("player.two", fallback: "Player 2"),
                        text: $playerTwoName,
                        accent: StudioTheme.coral
                    )
                }
            }

            settingsCard {
                VStack(alignment: .leading, spacing: 14) {
                    Text(copy("settings.language.label", fallback: "Language"))
                        .font(StudioTypography.label)
                        .foregroundStyle(StudioTheme.muted)

                    languageOption(.english, title: copy("settings.language.english", fallback: "English"))
                    languageOption(.ukrainian, title: copy("settings.language.ukrainian", fallback: "Ukrainian"))
                }
            }

            Spacer()
        }
    }

    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(18)
            .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(StudioTheme.line.opacity(0.8))
            }
    }

    private var settingsRail: some View {
        Text(copy("settings.title", fallback: "Settings"))
            .font(StudioTypography.label)
            .foregroundStyle(.white)
            .rotationEffect(.degrees(-90))
            .frame(width: 132, height: 48)
            .frame(width: railWidth)
            .frame(height: 132)
            .background(StudioTheme.coral, in: UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 20))
            .shadow(color: StudioTheme.shadowStrong, radius: 10, x: 0, y: 5)
            .contentShape(Rectangle())
            .accessibilityLabel(copy(isPresented ? "settings.close" : "settings.open", fallback: isPresented ? "Close settings" : "Open settings"))
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { toggleDrawer() }
            .frame(width: railWidth)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 72)
    }

    private func languageOption(_ language: AliasLanguage, title: String) -> some View {
        let isSelected = selectedLanguage == language

        return Button {
            languageOverride = language.rawValue
        } label: {
            HStack(spacing: 12) {
                LanguageFlagView(language: language)
                    .frame(width: 42, height: 28)

                Text(title)
                    .font(StudioTypography.body)
                    .foregroundStyle(StudioTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .layoutPriority(1)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isSelected ? StudioTheme.teal : StudioTheme.muted.opacity(0.55))
            }
            .padding(.horizontal, 14)
            .frame(height: 56)
            .background(isSelected ? StudioTheme.teal.opacity(0.10) : Color.white.opacity(0.46), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func playerNameField(
        title: String,
        text: Binding<String>,
        accent: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(StudioTypography.label)
                .foregroundStyle(StudioTheme.muted)

            TextField(copy("settings.player.placeholder", fallback: "Enter a name"), text: text)
                .font(StudioTypography.body)
                .foregroundStyle(StudioTheme.ink)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(accent.opacity(0.2), lineWidth: 1)
                }
        }
    }

    private func dismiss() {
        withAnimation(.snappy(duration: 0.28)) {
            isPresented = false
        }
    }

    private func toggleDrawer() {
        withAnimation(.easeInOut(duration: 0.45)) {
            isPresented.toggle()
        }
    }

    private func drawerDragGesture(closedOffset: CGFloat) -> some Gesture {
        // The tab moves while it is dragged, so measure the finger in a stable space.
        DragGesture(minimumDistance: 4, coordinateSpace: .global)
            .updating($drawerDragTranslation) { value, state, transaction in
                transaction.animation = nil
                state = value.translation.width
            }
            .onEnded { value in
                settleDrawer(after: value, closedOffset: closedOffset)
            }
    }

    private func railGesture(closedOffset: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .updating($drawerDragTranslation) { value, state, transaction in
                transaction.animation = nil
                state = value.translation.width
            }
            .onEnded { value in
                if abs(value.translation.width) < 8, abs(value.translation.height) < 8 {
                    toggleDrawer()
                } else {
                    settleDrawer(after: value, closedOffset: closedOffset)
                }
            }
    }

    private func settleDrawer(after value: DragGesture.Value, closedOffset: CGFloat) {
        let restingOffset = isPresented ? 0 : closedOffset
        let endingOffset = min(max(restingOffset + value.predictedEndTranslation.width, 0), closedOffset)
        isPresented = endingOffset < closedOffset / 2
    }

    private func resolvedDrawerOffset(closedOffset: CGFloat) -> CGFloat {
        let restingOffset = isPresented ? 0 : closedOffset
        return min(max(restingOffset + drawerDragTranslation, 0), closedOffset)
    }

    private func copy(_ key: String, fallback: String) -> String {
        aliasLocalized(key, fallback: fallback)
    }
}
