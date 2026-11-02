import SwiftUI
import UIKit

/// Spacing, radii, type, and the one spring. Views reach metrics through these accessors.
enum Spacing {
    static let s4: CGFloat = 4
    static let s8: CGFloat = 8
    static let s12: CGFloat = 12
    static let s16: CGFloat = 16
    static let s20: CGFloat = 20
    static let s24: CGFloat = 24
    static let s32: CGFloat = 32
    static let s40: CGFloat = 40
    static let s48: CGFloat = 48
}

enum Metrics {
    static let hairline: CGFloat = 1
    static let hit: CGFloat = 44
    static let card: CGFloat = 18
    static let chip: CGFloat = 8
    static let nameEstimate: CGFloat = 96
    static let copyEstimate: CGFloat = 120
    static let figureEstimate: CGFloat = 160
    static let stripEstimate: CGFloat = 192
    static let trunkFloor: CGFloat = 240
}

enum Motion {
    static let spring = Animation.spring(response: 0.32, dampingFraction: 0.86)
    static let step: Double = 0.05
    static let reveal: Double = 0.16
}

enum TypeScale {
    enum Step {
        case display
        case title
        case headline
        case body
        case caption
        case micro
    }

    static func face(_ step: Step) -> Font {
        switch step {
        case .display:
            Font.custom("BradleyHandITCTT-Bold", size: 40, relativeTo: .largeTitle)
        case .title:
            Font.custom("BradleyHandITCTT-Bold", size: 28, relativeTo: .title)
        case .headline:
            Font.custom("BradleyHandITCTT-Bold", size: 22, relativeTo: .headline)
        case .body:
            Font.custom("BradleyHandITCTT-Bold", size: 17, relativeTo: .body)
        case .caption:
            Font.custom("BradleyHandITCTT-Bold", size: 14, relativeTo: .caption)
        case .micro:
            Font.custom("BradleyHandITCTT-Bold", size: 12, relativeTo: .caption2)
        }
    }
}

struct NarrowMeasure: ViewModifier {
    func body(content: Content) -> some View {
        content
            .containerRelativeFrame(.horizontal, alignment: .leading) { width, _ in
                min(width * 0.84, Spacing.s48 * 9)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension View {
    func narrowMeasure() -> some View {
        modifier(NarrowMeasure())
    }
}

struct StaggerIn: ViewModifier {
    var index: Int
    var reduce: Bool
    @State private var shown: Bool

    init(index: Int, reduce: Bool) {
        self.index = index
        self.reduce = reduce
        _shown = State(initialValue: !UIView.areAnimationsEnabled)
    }

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown || reduce ? 0 : Spacing.s8)
            .onAppear {
                guard !shown else { return }
                if reduce {
                    withAnimation(.easeOut(duration: Motion.reveal)) {
                        shown = true
                    }
                } else {
                    let delay = min(Double(index) * Motion.step, 0.15)
                    withAnimation(.easeOut(duration: Motion.reveal).delay(delay)) {
                        shown = true
                    }
                }
            }
    }
}

extension View {
    func stagger(index: Int, reduce: Bool) -> some View {
        modifier(StaggerIn(index: index, reduce: reduce))
    }
}
