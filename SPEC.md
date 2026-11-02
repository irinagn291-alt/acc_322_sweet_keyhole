# Alburnum — Build Specification

> Portfolio app 384, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Save loose cash by hand toward one goal and grow the trunk when you commit the filled ring.

| Field | Value |
| --- | --- |
| Product name | Alburnum |
| Bundle identifier | `com.alburnum.pith` |
| Domain | https://alburnum-pith.space |
| Contact URL | https://alburnum-pith.space/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone (portrait, landscape left, landscape right) and iPad (all orientations) |
| Interface style | Light |
| Asset prefix | `alb_` |
| User-Agent | `Alburnum/1.0 (iOS; +https://alburnum-pith.space)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Alburnum -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A cash saver wedges each hand deposit into the sapwood ring and seasons the ring so heartwood thickens only when the outer ring is committed.

### 2.1 User flow

1. On Garden, tap Season to commit the filled sapwood ring into heartwood toward the target.
2. Tap Wedge and enter a cash amount; the outer sapwood ring fills while trunk girth stays fixed.
3. Peel removes the last wedge from SapRing if the amount was wrong.
4. Open the Analytics sheet to read SeasonMark timeline and wedge-to-season stats.
5. Plant a new goal name and target on the pith when the current goal is Ripe.
6. In Settings, set currency, export marks CSV, or reset all data.

### 2.2 Essential behaviour

- Garden-root cross-section trunk with SapRing visualization and fused Wedge, Season, and Peel controls.
- Heartwood total versus target with quartile wire markers.
- Append-only WedgeMark and SeasonMark history keyed by YYYYMMDD daykey.
- Analytics sheet with monthly season counts and sap ring size at commit.
- Simulator-only seed with two wedges in SapRing so Season is the first live verb.
- Local UserDefaults+Codable persistence with debounced saves and no network APIs.

---

## 3. Uniqueness assignment for Alburnum

| Axis | Assigned value |
| --- | --- |
| Architecture | **Sapwood ADT fold (Bare | Wedged | Seasoned); the pith is a fold over WedgeMarks; Wedge appends amount to SapRing and folds Bare to Wedged; Season writes SeasonMark when SapRing is positive, transfers SapRing into Heartwood, clears SapRing, and folds Wedged to Seasoned then Bare unless Ripe; Season on Bare or empty SapRing writes HollowMark; Wedge on Ripe writes RipeMark; Peel removes the last WedgeMark from SapRing only; an unstaked pith writes Blank** |
| UI approach | **SwiftUI SceneKit integration · cce46b1b23** |
| Naming convention | **Espalier / sapwood ring lexicon (Pith, Goal, SapRing, WedgeMark, SeasonMark, Heartwood, HollowMark, RipeMark, Peel, Wire)** |
| File organization | **By sapwood role (Pith, Goal, SapRing, WedgeMark, SeasonMark, Heartwood, HollowMark, RipeMark, Wire, Peel)** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **dithered · editorial-stack · soft** |
| Typography | **Bradley Hand** |
| Navigation pattern | **Pith-locked chrome (the trunk cross-section and sapwood ring never leave; Analytics and Settings arrive as sheets; wedge and season fuse on Garden; no tab bar)** |
| AI art style | **Sumi-e ink wash · collage** |
| Functional twist | **Wedge-then-season (wedge fills sapwood; season commits the ring into heartwood; unwedged cash never thickens the trunk)** |
| Persistence | **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — savings_vine

**Core** — A cash saver wedges each hand deposit into the sapwood ring and seasons the ring so heartwood thickens only when the outer ring is committed.

**Audience** — People who save loose cash toward one named goal and want the plant to move on deliberate season commits, not on every typed amount or a bank feed.

**User flow**

1. On Garden, tap Season to commit the filled sapwood ring into heartwood toward the target.
2. Tap Wedge and enter a cash amount; the outer sapwood ring fills while trunk girth stays fixed.
3. Peel removes the last wedge from SapRing if the amount was wrong.
4. Open the Analytics sheet to read SeasonMark timeline and wedge-to-season stats.
5. Plant a new goal name and target on the pith when the current goal is Ripe.
6. In Settings, set currency, export marks CSV, or reset all data.

**Essential features**

- Garden-root cross-section trunk with SapRing visualization and fused Wedge, Season, and Peel controls.
- Heartwood total versus target with quartile wire markers.
- Append-only WedgeMark and SeasonMark history keyed by YYYYMMDD daykey.
- Analytics sheet with monthly season counts and sap ring size at commit.
- Simulator-only seed with two wedges in SapRing so Season is the first live verb.
- Local UserDefaults+Codable persistence with debounced saves and no network APIs.

**Twist** — Wedge-then-season fold (Bare | Wedged | Seasoned). Home is the pith cross-section. Wedge writes WedgeMark, adds to SapRing, and folds Bare to Wedged; Heartwood and trunk radius do not move. Season writes SeasonMark, transfers the entire SapRing into Heartwood, clears SapRing, animates one growth pulse, and folds toward Ripe or back to Bare. Season on Bare or empty SapRing writes HollowMark and is refused — unit tests must reject this. Wedge on Ripe writes RipeMark and is refused. Peel removes only the last WedgeMark from SapRing; Heartwood never decreases. Simulator seed holds two WedgeMarks in SapRing so the opening tap is Season. Home verb: season-the-ring — not pinch-the-leader, clip-the-rung, fuse-the-beads, or set-the-canopy.

**Why this is not a repeat** — Fifth savings_vine mechanic: sapwood buffer plus season commit, not Palmette flush-pinch, Batten pool-clip, Hopcrown spool-fuse, or Cordon tray-set. Home is season-the-ring after seed, not a balance sheet or browse catalog.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Garden of vines. Manual add grows them.
- Invariant: progress = current/target. Milestones 0.25/0.5/0.75/1.0. vineSeed drives branch shape. Manual only — no bank.
- Never: No Plot / GardenGame tab.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

The pith is a sapwood fold, Blank | Bare | Wedged | Seasoned | Ripe, over the WedgeMarks held in SapRing. Wedge appends a positive cash amount as a WedgeMark, adds it to SapRing, and folds Bare to Wedged, while Heartwood and the trunk radius stay fixed, and a zero or negative amount appends nothing. Season, when SapRing is positive, writes a SeasonMark, transfers the entire SapRing into Heartwood, clears SapRing, and folds Wedged to Seasoned, then to Bare, or to Ripe when Heartwood divided by the Goal target reaches 1. Season on Bare or on an empty SapRing writes HollowMark and is refused, and Wedge on Ripe writes RipeMark and is refused. Peel removes only the last WedgeMark from SapRing and appends nothing when SapRing is empty, Heartwood never decreases, and an unstaked pith with no Goal writes Blank. Progress equals Heartwood divided by the target, Wire marks the milestones at 0.25/0.5/0.75/1.0, and the Goal vineSeed drives the ring shape.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

The ui approach is SwiftUI SceneKit integration, and the axis token is never a visible label. GardenTrunkView is a UIViewRepresentable around one SCNView, the only custom-rendered surface, with allowsCameraControl off and the scene background set to DesignTokens.bg so the safe area stays filled. The root background is the same token. The heartwood disc, the sapwood annulus, and four quartile wire arcs share that scene, and the hero shading is a dither of the existing tokens, not a glossy or glass render. Swift Charts draws the heartwood arc as a stock chart on Garden, not as a second custom renderer. The live metric is the heartwood total, and it uses a numeric content transition, .contentTransition(.numericText()), so the figure rolls when Season commits. The sap-ring cash figure uses that same numeric content transition while the person types or drags. The one haptic is .sensoryFeedback(.impact), and the one commit that triggers it is a successful Season. Wedge, Peel, sheet navigation, and a refused Season stay silent. The one gesture that shows live feedback is a DragGesture on the sapwood band: the annulus thickness and the cash figure follow the finger, and lifting the finger does not write a WedgeMark. Season, Wedge, Peel, and Plant are Button controls. Season uses the filled-capsule button style with default, pressed, disabled, and loading states, and it is the only accent. The Wedge button commits a typed or previewed positive amount. Season transfers only the persisted SapRing. A successful Season plays one growth pulse on the disc. Reduce Motion fades that pulse and reveals the garden group at once. Otherwise grouped reveals step 40 to 60 milliseconds and finish within 360 milliseconds. Visible phase words are Ring is clear, Ready to season, and This goal is ripe. A refused Season says the ring is empty and points to Wedge. A refused Wedge on a ripe goal points to Plant. Quartile wires carry text as well as position. Icon-only controls have VoiceOver labels. Close has a text label. Clipping applies only to the framed trunk, never to the goal name or an amount. Garden is an editorial stack, narrow type then wide trunk, one full-width hairline, then the strip, with outer padding larger than the strip gaps. It is one hero, not three equal cards, and sibling blocks do not overlap. Lists use a bottom content margin. On iPad the trunk uses the width. Analytics, Settings, Plant, Currency, Export, and Ripe are stock stacks.

### 3.3 Naming contract

Convention: Espalier / sapwood ring lexicon (Pith, Goal, SapRing, WedgeMark, SeasonMark, Heartwood, HollowMark, RipeMark, Peel, Wire).

Examples to follow: `Pith.wedge(amount:daykey:)` appends a WedgeMark and folds Bare to Wedged. `Pith.season(daykey:)` writes a SeasonMark when SapRing is positive. `Pith.peel()` drops only the last WedgeMark. `Goal.vineSeed` and `Wire.quartiles` keep the ring shape and the four milestones.

### 3.4 Dependency contract

Zero external dependencies. project.yml has no packages key. There is no SPM entry, no CocoaPods, and no vendored source. The linked system frameworks are SwiftUI, Foundation, UIKit to host the trunk, SceneKit for the one Garden hero, Swift Charts for the heartwood arc, and Core Graphics for hairline rules. Do not import AVFoundation or Vision, and do not call URLSession.

### 3.5 Navigation contract

Chrome is pith-locked. Garden is the root and has no back button. The trunk cross-section and the sapwood ring never leave Garden. There is no tab bar and no GardenGame destination. Analytics, Settings, Plant, Currency, Export, and Ripe arrive as sheets, each dismissed with Close on its own stack. Wedge, Season, and Peel fuse on the Garden strip. Season is the accent filled capsule. Peel is a secondary control. Reset uses the destructive style and asks Erase this garden? and states that goals and cash on this device will be deleted. The contact row is a link to https://alburnum-pith.space/contact-us, not a web view. navigationTitle is the goal name, never the product name. Sheets use the 18pt radius and material elevation, and chips use 8pt. Every control is at least 44pt, and the whole label is the hit target with contentShape. The launch argument is read once after onboarding. today stays on Garden, log presents Analytics, and goals presents Plant. settings, currency, export, and ripe present those sheets. garden, analytics, and plant present the same three destinations.

### 3.6 Screen composition contract

Garden-root fused pith (Garden holds cross-section trunk, SapRing band, Swift Charts heartwood arc, and fused wedge-season strip; Analytics and Settings as sheets; no tab bar and no pushed deposit ledger)

Physical screens: Settings, Currency, Export, Ripe, Analytics, Plant, Garden.
Garden is the root. It holds the SceneKit trunk, the sapwood band, the Swift Charts heartwood arc, the quartile wires, the goal name, and the fused Wedge, Season, and Peel strip. The trunk uses the remaining height. The goal name keeps its height with fixedSize on the vertical axis. The Season capsule sits full width in the bottom strip. Analytics is a sheet whose top is a monthly count chart and whose lower part is the commit timeline, including the sap ring size at each commit. Its empty state fills the sheet with the line No seasons yet and the line Commit a ring on Garden to see it here. Settings is a short form for the currency row, the export row, reset, the contact link https://alburnum-pith.space/contact-us, and re-running onboarding. Plant is the sheet for a goal name and a target. The goals key opens Plant already filled with the seeded name and target. When nothing is planted, Garden itself is the full-page empty state, frame maxHeight infinity, with the empty cutout, the headline The garden is empty, the line Plant your first goal, and a full-width Plant capsule at the bottom. Currency is a full-height local list of currency names with one selected row, and it is not the settings form. Export is a column of commit rows with date, kind, and amount, plus a full-width Save capsule that shares a file through ShareLink, and it is not the settings form. Its empty state fills the sheet and says Nothing to save yet. Season a ring first. Ripe is a full page, not the garden strip: TwistHero is the cutout, the trunk reads full, the ring is clear, the headline is This goal is ripe, and the bottom capsule is Plant. The ripe key draws that layout in memory and does not write the Chart, so the saved pith stays Wedged. There is no tab bar and no pushed deposit ledger. The today key opens seeded Garden with Season enabled. The log key opens Analytics. The goals key opens Plant. The settings, currency, export, and ripe keys open those destinations. today, log, and goals are three different frames, and settings, currency, export, and ripe are different again. Onboarding is three pages using the three onboarding cutouts, with Next full width at the bottom. The simulator seed marks onboarding complete so the launch hook can run. A device install does not seed, so the first real launch can show the empty garden.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By sapwood role (Pith, Goal, SapRing, WedgeMark, SeasonMark, Heartwood, HollowMark, RipeMark, Wire, Peel)**

```
Alburnum/
  Pith/Pith.swift
