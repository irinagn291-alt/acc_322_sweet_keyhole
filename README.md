# Alburnum

Alburnum is a cash saver for one named goal. You type loose cash by hand. It sits in the outer band until you season it. Only then does the trunk thicken toward the goal. It is for someone who wants the plant to move on a deliberate commit, not on every typed amount and not from a bank feed.

## Why a sapwood fold

The product is a buffer plus a commit, so the domain is a fold instead of a balance sheet. `Pith` is Blank, Bare, Wedged, Seasoned, or Ripe over the wedges held in the live band.

- Wedge appends a positive amount and folds Bare to Wedged. The trunk stays put. A zero or negative amount appends nothing. Wedge on a ripe goal writes a refusal and is ignored.
- Season, when the band holds cash, writes a commit, transfers the whole band into the trunk, clears the band, and passes through Seasoned before settling to Bare, or to Ripe when the trunk reaches the target. Season on Bare or on an empty band is refused and leaves the fold where it was.
- Undo last removes only the latest wedge. The trunk never decreases.
- With no goal, the pith stays Blank.
- Progress is trunk divided by the target. Quartile marks sit at 0.25, 0.5, 0.75, and 1. The goal's vine seed drives the band's lobe count. Those values are derived, not stored.

Seasoned is the in-memory moment of a successful season. The saved chart settles on Bare or Ripe so a relaunch does not replay the growth pulse.

Garden stays on screen. Commits, settings, the goal form, currency, a saved copy, and the ripe page arrive as sheets. There is no tab bar. The trunk cross-section never leaves Garden, because the job is the commit, not a ledger you browse.

## Why you would pick it

A wedge only fills the outer band. Uncommitted cash never thickens the trunk. Season is the home verb: it writes the commit, moves the whole band into the trunk, clears the band, and plays one growth pulse. The Simulator seed leaves two wedges in the band so Season is already enabled.

## Persistence

One chart root is JSON under `alb.chart.v1`, mirrored to an atomic file in Application Support. Cash is a decimal string. The previous payload is copied to `alb.chart.v1.bak` before replace. If the primary record cannot be decoded, the backup is read, then an empty garden, and the person is told a fresh garden is ready. Saves are debounced and flushed when the scene leaves the foreground, and immediately after reset. The in-memory pith is the source of truth: a failed write restores the last stored pith.

The Simulator seed runs once behind `alb.demo.v1` and marks onboarding complete. A device install does not seed.

## Screens

Garden is the cross-section: goal name, trunk, quartile words, and the fused Wedge, Undo last, and Season strip. Analytics, Settings, Plant, Currency, and Export are sheets dismissed with Close. The ripe page is a full-screen layout that does not write the chart. Onboarding is three pages. The launch argument `-ReviewScreen` is read once after onboarding: today stays on Garden, log opens commits, goals opens the planted goal, and settings, currency, export, and ripe open those pages.

## Art

Style: sumi-e ink wash collage. A few wet brush strokes, wash blooming where it pools, torn collage layers, and a wide empty ground. One solid opaque subject sits in the center, wood or a closed trunk slice. Not a hollow ring, not glass, not a wire frame, not a clay render, not a photograph, no letters, no emoji.

`alb_Onboarding1`: A hand placing loose cash beside a small solid trunk slice, sumi-e ink wash collage, subjects opaque and centered. Not glass, not a hollow ring, no letters.

`alb_Onboarding2`: A hand pressing a filled outer wood band into the trunk core, mid gesture, sumi-e ink wash collage, solid opaque forms. Not glass, not a hollow ring, no letters.

`alb_Onboarding3`: A thicker solid trunk after several committed bands, calm, sumi-e ink wash collage, opaque and centered. Not a hollow ring, not glass, no letters.

`alb_EmptyHome`: A solid closed wooden bowl, fully opaque and centered, sumi-e ink wash with a few torn collage layers. Calm and unused. Not glass, not a hollow ring, not a wire frame, no letters.

`alb_TwistHero`: A solid trunk slice with a thick outer band, fully opaque and centered, sumi-e ink wash collage. The signature of committing the outer band into the core. Not a hollow ring, not glass, not a wire outline, no letters.

Each cutout is an isolated solid subject on a transparent ground, centered, with the four corners clear.

## How this differs

This is a sapwood buffer plus a season commit. Home is season-the-ring after the seed, not a balance sheet, not a bank graph, and not a browse catalog.

## Build

```bash
cd Alburnum
xcodegen generate
xcodebuild build-for-testing -scheme Alburnum -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Alburnum -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
```

Signing flags stay on the command line. The project keeps automatic signing.
