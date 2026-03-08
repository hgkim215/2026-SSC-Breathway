import SwiftUI

struct DisclaimerView: View {
    let lines: [String]

    var body: some View {
        VStack(spacing: BW2Tokens.Space.x4) {
            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(BW2Tokens.Typography.caption13)
                    .foregroundStyle(BW2Tokens.ColorPalette.textOnImageSecondary)
                    .shadow(color: Color.black.opacity(0.45), radius: 2, y: 0.5)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(lines.joined(separator: " "))
    }
}

#Preview {
    DisclaimerView(lines: HomeViewData.mock.disclaimerLines)
        .padding()
        .background(Color.black.opacity(0.4))
}