Pith/Chart.swift
Pith/ChartStore.swift
Goal/Goal.swift
SapRing/SapRing.swift
WedgeMark/WedgeMark.swift
SeasonMark/SeasonMark.swift
Heartwood/Heartwood.swift
HollowMark/HollowMark.swift
RipeMark/RipeMark.swift
Wire/Wire.swift
Peel/Peel.swift
Garden/GardenScreen.swift
Garden/GardenTrunkView.swift
Analytics/AnalyticsScreen.swift
Settings/SettingsScreen.swift
Plant/PlantScreen.swift
Currency/CurrencyScreen.swift
Export/ExportScreen.swift
Ripe/RipeScreen.swift
Design/TypeScale.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Garden
A first-class screen for **Garden**. Must render empty, populated and error states.

### 5.3 Analytics
A first-class screen for **Analytics**. Must render empty, populated and error states.

### 5.4 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.5 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.6 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **SavingGoal** — named per this app's convention.
- **Contribution** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **dithered · editorial-stack · soft**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#F4F6FA` | Screen background |
| `surface` | `#FDFEFE` | Cards, rows, sheets |
| `ink` | `#182239` | Primary text and icons |
| `accent` | `#2855BD` | Primary action, key figure, progress fill |
| `muted` | `#5E6C8D` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Alburnum/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Bradley Hand**

