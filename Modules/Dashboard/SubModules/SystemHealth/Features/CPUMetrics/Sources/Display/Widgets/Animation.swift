import SwiftUI

/// # CPU Animation Widget
///
/// Provides visual feedback for CPU activity.
///
/// ## Overview
///
/// This widget displays an animated indicator that responds to CPU usage levels,
/// providing immediate visual feedback about system activity.
public struct CPUAnimation: View {
    let isActive: Bool
    
    @State private var phase: CGFloat = 0
    
    public init(isActive: Bool) {
        self.isActive = isActive
    }
    
    public var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    AnimatedBar(
                        index: index,
                        phase: phase,
                        isActive: isActive,
                        height: geometry.size.height
                    )
                }
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
            phase = 1.0
        }
    }
}

struct AnimatedBar: View {
    let index: Int
    let phase: CGFloat
    let isActive: Bool
    let height: CGFloat
    
    private var delay: Double {
        Double(index) * 0.1
    }
    
    private var scale: CGFloat {
        guard isActive else { return 0.2 }
        
        let adjustedPhase = (phase + CGFloat(delay)).truncatingRemainder(dividingBy: 1.0)
        return 0.2 + 0.8 * sin(adjustedPhase * .pi)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(isActive ? Color.blue : Color.gray.opacity(0.3))
            .frame(height: height * scale)
            .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}