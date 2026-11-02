import SwiftUI

/// In-memory full page for a ripe goal. It does not write the chart.
struct RipeScreen: View {
    var onPlant: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            Image("alb_TwistHero")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(minHeight: Spacing.s48 * 4)
                .clipped()
                .accessibilityLabel("Full trunk")
            Text("Trunk is full")
                .font(TypeScale.face(.title))
                .foregroundStyle(DesignTokens.accent)
                .fixedSize(horizontal: false, vertical: true)
            Text(GardenCopy.ringClear)
                .font(TypeScale.face(.headline))
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(GardenCopy.ripe)
                .font(TypeScale.face(.display))
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(3)
        }
        .padding(.horizontal, Spacing.s24)
        .padding(.top, Spacing.s24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) {
            Button("Plant", action: onPlant)
                .buttonStyle(CapsulePressStyle())
                .padding(.horizontal, Spacing.s24)
                .padding(.bottom, Spacing.s12)
        }
        .background(DesignTokens.bg.ignoresSafeArea())
    }
}
