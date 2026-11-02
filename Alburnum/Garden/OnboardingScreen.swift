import SwiftUI

/// Three pages before the first garden. Skip and Start both mark onboarding complete.
struct OnboardingScreen: View {
    var onFinish: () async -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0
    @State private var finishing = false

    private let pages: [(image: String, title: String, line: String, label: String)] = [
        (
            "alb_Onboarding1",
            "Loose cash, one goal",
            "Type what you set aside. It stays on this phone until you season it into the trunk.",
            "Loose cash beside a trunk"
        ),
        (
            "alb_Onboarding2",
            "Season the outer band",
            "Waiting cash does not thicken the trunk. Season is the tap that saves it.",
            "A hand pressing the outer band into the trunk"
        ),
        (
            "alb_Onboarding3",
            "Watch the trunk grow",
            "Each season keeps the goal in sight. Plant the next one when this one is full.",
            "A thicker trunk after several seasons"
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            illustration
                .stagger(index: 0, reduce: reduceMotion)
            VStack(alignment: .leading, spacing: Spacing.s8) {
                Text(pages[page].title)
                    .font(TypeScale.face(.display))
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(3)
                Text(pages[page].line)
                    .font(TypeScale.face(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .lineSpacing(Spacing.s4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .narrowMeasure()
            .id(page)
            pageMarks
        }
        .padding(.horizontal, Spacing.s24)
        .padding(.top, Spacing.s32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: Spacing.s8) {
                Button(page == pages.count - 1 ? "Start" : "Next") {
                    advance()
                }
                .buttonStyle(CapsulePressStyle(role: .primary, isLoading: finishing))
                .disabled(finishing)
                Button("Skip") {
                    complete()
                }
                .buttonStyle(CapsulePressStyle(role: .secondary))
                .disabled(finishing)
            }
            .padding(.horizontal, Spacing.s24)
            .padding(.bottom, Spacing.s12)
        }
        .background(DesignTokens.bg.ignoresSafeArea())
        .animation(reduceMotion ? .easeOut(duration: 0.2) : Motion.spring, value: page)
    }

    private var illustration: some View {
        Image(pages[page].image)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(minHeight: Spacing.s48 * 4)
            .clipped()
            .accessibilityLabel(pages[page].label)
    }

    private var pageMarks: some View {
        HStack(spacing: Spacing.s8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Text(index == page ? "Now" : "\(index + 1)")
                    .font(TypeScale.face(.micro))
                    .foregroundStyle(index == page ? DesignTokens.surface : DesignTokens.ink)
                    .frame(minWidth: Metrics.hit, minHeight: Metrics.hit)
                    .background(index == page ? DesignTokens.accent : DesignTokens.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Metrics.chip, style: .continuous))
                    .accessibilityLabel(index == page ? "Page \(index + 1), now" : "Page \(index + 1)")
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func advance() {
        if page < pages.count - 1 {
            page += 1
        } else {
            complete()
        }
    }

    private func complete() {
        guard !finishing else { return }
        finishing = true
        Task {
            await onFinish()
            finishing = false
        }
    }
}