Soft rounded UI type, one playful moment, no serif. Reference type feel: agency. Bradley Hand is the only family. The accessor uses Font.custom with the system face BradleyHandITCTT-Bold, sized with relativeTo, and DesignTokens.fontFamily stays Bradley Hand. The playful moment is the goal name at the display step, one or two short lines, wide, with the rest of the screen quiet. The scale has six steps behind that one accessor: display, title, headline, body, caption, and micro. Body is the 17pt step with generous leading on the narrow editorial measure. Hierarchy is size, because this face has one weight. Amounts and counts use Text with FormatStyle, currency for cash and number precision fractionLength 0...2, never NumberFormatter and never String(format:). Day edges use Calendar.current.startOfDay, then an Int in YYYYMMDD form. Dynamic Type and ScaledMetric keep the goal name fully visible at the largest size by stepping down, and display type uses fixedSize on the vertical axis so the trunk cannot compress it.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **18pt** for cards, sheets and primary surfaces; **8pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **material** — SwiftUI `Material` (`.regularMaterial` / `.thinMaterial`), reused everywhere a surface sits above another.

Primary control: **filled capsule** — the primary CTA is a full-width filled `Capsule`, never a bare text link or a plain `.plain` button.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI SceneKit integration · cce46b1b23**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI SceneKit integration · cce46b1b23** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **agency** (High-end agency: huge type, air, one accent, hairline depth.)

