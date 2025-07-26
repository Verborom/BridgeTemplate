import SwiftUI

/// # Number Display Widget
///
/// A widget for displaying numeric values with units.
///
/// ## Overview
///
/// Provides animated number transitions and customizable formatting
/// for displaying metrics like percentages, temperatures, etc.
public struct NumberDisplay: View {
    let value: Double
    let unit: String
    let precision: Int
    let fontSize: Font
    
    @State private var displayValue: Double = 0
    
    public init(
        value: Double,
        unit: String = "",
        precision: Int = 0,
        fontSize: Font = .title2
    ) {
        self.value = value
        self.unit = unit
        self.precision = precision
        self.fontSize = fontSize
    }
    
    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(formattedValue)
                .font(fontSize)
                .fontWeight(.semibold)
                .contentTransition(.numericText())
            
            if !unit.isEmpty {
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                displayValue = value
            }
        }
        .onChange(of: value) { newValue in
            withAnimation(.easeInOut(duration: 0.3)) {
                displayValue = newValue
            }
        }
    }
    
    private var formattedValue: String {
        if precision == 0 {
            return "\(Int(displayValue))"
        } else {
            return String(format: "%.\(precision)f", displayValue)
        }
    }
}