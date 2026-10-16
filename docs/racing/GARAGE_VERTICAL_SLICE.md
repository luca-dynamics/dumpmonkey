# Garage vertical slice

This is the corrected next product slice for DumpMonkey Racing. The supplied reference board is treated as a quality and interaction reference, not as a source for copied assets or code.

## Player flow

`Loading → Onboarding → Garage → Bike Tuning → Rider Setup → Ride Challenge → Results → Save`

The Garage slice must feel like a complete mobile racing-game product surface before it is called playable-polished. It needs a persistent hero-bike presentation, a real navigation hierarchy, a parts catalog, rider configuration, settings, a challenge launch path and a return-to-garage result state.

## First production asset gate

- One authored modular motorcycle with separate wheels, fork/handlebars, body panels, exhaust, engine and mounting points.
- One UV-mapped, skinned DumpMonkey rider with seated, standing, throttle, wheelie, braking, crash and landing animations.
- One modeled garage environment with collision, lighting, material instances and camera anchors for inspection shots.
- One coherent UI kit for tuning cards, stat bars, locked/unlocked states, confirmation states and settings.
- No procedural placeholder mesh may appear in the review capture for this slice.

## REA research boundary

REA is used for authorized reference-app research: state transitions, navigation, screen inventory, input behavior, timing, camera framing and observable tuning/progression rules. It is not a mechanism for extracting or reusing proprietary Unity models, textures, source code, audio or branding. Findings must be recorded as behavior and design requirements, with screenshots or traces where permitted.

The REA audit is blocked until an authorized APK, installed build, or accessible target app URL is supplied. The supplied screenshots are already sufficient to define the initial inventory: garage tuning, rider configuration, bike collection, riding HUD, wheelie challenge messaging and branded loading.

## Acceptance evidence

The slice is not complete until a reviewer can open the browser build and capture the full flow above at desktop and mobile aspect ratios, inspect a bike part change, change a rider option, open settings, launch a ride, complete or fail a challenge, and return with the saved state intact. Concept boards and raster backgrounds may support the presentation, but they do not count as 3D asset completion.