Reference system: **dithered** — steal rhythm and restraint, not their colours or logos.

Mood: **Dot-pattern rendering technique that simulates shades with a limited palette for nostalgic, retro, high-contrast visuals.**.

Home rhythm (`editorial-stack`, airy): Narrow measure for prose, wide for media. Rules, not boxes.

High-end agency: huge type, air, one accent, hairline depth. Layout `editorial-stack`, density airy. Kit 18/8, material, filled capsule. Palette recipe `soft`. Grouped reveals step 40-60ms, cap 360ms total. Last item must not arrive late. Reduce Motion: the group appears at once. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Soft rounded UI type, one playful moment, no serif. Reference type feel: agency.

Motion (`stagger`): Grouped reveals step 40-60ms, cap 360ms total. Last item must not arrive late. Reduce Motion: the group appears at once.

Voice (`warm`): Human and brief. Empty states invite. Errors stay calm and useful.

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- iPhone allows portrait, landscape left, and landscape right. iPad allows all
  four orientations. Keep both lists in the Info settings, and let a rotated
  screen scroll instead of clipping.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Every headline, amount, and button title is fully visible. Do not give display
  type a fixed height shorter than the font, and do not let a sibling with
  `maxHeight: .infinity` compress it. When the column is taller than the screen,
  scroll it. `.clipped()` frames an image cell; it never wraps text.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Spacing uses a base of 4: 4, 8, 12, 16, 20, 24, 32, 40, 48, in one `Spacing`
  enum next to `DesignTokens`. No other values.

**Keyboard**

