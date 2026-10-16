# Crew Yard verification record

Date: 2026-10-16. Engine: Godot 4.7.2.stable.official.ed1daf0bf. Windows, Compatibility renderer. Native visual capture identified Intel UHD Graphics 615, OpenGL 3.3, driver 30.0.101.1404.

## Verified locally

- Official Windows engine archive matches published SHA512 checksum; matching single-threaded web template ZIP entries pass CRC and size verification. Setup script exercised successfully.
- `tests/run_tests.gd`: 24 checks passed. Ordered gates/countdown/finish, valid wheelie distance, airborne and stationary scoring rejection, directional swept gate bounds, actual acceleration, braking, floor contact, assisted wheelie entry, overbalance wipeout, reset and top-speed thin-wall collision.
- `tests/integration.gd`: 13 checks passed. Actual scene/button signals, Garage entry and default tuning section, countdown, pause/resume, directional gate/finish integration, results UI, respawn invalidation, free riding, focus-loss pause, timer/movement freeze and return to menu. Uses a separate test save file. Gate completion is driven with controlled crossing positions; this is not a human-driven lap test.
- Native title and riding screenshots rendered and visually inspected. Corrected misplaced toast/countdown anchors and rear-wheel visual pivot. Title illustration is integrated. Actual riding graphics remain a procedural 3D development study.
- Single-threaded Web release export succeeds. Local server returns HTTP 200 and `application/wasm` for the engine and supports gzip responses. Server binds to 127.0.0.1:4173.
- Build output, engine binaries and generated visual-test output are ignored. Existing landing-page source behavior is not changed.

## Not verified / remaining release gates

- The earlier debugger-attachment blocker was resolved during onboarding work. In-app browser startup, title rendering, Start Riding, cinematic-to-lesson handoff and real throttle-input advancement to braking were visually verified. Full browser lesson completion, browser FPS, audible output and IndexedDB persistence are not yet verified.
- No Android device run, real gamepad test, human-driven full trial, outside playtest or ten-minute browser stability run.
- Ramp/curb landing quality and sustained cornering feel need hands-on playtesting.
- Production skinned rider, modular bike assets, animation and final engine/feedback sound design remain. Procedural models and the synthesized PCM loop do not meet those production deliverables.
- Settings cover sound and reduced motion; quality presets, richer accessibility/input settings and touch controls remain.
- The new Garage screen is native-tested and included in the Web export, but its visual presentation has not yet been captured in the browser. Bike tuning cards are currently product-shell data; real modular part swaps and saved rider configuration remain.
- Download/startup measurements on a real network and supported-device performance gates remain. Local file/gzip sizes are packaging measurements only.

## Local packaging measurements

Release export with title art and asphalt: WASM 39,514,754 bytes raw / 10,185,394 gzip; game pack 4,345,132 raw / 4,338,782 gzip. All exported runtime files total 14,636,069 bytes under gzip (approximately 14.6 MB decimal). This does not measure live CDN delivery, startup latency, GPU memory or browser frame rate. Measured before the final brand-icon addition; remeasure the release artifact when publishing.

## Reproduction

See `game/README.md` for pinned setup, tests, native launch and browser export commands. Run the local development server, open http://127.0.0.1:4173, select Time Trial or Free Ride. Use the in-game controls. Native screenshot captures are debugging evidence, not web-render verification.

## Onboarding verification update

`tests/onboarding.gd` adds 35 checks: skill/contact/input validity, continuous wheelie hold, retry retention, generated artwork load, integer/boolean motion-preference conversion, cinematic pause/skip/automatic handoff, pause disabling underlying controls, skip versus completion, saved preference readback, replay and returning-player behavior. All five skills are also driven using actual controller commands in the real scene without teleports or synthetic telemetry.

Browser startup initially failed because JavaScriptBridge.eval returned an integer for the motion-preference boolean, and a direct comparison with `true` raised `Invalid operands 'int' and 'bool'`. A debug export exposed this; explicit `bool(value)` at the bridge boundary fixed it. The real release was then verified to render and advance the throttle lesson. Temporary DEBUG-onboarding-startup logs were removed. Browser loading now waits for `dumpmonkey:ready` and exposes initialization failures rather than silently revealing a blank canvas. Missing arrow glyphs found in the web capture were replaced with ASCII/control names.
