import SwiftUI

/// Renders the language choices without coupling the home screen to flag drawing details.
struct LanguageFlagView: View {
    let language: GuessWhoLanguage

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                switch language {
                case .english:
                    englishFlag(width: width, height: height)
                case .ukrainian:
                    ukrainianFlag(width: width, height: height)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            }
        }
    }

    private func ukrainianFlag(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 0) {
            Color(red: 0.10, green: 0.42, blue: 0.88)
            Color(red: 0.98, green: 0.83, blue: 0.20)
        }
        .frame(width: width, height: height)
    }

    @ViewBuilder
    private func englishFlag(width: CGFloat, height: CGFloat) -> some View {
        let diagonalLength = sqrt((width * width) + (height * height))

        ZStack {
            Color(red: 0.06, green: 0.20, blue: 0.53)
            Rectangle().fill(.white).frame(width: diagonalLength, height: height * 0.22).rotationEffect(.degrees(33))
            Rectangle().fill(.white).frame(width: diagonalLength, height: height * 0.22).rotationEffect(.degrees(-33))
            Rectangle().fill(Color(red: 0.79, green: 0.11, blue: 0.17)).frame(width: diagonalLength, height: height * 0.10).rotationEffect(.degrees(33))
            Rectangle().fill(Color(red: 0.79, green: 0.11, blue: 0.17)).frame(width: diagonalLength, height: height * 0.10).rotationEffect(.degrees(-33))
            Rectangle().fill(.white).frame(width: width, height: height * 0.34)
            Rectangle().fill(.white).frame(width: width * 0.28, height: height)
            Rectangle().fill(Color(red: 0.79, green: 0.11, blue: 0.17)).frame(width: width, height: height * 0.18)
            Rectangle().fill(Color(red: 0.79, green: 0.11, blue: 0.17)).frame(width: width * 0.14, height: height)
        }
    }
}
