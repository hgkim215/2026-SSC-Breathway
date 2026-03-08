import SwiftUI

struct WeekCapsuleView: View {
    let days: [WeekDayProgress]

    var body: some View {
        let columnWidth: CGFloat = 120

        VStack(spacing: BW2Tokens.Space.x10) {
            HStack {
                ForEach(days) { day in
                    Text(day.label)
                        .font(.system(size: 14, weight: day.isToday ? .semibold : .regular))
                        .foregroundStyle(day.isToday ? BW2Tokens.ColorPalette.teal500 : BW2Tokens.ColorPalette.deep900)
                        .frame(width: columnWidth)
                }
            }

            HStack {
                ForEach(days) { day in
                    DayDotView(day: day)
                        .frame(width: columnWidth)
                }
            }
        }
        .padding(18)
        .bwLiquidGlass(
            cornerRadius: BW2Tokens.Radius.pill,
            strokeColor: BW2Tokens.ColorPalette.borderGlass
        )
        .accessibilityElement(children: .contain)
    }
}

private struct DayDotView: View {
    let day: WeekDayProgress

    var body: some View {
        let dotSize: CGFloat = day.isToday ? 28 : 18
        let completedFill = day.isToday ? BW2Tokens.ColorPalette.teal500 : BW2Tokens.ColorPalette.teal400

        Circle()
            .fill(day.isCompleted ? completedFill : Color.white.opacity(0.16))
            .overlay(
                Circle()
                    .stroke(strokeColor, lineWidth: day.isToday ? 3 : 1)
            )
            .frame(width: dotSize, height: dotSize)
            .accessibilityLabel("\(day.label), \(day.isToday ? "today" : "day"), \(day.isCompleted ? "completed" : "not completed")")
    }

    private var strokeColor: Color {
        if day.isToday {
            return day.isCompleted ? BW2Tokens.ColorPalette.borderOnImage : BW2Tokens.ColorPalette.teal500.opacity(0.92)
        }
        return day.isCompleted ? Color.clear : BW2Tokens.ColorPalette.borderOnImage.opacity(0.36)
    }
}

#Preview {
    WeekCapsuleView(days: HomeViewData.mock.weekDays)
        .padding()
        .background(Color.gray.opacity(0.2))
}
