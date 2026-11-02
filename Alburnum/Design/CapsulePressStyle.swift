import SwiftUI

struct RowPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.72 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(Motion.spring, value: configuration.isPressed)
    }
}

enum CapsuleRole {
    case primary
    case secondary
    case destructive
}

/// Filled capsule with pressed, disabled, and loading states. Primary is the only accent.
struct CapsulePressStyle: ButtonStyle {
    var role: CapsuleRole = .primary
    var isLoading: Bool = false

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && isEnabled && !isLoading
        return ZStack {
            configuration.label
                .font(TypeScale.face(.headline))
                .lineLimit(1)
                .opacity(isLoading ? 0 : 1)
            if isLoading {
                ProgressView()
                    .tint(foreground)
            }
        }
        .foregroundStyle(foreground)
        .frame(maxWidth: .infinity, minHeight: Metrics.hit)
        .padding(.horizontal, Spacing.s16)
        .background(fill(pressed: pressed))
        .clipShape(Capsule())
        .contentShape(Capsule())
        .scaleEffect(pressed ? 0.98 : 1)
        .opacity(pressed ? 0.88 : 1)
        .animation(Motion.spring, value: pressed)
    }

    private var foreground: Color {
        switch role {
        case .primary, .destructive:
            return isEnabled && !isLoading ? DesignTokens.surface : DesignTokens.ink
        case .secondary:
            return DesignTokens.ink
        }
    }

    private func fill(pressed: Bool) -> some ShapeStyle {
        if !isEnabled || isLoading {
            return AnyShapeStyle(DesignTokens.muted.opacity(0.35))
        }
        switch role {
        case .primary:
            return AnyShapeStyle(pressed ? DesignTokens.accent.opacity(0.82) : DesignTokens.accent)
        case .secondary:
            return AnyShapeStyle(DesignTokens.surface)
        case .destructive:
            return AnyShapeStyle(pressed ? DesignTokens.ink.opacity(0.82) : DesignTokens.ink)
        }
    }
}
