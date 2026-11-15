# SOFA — current Codex Release source

The working release branch is `codex/current-2026-11-15` in `nasiri1402/Sofa`.
The original `main` and `develop` branches and their history are preserved.
The inherited `README.md` is historical; use this document and `CODEX-RELEASE.json`
for this branch's current source status.

## Source and Apple builds

- Current source settings: **1.2.2 (11)**, bundle ID `com.ajdar.ai.sofa`.
- This branch includes the four fixes from November 14: authentication readiness
  and error handling, authoritative StoreKit display prices, country localization,
  and Dynamic Type in Settings and My Data.
- The previously uploaded Apple **1.2.2 (12)** predates those fixes. Its build number
  was supplied during the earlier archive operation. This Git synchronization is
  not a new build, TestFlight upload, App Review submission, or production release.
- `SOURCE-MANIFEST.json` records all **703 non-sensitive approved source inputs**.
  They are preserved byte for byte, including the historical README and scripts.
  The documentation and manifests added for this synchronization are separate.

## Verification limits

The earlier scoped QA was partial: the normal simulator generation flow failed
at Firebase authentication with HTTP 401; the exact cause remains unresolved.
Native purchase-price agreement was not verified because the Xcode UI timed out.
Passing source/model regressions and prior builds do not establish release readiness.
No product tests or builds were run during this Git synchronization.

All local simulators, runtimes and build outputs were removed at the owner's
request on November 15. **Do not recreate or download them automatically.**
New runtime work requires a new explicit owner request.

## Configuration and excluded artifacts

The pre-existing tracked `Sofa/Sources/Plists/GoogleService-Info.plist` entry is
inherited unchanged from `develop`. Its contents were not read, copied, compared,
or uploaded again. This isolated working checkout deliberately leaves that path
unmaterialized using sparse checkout; Git still retains its original tracked entry.
Its content is excluded from the 703-input verification claim.

Before any separately authorized runtime work, have the owner supply or validate
the appropriate Firebase client configuration through the approved local setup.
Never put service-account credentials, private keys, tokens, `.env` files,
certificates, provisioning profiles or account credentials into commits.

DerivedData, build/index caches, simulator runtimes/devices, IPA/xcarchive/dSYM,
xcresult, raw logs, node_modules and dependency checkouts are not included.

## Obsolete files

Ten superseded Brief screens were removed from this release branch because
their symbols are absent from the approved current Swift flow. The project uses
a synchronized source group, so leaving them would reintroduce obsolete code.
The old accented-name flag image was replaced by `uzbekistan.png`, as referenced
by the approved asset manifest. The original files remain in `develop` history.
