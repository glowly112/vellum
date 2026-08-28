# Vellum Pad — Internal TestFlight

Working name **Vellum Pad** (not “Vellum” alone — Apple Search Ads / App Store uniqueness). This is a native iOS shell around the *local* production desk, not a rewrite and not a wrap of the live Vercel URL.

| | |
| --- | --- |
| **Display name** | Vellum Pad |
| **Bundle ID** | `com.jamiematheson.vellumpad` |
| **Version** | 1.0.0 |
| **Build** | 1 |
| **Distribution** | **Internal TestFlight only** — do not submit for App Review |
| **Pages** | Local (`localStorage` key `vellum-pages-v1`). Files / iCloud later; not in this build. |

The Xcode project lives at `ios/App/App.xcodeproj`. It loads `dist/client` (a static SPA of the same paper desk) over Capacitor’s `capacitor://localhost`. It must never load `https://vellum-jamies-projects-b6f60a28.vercel.app` or any other remote app URL.

## On the Mac Mini (Xcode already installed)

Need Node 22+ (`node -v`). Then, from the repo root:

```bash
npm install
npm run ios:prepare
open ios/App/App.xcodeproj
```

`npm run ios:prepare` builds the static desk (`VELLUM_IOS=1`) and copies it into `ios/App/App/public`. `npm run build` is unchanged: it is still the Vercel SSR web build.

In Xcode:

1. Select the **App** target → **Signing & Capabilities**.
2. Tick **Automatically manage signing**.
3. Choose **Jamie Matheson’s personal Apple team** from the Team menu. (This cloud VM cannot complete signing. No team ID is checked into the project.)
4. Confirm Bundle Identifier is `com.jamiematheson.vellumpad`.
5. Destination: **Any iOS Device (arm64)** — not a simulator — for a store/TestFlight archive.
6. **Product → Archive**.
7. Organizer opens when the archive finishes.

### Upload for Internal TestFlight

**From Organizer**

1. Select the archive → **Distribute App**.
2. **App Store Connect**.
3. **Upload**.
4. Leave App Review information alone; you are not submitting a review.
5. Wait for processing in [App Store Connect](https://appstoreconnect.apple.com).

**Or Transporter**

1. Organizer → Distribute App → **Export** → App Store Connect → export the `.ipa`.
2. Open **Transporter** → add the `.ipa` → **Deliver**.

Then in App Store Connect:

1. **Apps** → create “Vellum Pad” if it does not exist (bundle ID `com.jamiematheson.vellumpad`, iOS).
2. **TestFlight** → the build appears after processing (often 10–30 minutes).
3. Add Jamie (and only internal testers) under **Internal Testing**.
4. Do **not** click Submit for Review. Do **not** add an external test group that requires Beta App Review.

First-time App Store Connect setup (once per Apple ID / bundle):

- An **Apple Developer Program** membership on Jamie’s team.
- An iOS **App** record with this bundle ID.
- Export compliance: Info.plist already sets `ITSAppUsesNonExemptEncryption` to `false` (standard HTTPS only).

## What the shell does

- Hosts the existing desk (library, paper textures, catalogue, focus, visualViewport keyboard inset).
- Keyboard: Capacitor `Keyboard.resize = none` so `src/lib/keyboard.ts` (`visualViewport`) keeps the caret and the page sheet above the keyboard. Safe-area padding is the existing `pt-safe` / `pb-safe`.
- **Export as text** in the Page drawer presents the iOS share sheet with a `.txt` file.
- Home-screen icon is a cream ruled sheet on a desk (`public/ios/vellum-pad-icon.png`), not the generic Capacitor glyph and not Grok assets under `public/__grok`.

## Signing / blockers (this VM)

Signing **cannot** be completed on the cloud agent:

- No Apple ID session, no certificates, no provisioning profiles, no App Store Connect API key.
- `DEVELOPMENT_TEAM` is intentionally unset. Do not invent a team ID.
- Archive and upload must happen on the Mini, signed as Jamie’s personal team.

If Xcode complains the bundle ID is taken, register `com.jamiematheson.vellumpad` under that team in the [Apple Developer identifiers](https://developer.apple.com/account/resources/identifiers/list) list, then reselect the team.

If SPM packages fail to resolve on first open: **File → Packages → Resolve Package Versions**. Capacitor 8 uses the local `CapApp-SPM` package; it needs network once.

## After you change the web desk

```bash
npm run ios:prepare
```

Then archive again. Bump **Current Project Version** (build number) in the App target for each upload to TestFlight. Leave **Marketing Version** at 1.0.0 until you mean to.

## Product locks (do not break)

Pages, not documents. No folders, tags, notebooks, accounts, AI, sync, or sidebar. Local pages only.
