import Charts
import SwiftUI

/// Garden is the root. The trunk stays here. Season commits the outer band. Wedge only fills it.
struct GardenScreen: View {
    @Bindable var session: GardenSession
    var ready: Bool
    var onPlant: () -> Void
    var onRetry: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicType
    @ScaledMetric(relativeTo: .largeTitle) private var nameBlock = Metrics.nameEstimate
    @ScaledMetric(relativeTo: .body) private var copyBlock = Metrics.copyEstimate
    @ScaledMetric(relativeTo: .body) private var figureBlock = Metrics.figureEstimate
    @ScaledMetric(relativeTo: .body) private var stripBlock = Metrics.stripEstimate

    @State private var amountText = ""
    @State private var seasoning = false
    @State private var pulse = 0
    @FocusState private var field: AmountField?
    @GestureState private var dragTranslation: CGFloat = 0

    private enum AmountField: Hashable {
        case amount
    }

    var body: some View {
        GeometryReader { proxy in
            if ready, session.pith.goal != nil {
                // Editorial stack: narrow type → wide trunk → hairline → fused strip.
                // Strip stays outside the scroll so Season / Wedge / Peel never leave the first frame.
                VStack(alignment: .leading, spacing: Spacing.s16) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: Spacing.s16) {
                            typeBlock
                                .stagger(index: 0, reduce: reduceMotion)
                            trunk(in: proxy.size)
                                .stagger(index: 1, reduce: reduceMotion)
                        }
                        .padding(.horizontal, Spacing.s24)
                        .padding(.top, Spacing.s12)
                        .frame(maxWidth: .infinity, alignment: .top)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    Hairline()
                        .padding(.horizontal, Spacing.s24)
                    strip
                        .stagger(index: 2, reduce: reduceMotion)
                        .padding(.horizontal, Spacing.s24)
                        .padding(.bottom, Spacing.s24)
                }
            } else {
                ScrollView {
                    if !ready {
                        holding(in: proxy.size)
                    } else {
                        empty(in: proxy.size)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .background(DesignTokens.bg.ignoresSafeArea())
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { field = nil }
                    .frame(minHeight: Metrics.hit)
            }
        }
    }

