# Racing roadmap

## PR 1 — production direction and asset pipeline

Record accepted architecture, first playable, art direction and asset provenance. Establish consistent rider/bike/environment references. Inventory the Godot and modeling toolchain. This is preproduction, not playable completion.

## PR 2 — riding and browser feasibility

Pin engine/templates; implement internal contact, movement, wheelie and camera test scenes. Export to web. Verify wall/curb/ramp impacts at top speed, slope contact, balance recovery, pause/focus behavior and reset. Record real browser measurements. Revisit controller choice if contact behavior fails.

## PR 3 — Crew Yard production slice

Integrate modeled rider/bike, industrial environment, materials, animation, audio and polished HUD. Add practice and time-trial loops. Test wheelie scoring and checkpoint invalidation. Keep asset complexity within measured budgets.

## PR 4 — playable release candidate

Settings and local bests, loading/failure states, responsive canvas, gamepad checks, browser matrix and outside playtest. Publish a reviewable preview through a focused PR. Release only after validation evidence is recorded.

## Later

Garage/parts pipeline, progression and challenges; more bikes/riders/tracks; native Android controls and performance; asynchronous competition before real-time multiplayer; optional ecosystem integration.

## Playable exit criteria

- One complete practice and time-trial session in a hosted browser export.
- Understandable controls, recoverable wheelies, reliable checkpoint order and reset rules.
- Rider and motorcycle are animated 3D assets, not billboard replacements.
- Ten-minute stability run; named-device performance and startup measurements.
- Browser save failure, focus loss and audio activation handled.
- External playtest observations, known issues and repeatable verification instructions.
