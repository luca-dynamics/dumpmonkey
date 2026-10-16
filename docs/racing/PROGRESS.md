# Racing handoff

## 2026-10-16

Owner accepted desktop-browser-first, assisted arcade physics and Crew Yard solo time trial plus wheelies. Requested premium characters/design assets using imagegen, and explicitly rejected a generic scaffold as the result.

Inspected local main at 75aa9d26: existing Next.js landing page, matching GitHub remote, clean worktree before this task. No Godot project existed. Existing brand character inspected as identity reference. No Godot or Blender executable found through PATH or the checked Program Files names; installation elsewhere remains possible.

Architecture and roadmap recorded. First image-generation request used the existing character as an identity reference for a rider turnaround, bike and environment production board. Output inspected and saved to docs/racing/art/crew-yard-direction-v1.png. Prompt and modeling caveats are in ASSET_MANIFEST.md. This is a production reference, not runtime geometry.

## Riding slice implemented

Branch: codex/crew-yard-playable. Pinned Godot 4.7.2, official engine SHA512 verification, matching single-threaded web templates, independent Godot game project, procedural 3D motorcycle/rider/industrial circuit, arcade controller, rear-pivot wheelies, chase camera, race/practice modes, directional ordered gates, countdown/results, reset invalidation, focus pause, local saves, gamepad bindings and looped sample audio. Generated title art and asphalt albedo are integrated; prompts/provenance are in ASSET_MANIFEST.md.

Validation: 24 focused and 11 scene integration checks pass; native title/riding captures inspected; web release export succeeds. Detailed limits and reproduction are in TESTING.md. Browser automation is blocked by an unattached debugger, so browser playability/performance/audio/storage are not verified. No Android/gamepad hardware test or human complete-lap playtest. Production geometry, skinning, animation and sound design remain. The accepted premium playable milestone is not complete. No REA setup executed.

The GitHub repository was empty. The unchanged two-commit local landing-page history was published to main to establish the PR base. The default CLI account lacked access; command-scoped credentials for the already-signed-in luca-dynamics account were used without changing the global active account. Game work stays on its feature branch.

Next: inspect the draft PR and CI artifact; restore browser automation or record manual browser evidence; drive complete laps and validate curbs/ramps; then replace procedural studies with production modeled/rigged assets matching the concept board. Discuss material architecture/scope changes with the owner. Do not merge this development build as the finished premium milestone.

## Onboarding revision requested and implemented

Owner explicitly rejected the development geometry as insufficiently polished and requested console-style onboarding. Accepted direction: cinematic arrival, stronger title screen, progressive riding lessons, wheelie/landing instruction and a first challenge. Implementation adds the seven-second skippable in-engine arrival, one-skill-at-a-time coaching based on actual controller motion, persistent completion/replay, reduced-motion and sound controls, modal focus/input isolation, and sample-based feedback cues. The title uses a new imagegen background requested by the owner; exact prompt and saved path are in ONBOARDING_ART.md. Barlow fonts include their OFL licenses.

The in-app browser now connects. Verified release title rendering, Start Riding, cinematic handoff and real throttle input advancing to braking. Found and fixed a web-only JavaScriptBridge integer/boolean comparison that stopped scene initialization; added bridge-conversion regression checks and a scene-readiness loading handshake. All five lesson skills complete under actual controller input in the native scene tests. See TESTING.md for detailed evidence and remaining browser/hardware/art limits. The current 3D rider/bike/environment remain development assets and do not meet the owner's final art bar.

Changes continue on draft PR #1: https://github.com/luca-dynamics/dumpmonkey/pull/1. Local verification now totals 70 checks (24 physics/rules, 11 integration, 35 onboarding). Native review captures of the revised title, arrival and challenge invitation are in docs/racing/art/onboarding-*.png. Do not interpret the new raster background as a production 3D upgrade.

## Garage re-baseline

The supplied Unity/mobile reference board established the required product bar: garage tuning, rider setup, bike collection, branded loading, riding HUD, wheelie challenges and settings. REA remains reserved for authorized reference-app research; screenshots alone cannot reveal internal Unity implementation or provide reusable proprietary assets. The next approved slice is documented in GARAGE_VERTICAL_SLICE.md.

Added `game/assets/art/garage-tuning-v1.png`, a new built-in-imagegen garage art-direction reference with a coherent hero motorcycle, DumpMonkey rider, workshop lighting and UI-safe negative space. Added a navigable Garage screen to the Godot HUD with bike-tuning presentation, rider-setup/settings sections, real sound/reduced-motion controls and a ride launch path. This is a product-shell step; the modular bike, skinned rider, part swaps and modeled garage remain production asset work.

Validation after the Garage change: 24 physics checks, 13 integration checks, 35 onboarding checks and a successful Web release export. No browser visual capture of the new Garage screen has been recorded yet.

## Loading shell polish

The browser boot screen was reviewed against the owner's screenshot. The generic centered text/progress treatment was replaced with an art-directed responsive shell: left-weighted title hierarchy, chapter framing, asymmetrical status rail, restrained diagnostic copy and responsive mobile layout. Browser reload visibly verified the new shell and successful handoff into the Godot title screen. This fixes the loading presentation; it does not replace the need for production in-game 3D assets.