- Decimal fields use `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with a `FormatStyle`, never `NumberFormatter` or
  `String(format:)`. Example:
  `Text(value, format: .number.precision(.fractionLength(0...1)))`.
  Group separators and decimal separators follow the locale.
- Whole units show no decimals. Measured values show at most one decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown values render as a dash or the word "unknown", never as 0.
- A changing metric uses `.contentTransition(.numericText(value:))` with the
  shared spring, on the same value the text shows.
- A custom drag, magnification, or rotation shows its in-flight value through
  `@GestureState` and `.updating`. The committed value changes in `.onEnded`.
- Loading rows use `.redacted(reason: .placeholder)` at the size they will have
  when the data arrives.
- A form with more than one field chains focus with an `@FocusState` enum.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- State changes use one shared spring token. A `PhaseAnimator` or
  `KeyframeAnimator` is only the single signature moment on a view, triggered
  by a value, never a loop on appear.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- The root screen has no back button. `.navigationTitle` is a screen name, never
  the product name. A back control titled with the app name is a defect: it
  reads as a button that returns to this same app.
- A sheet dismisses with Close and owns its stack. Do not push it onto a stack
  whose title is the product name.
- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- A ring or a gauge uses the same `lineWidth` for the track and the fill.
- Display type does not use `.minimumScaleFactor`. Adapt with `ViewThatFits`
  or `dynamicTypeSize.isAccessibilitySize`, and scroll the column.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.
- An actor method re-checks its state after every `await`. Do not force-unwrap
  a lookup that happened before the await. The value may be gone.
- Filter `CancellationError` out before showing error UI or retrying.
  Cancellation is a normal end, not a failure.
- Build streams with `AsyncStream.makeStream(of:)` or the throwing variant.
  Pass a bounded `bufferingPolicy`, and set `onTermination` so the producer
  stops when the consumer does.
- CPU work uses `@concurrent`. Do not run it on `@MainActor`. The scaffold does
  not turn on default main-actor isolation, so UI types still need an explicit
  `@MainActor`.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark**

UserDefaults stores one Codable Chart root as JSON under the single key alb.chart.v1, with schemaVersion starting at 1. Chart holds five storage slots, which are not a second lexicon and never appear in the interface. Islands hold Goal values, including name, target, vineSeed, and currency code. Books hold SeasonMark values. Sessions hold the live SapRing as WedgeMark values. Runs hold one Heartwood total per Goal, and that total moves only upward. Rhumbs hold HollowMark and RipeMark refusals, each with a daykey, and RipeMark also keeps the refused amount. Cash amounts are Decimal values encoded as strings. Each mark stores an Int daykey in YYYYMMDD form taken from Calendar.current.startOfDay. Swift types stay Pith, Goal, SapRing, WedgeMark, SeasonMark, Heartwood, HollowMark, RipeMark, Wire, and Peel. Pith phase is derived: no Goal means Blank, heartwood at the target means Ripe, a positive SapRing means Wedged, and otherwise Bare. Seasoned is the in-memory moment of a successful Season before the pith settles to Bare or Ripe. Wire positions and progress are derived, not stored. Each accepted mark schedules one debounced save of about 400 milliseconds. The store flushes when scenePhase becomes inactive or background, and it flushes immediately after reset. The previous JSON is copied to alb.chart.v1.bak before replace. Decode failure restores the backup, then an empty Blank pith, and tells the person the saved garden could not be read and a fresh garden is ready. The in-memory Chart is the source of truth, so a failed write does not show a mark that was not stored. Encode and save run off the main actor. Views never touch UserDefaults. resetAllData deletes both keys and is reachable from Settings. The Simulator seed runs once behind alb.demo.v1, guarded by targetEnvironment simulator, marks onboarding complete, and never runs on a device. It writes Goal Field coat with target 240, vineSeed 17, and currency USD, Heartwood 80 from SeasonMarks of 30 on 20260312 and 50 on 20260802, and two WedgeMarks of 18 and 27 in SapRing on 20261025, so the pith is Wedged, progress is below the target, and Season is enabled.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Alburnum/1.0 (iOS; +https://alburnum-pith.space)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.
No scanner and no remote catalog in this product. Do not import AVFoundation or Vision for capture, do not add a camera usage description, and do not call a search endpoint. Ignore a leftover scanner or search axis.


---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- iPhone: portrait, landscape left, landscape right. iPad: all four orientations (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.finance`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Light
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.finance
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Wedge-then-season (wedge fills sapwood; season commits the ring into heartwood; unwedged cash never thickens the trunk)

