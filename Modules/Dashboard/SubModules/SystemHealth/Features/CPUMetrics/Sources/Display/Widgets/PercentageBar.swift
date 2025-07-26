import SwiftUI

/// # Percentage Bar Widget
///
/// A reusable progress bar widget for displaying percentage values.
///
/// ## Overview
///
/// This widget can be used to display any percentage-based metric
/// with customizable colors and animations.
public struct PercentageBar: View {
    let value: Double
    let maxValue: Double
    let barColor: Color
    let backgroundColor: Color
    
    @State private var animatedValue: Double = 0
    
    public init(
        value: Double,
        maxValue: Double = 100,
        barColor: Color = .blue,
        backgroundColor: Color = Color.gray.opacity(0.2)
    ) {
        self.value = value
        self.maxValue = maxValue
        self.barColor = barColor
        self.backgroundColor = backgroundColor
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(backgroundColor)
                
                // Filled portion
                RoundedRectangle(cornerRadius: 4)
                    .fill(barColor)
                    .frame(width: geometry.size.width * CGFloat(animatedValue / maxValue))
                    .animation(.easeInOut(duration: 0.3), value: animatedValue)
            }
        }
        .frame(height: 8)
        .onAppear {
            animatedValue = value
        }
        .onChange(of: value) { newValue in
            animatedValue = newValue
        }
    }
}