    private var typeBlock: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            header
            figure
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text(session.pith.goal?.name ?? "unknown")
                .font(TypeScale.face(dynamicType.isAccessibilitySize ? .headline : .display))
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(session.phaseCaption)
                .font(TypeScale.face(.title))
                .foregroundStyle(DesignTokens.accent)
                .fixedSize(horizontal: false, vertical: true)
            Text("Save toward this goal. Season moves waiting cash into the trunk.")
                .font(TypeScale.face(.body))
                .foregroundStyle(DesignTokens.ink)
                .lineSpacing(Spacing.s4)
                .fixedSize(horizontal: false, vertical: true)
                .narrowMeasure()
            if let refusal = session.refusal {
                Text(refusal)
                    .font(TypeScale.face(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let notice = session.notice {
                VStack(alignment: .leading, spacing: Spacing.s8) {
                    Text(notice)
                        .font(TypeScale.face(.body))
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Button("Retry", action: onRetry)
                        .buttonStyle(CapsulePressStyle(role: .secondary))
                }
            }
        }
    }

    private var figure: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: Spacing.s16) {
                amounts
                arc
                    .frame(width: Spacing.s48 * 3, height: Spacing.s48 * 2)
            }
            VStack(alignment: .leading, spacing: Spacing.s12) {
                amounts
                arc
                    .frame(maxWidth: .infinity)
                    .frame(height: Spacing.s48 * 2)
            }
        }
    }

    private var amounts: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text("In the trunk")
                .font(TypeScale.face(.caption))
                .foregroundStyle(DesignTokens.muted)
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: Spacing.s8) {
                    money(session.pith.heartwood.total, step: .title)
                        .foregroundStyle(DesignTokens.accent)
                    Text("of")
                        .font(TypeScale.face(.caption))
                        .foregroundStyle(DesignTokens.muted)
                    money(session.pith.goal?.target ?? 0, step: .headline)
                        .foregroundStyle(DesignTokens.ink)
                }
                VStack(alignment: .leading, spacing: Spacing.s4) {
                    money(session.pith.heartwood.total, step: .title)
                        .foregroundStyle(DesignTokens.accent)
                    money(session.pith.goal?.target ?? 0, step: .headline)
                        .foregroundStyle(DesignTokens.ink)
                }
            }
            Text(quartileLine)
                .font(TypeScale.face(.caption))
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(bandLabel)
                .font(TypeScale.face(.caption))
                .foregroundStyle(DesignTokens.muted)
            money(bandCash, step: .headline)
                .foregroundStyle(DesignTokens.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var arc: some View {
        Charts.Chart {
            SectorMark(angle: .value("Saved", savedNumber), innerRadius: .ratio(0.62))
                .foregroundStyle(DesignTokens.accent)
            if restNumber > 0.01 {
                SectorMark(angle: .value("Left", restNumber), innerRadius: .ratio(0.62))
                    .foregroundStyle(DesignTokens.muted.opacity(0.35))
            }
        }
        .chartLegend(.hidden)
        .accessibilityLabel("Saved share of the goal")
    }

    private func trunk(in size: CGSize) -> some View {
        let height = trunkHeight(in: size)
        return GardenTrunkView(
            saved: savedFraction,
            band: bandFraction,
            trying: tryingFraction,
            lobes: session.pith.goal?.ringLobes ?? 3,
            reached: session.wires.map(\.reached)
        )
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Trunk cross section")
        .accessibilityHint("Drag to try an amount. Lift keeps it in the field. Season saves only cash already added.")
        .highPriorityGesture(drag)
        .phaseAnimator([false, true, false], trigger: pulse) { view, hot in
            view
                .scaleEffect(!reduceMotion && hot && pulse > 0 ? 1.04 : 1)
                .opacity(reduceMotion && hot && pulse > 0 ? 0.72 : 1)
        } animation: { _ in
            reduceMotion ? .easeOut(duration: 0.18) : Motion.spring
        }
    }

    private var strip: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text("Wedge adds waiting cash. Season moves it into the trunk. Drop last undoes the latest add.")
                .font(TypeScale.face(.caption))
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            TextField("Amount", text: $amountText)
                .font(TypeScale.face(.body))
                .foregroundStyle(DesignTokens.ink)
                .keyboardType(.decimalPad)
                .focused($field, equals: .amount)
                .padding(.horizontal, Spacing.s16)
                .frame(minHeight: Metrics.hit)
                .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: Metrics.chip, style: .continuous))
                .onChange(of: amountText) { _, newValue in
                    let cleaned = CashField.sanitize(newValue)
                    if cleaned != newValue {
                        amountText = cleaned
                    }
                }
            if !amountText.isEmpty && CashField.parse(amountText) == nil {
                Text("Enter a number greater than zero.")
                    .font(TypeScale.face(.caption))
                    .foregroundStyle(DesignTokens.ink)
            }
            HStack(spacing: Spacing.s8) {
                Button("Wedge", action: commitWedge)
                    .buttonStyle(CapsulePressStyle(role: .secondary))
                    .disabled(CashField.parse(amountText) == nil || seasoning || session.pith.goal == nil)
                Button("Drop last", action: undoLast)
                    .buttonStyle(CapsulePressStyle(role: .secondary))
                    .disabled(session.pith.sapRing.isEmpty || seasoning)
            }
            Button("Season", action: commitSeason)
                .buttonStyle(CapsulePressStyle(role: .primary))
                .disabled(seasoning)
                .sensoryFeedback(.impact(weight: .medium, intensity: 0.9), trigger: pulse)
        }
        .padding(Spacing.s16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Metrics.card, style: .continuous))
    }

    private func holding(in size: CGSize) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            Text("Goal name")
                .font(TypeScale.face(.display))
                .fixedSize(horizontal: false, vertical: true)
            Text("Ready to season")
                .font(TypeScale.face(.title))
            RoundedRectangle(cornerRadius: Metrics.card, style: .continuous)
                .fill(DesignTokens.surface)
                .frame(height: trunkHeight(in: size))
            Hairline()
            Capsule()
                .fill(DesignTokens.muted.opacity(0.35))
                .frame(height: Metrics.hit)
        }
        .redacted(reason: .placeholder)
        .padding(.horizontal, Spacing.s24)
        .padding(.top, Spacing.s12)
        .frame(maxWidth: .infinity, minHeight: size.height, alignment: .top)
        .accessibilityLabel("Loading the garden")
    }

    private func empty(in size: CGSize) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            Image("alb_EmptyHome")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(minHeight: Spacing.s48 * 4)
                .clipped()
                .accessibilityLabel("A calm wooden bowl")
            Text("The garden is empty")
                .font(TypeScale.face(.display))
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Plant your first goal")
                .font(TypeScale.face(.body))
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            if let notice = session.notice {
                Text(notice)
                    .font(TypeScale.face(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Retry", action: onRetry)
                    .buttonStyle(CapsulePressStyle(role: .secondary))
            }
        }
        .padding(.horizontal, Spacing.s24)
        .padding(.top, Spacing.s16)
        .frame(maxWidth: .infinity, minHeight: size.height, alignment: .top)
        .safeAreaInset(edge: .bottom) {
            Button("Plant", action: onPlant)
                .buttonStyle(CapsulePressStyle())
                .padding(.horizontal, Spacing.s24)
                .padding(.bottom, Spacing.s12)
        }
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: Spacing.s4)
            .updating($dragTranslation) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                let amount = CashField.dragAmount(-value.translation.height)
                guard amount > 0 else { return }
                amountText = CashField.fieldText(amount)
            }
    }

    private var fingerAmount: Decimal {
        CashField.dragAmount(-dragTranslation)
    }

    /// Drag preview, typed amount, or the saved ring — rolls with numericText.
    private var bandCash: Decimal {
        if fingerAmount > 0 { return fingerAmount }
        if let typed = CashField.parse(amountText) { return typed }
        return session.pith.sapRing.total
    }

    private var bandLabel: String {
        if fingerAmount > 0 || CashField.parse(amountText) != nil {
            return "Trying"
        }
        return "Outer band"
    }

    private var currency: String {
        let code = session.pith.goal?.currencyCode ?? session.settings.currencyCode
        return code.isEmpty ? "USD" : code
    }

    private var savedFraction: CGFloat {
        CGFloat(NSDecimalNumber(decimal: min(max(session.progress, 0), 1)).doubleValue)
    }

    private var bandFraction: CGFloat {
        guard let target = session.pith.goal?.target, target > 0 else { return 0 }
        return CGFloat(NSDecimalNumber(decimal: session.pith.sapRing.total / target).doubleValue)
    }

    private var tryingFraction: CGFloat {
        guard let target = session.pith.goal?.target, target > 0 else { return 0 }
        let preview: Decimal
        if fingerAmount > 0 {
            preview = fingerAmount
        } else if let typed = CashField.parse(amountText) {
            preview = typed
        } else {
            preview = 0
        }
        let ratio = min(preview / target, 1)
        return CGFloat(NSDecimalNumber(decimal: ratio).doubleValue)
    }

    private var savedNumber: Double {
        NSDecimalNumber(decimal: min(max(session.progress, 0), 1)).doubleValue
    }

    private var restNumber: Double {
        max(0, 1 - savedNumber)
    }

    private var quartileLine: String {
        let names = ["Quarter", "Half", "Three quarters", "Full"]
        let wires = session.wires
        guard wires.count == names.count else { return "Quarter, half, three quarters, and full." }
        let reached = zip(names, wires).filter(\.1.reached).map(\.0)
        let ahead = zip(names, wires).filter { !$0.1.reached }.map(\.0)
        if reached.isEmpty {
            return "Quarter, half, three quarters, and full are still ahead."
        }
        if ahead.isEmpty {
            return "Quarter, half, three quarters, and full are reached."
        }
        return reached.joined(separator: ", ") + " reached. " + ahead.joined(separator: ", ") + " still ahead."
    }

    private func money(_ value: Decimal, step: TypeScale.Step) -> some View {
        Text(value, format: .currency(code: currency).precision(.fractionLength(0...2)))
            .font(TypeScale.face(step))
            .contentTransition(.numericText(value: NSDecimalNumber(decimal: value).doubleValue))
            .animation(Motion.spring, value: value)
            .lineLimit(1)
    }

    /// Trunk takes leftover height after type, hairline, and the fused strip.
    private func trunkHeight(in size: CGSize) -> CGFloat {
        let gaps = Spacing.s16 * 3
        let chrome = Spacing.s12 + Spacing.s24
        let used = nameBlock + copyBlock + figureBlock + stripBlock + Metrics.hairline + gaps + chrome
        return max(Spacing.s48 * 3, size.height - used)
    }

    private func commitSeason() {
        guard !seasoning else { return }
        seasoning = true
        let before = session.pith.seasons.count
        session.season(daykey: Daykey.make(from: Date()))
        if session.pith.seasons.count > before {
            pulse += 1
        }
        Task {
            try? await Task.sleep(for: .milliseconds(320))
            seasoning = false
        }
    }

    private func commitWedge() {
        guard !seasoning, let amount = CashField.parse(amountText) else { return }
        seasoning = true
        session.wedge(amount: amount, daykey: Daykey.make(from: Date()))
        amountText = ""
        Task {
            try? await Task.sleep(for: .milliseconds(180))
            seasoning = false
        }
    }

    private func undoLast() {
        guard !seasoning else { return }
        session.peel()
    }
}