The home verb is season-the-ring, because a wedge only fills sapwood, unwedged cash never thickens the trunk, and amounts are typed by hand with no bank feed. The Simulator seed behind demo_seed_key writes two WedgeMarks into SapRing and leaves the pith Wedged, so the opening tap is Season and that verb is already enabled. Season writes a SeasonMark, moves the whole SapRing into Heartwood, clears the ring, plays one growth pulse, and folds Seasoned back to Bare unless the goal is Ripe. Unit tests must reject the refusal of Season on Bare or on an empty SapRing, which writes HollowMark and leaves the fold where it was. Wedge on Ripe writes RipeMark and is refused, and Peel never reduces Heartwood.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Sumi-e ink wash · collage**


Base prompt, reused and extended for every asset:

```
Sumi-e ink wash collage. A few wet brush strokes, wash blooming where it pools, torn collage layers, and a wide empty ground. One solid opaque subject sits in the center, wood or a closed trunk slice. Not a hollow ring, not glass, not a wire frame, not a clay render, not a photograph, no letters, no emoji.
```

All 5 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `alb_` prefix.

### 13.1 App icon

Do not generate an app icon. Do not create an AppIcon image set and do not
paint icon artwork. The factory installs the icon later. Leave the empty
AppIcon.appiconset from the scaffold untouched.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `alb_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 2 | `alb_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 3 | `alb_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 4 | `alb_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 5 | `alb_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Wedge-then-season (wedge fills sapwood; season commits the ring into heartwood; unwedged cash never thickens the trunk)' feature screen. |

### Prompt per asset

**`alb_Onboarding1`** — 1024x1536

```
A hand placing loose cash beside a small solid trunk slice, sumi-e ink wash collage, subjects opaque and centered. Not glass, not a hollow ring, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`alb_Onboarding2`** — 1024x1536

```
A hand pressing a filled outer wood band into the trunk core, mid gesture, sumi-e ink wash collage, solid opaque forms. Not glass, not a hollow ring, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`alb_Onboarding3`** — 1024x1536

```
A thicker solid trunk after several committed bands, calm, sumi-e ink wash collage, opaque and centered. Not a hollow ring, not glass, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`alb_EmptyHome`** — 1024x1024

```
A solid closed wooden bowl, fully opaque and centered, sumi-e ink wash with a few torn collage layers. Calm and unused. Not glass, not a hollow ring, not a wire frame, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`alb_TwistHero`** — 1024x1024

```
A solid trunk slice with a thick outer band, fully opaque and centered, sumi-e ink wash collage. The signature of committing the outer band into the core. Not a hollow ring, not glass, not a wire outline, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`alb.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.
- `AnyView`, or a `View.if` helper that applies modifiers conditionally.
- `Binding(get:set:)` built inline inside `body`.
- `GeometryReader` inside a lazy stack or a lazy grid.
- `@AppStorage` on an `@Observable` class. `@Query` outside a `View`.
- `MagnificationGesture` or `RotationGesture`. Use `MagnifyGesture` and
  `RotateGesture`.
- `String(format:)` or `NumberFormatter` for a number the UI shows. Use a
  `FormatStyle` on `Text`.


---

## 17. Tests

Add a unit test target `AlburnumTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Alburnum/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Alburnum -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.
- [ ] Do not add a watchOS app target. Apple Watch store images are fitted from the iPhone screenshots.

**Uniqueness**
- [ ] Architecture matches **Sapwood ADT fold (Bare | Wedged | Seasoned); the pith is a fold over WedgeMarks; Wedge appends amount to SapRing and folds Bare to Wedged; Season writes SeasonMark when SapRing is positive, transfers SapRing into Heartwood, clears SapRing, and folds Wedged to Seasoned then Bare unless Ripe; Season on Bare or empty SapRing writes HollowMark; Wedge on Ripe writes RipeMark; Peel removes the last WedgeMark from SapRing only; an unstaked pith writes Blank** with no leakage across layers.
- [ ] UI approach matches **SwiftUI SceneKit integration · cce46b1b23**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Pith-locked chrome (the trunk cross-section and sapwood ring never leave; Analytics and Settings arrive as sheets; wedge and season fuse on Garden; no tab bar)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Bradley Hand** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Alburnum
xcodegen generate
xcodebuild build-for-testing -scheme Alburnum -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling_factory/.artifacts/genesis/com.alburnum.pith/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Alburnum -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling_factory/.artifacts/genesis/com.alburnum.pith/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Alburnum -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling_factory/.artifacts/genesis/com.alburnum.pith/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
