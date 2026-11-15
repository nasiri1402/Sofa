# Sofa Codex Release 1.2.1

Private release-candidate repository for the Sofa iOS app.

This repository is intentionally separate from the original developer repository
`nasiri1402/Sofa`. It contains the Codex-assisted onboarding, localization,
SwiftData migration, UI fixes, and the source used to build Sofa `1.2.1 (8)`.

## Open in Xcode

Open `Sofa.xcodeproj`, select the `Sofa` scheme, and use an iOS 17 or newer
destination.

## Data compatibility

The current SwiftData model preserves projects created by both the App Store
`1.2.0` schema and the TestFlight `1.2.1` schema during an app update.
