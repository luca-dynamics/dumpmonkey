# DumpMonkey Racing architecture

Status: initial direction accepted 2026-10-16. Changes to major product scope or controller architecture require discussion with the owner.

## Product contract

Browser-first stylized 3D motorcycle racing under DumpMonkeyCrew. Godot 4, typed GDScript, Compatibility rendering, single-threaded web export initially. Desktop browsers are the first supported target; Android Chrome is an early feasibility target and native Android follows later. No wallet is required to play.

The owner explicitly requests a polished game with original quality assets, not a generic scaffold. Build the riding and art pipelines together. A technical validation scene is an internal tool, not the public milestone.

## First playable: Crew Yard

One compact industrial circuit and practice area, one DumpMonkey rider, one original motorcycle. Free practice, ordered-checkpoint time trial, controlled wheelies, third-person chase camera, results/restart, pause/respawn, engine audio, settings and personal bests. Keyboard first; gamepad tested where available. Wheelie initiation is assisted, with progressively harder sustained balance.

Defer AI racers, traffic, police, full garage, rider creator, open world, first-person camera, multiplayer and token rewards. Do not imply that generated concept art is running gameplay.

Owner approved an expanded opening on 2026-10-16: restrained title screen, skippable arrival, learn-through-play riding lessons, first wheelie/landing, and an invitation to a time trial. `RideLesson` owns skill progression separately from `RaceSession`; the camera owns cinematic sampling and the HUD owns presentation. Reduced motion skips the arrival and disables nonessential transitions. Only a completed landing persists introduction completion. Skips leave it incomplete. Browser loading waits for actual scene readiness rather than only engine startup.

## Simulation

Custom CharacterBody3D arcade controller. Ground probes establish contact and slope; authored acceleration, braking, steering, grip and gravity determine movement at a fixed physics tick. Keep presentation transforms separate from collision. Validate ramps, curbs and landings before expanding stunts.

Input sources produce a shared command structure: throttle, brake, steering, balance, reset and pause. Controller produces read-only telemetry for camera, animation, audio, HUD and mode scoring. Wheelie scoring requires forward speed and rear-ground contact. Loss of valid contact, failure or reset ends the attempt. Time trials enforce checkpoint order and invalidate reset-assisted runs.

Use speed-dependent steering, capped assistance and explicit grounded/airborne/crashed/resetting states. Keep tuning in Resources rather than UI or mesh scripts. Do not use VehicleBody3D as the motorcycle foundation.

## Module layout

Keep the current Next.js landing page at the repository root. The future Godot project lives in game/ with core/, bike/, rider/, camera/, modes/, tracks/, ui/, data/, assets/ and tests/. Scope signals to the owning scene. Avoid a monolithic global manager.

Use stable content IDs and versioned saves. Browser storage is best effort and editable; save failure must not prevent riding. Handle focus loss, stuck inputs, audio activation and WebGL startup failures. The game builds independently to a static export. The website launches it; it does not own the simulation loop.

Future networking must not assume cross-platform deterministic physics. Preserve input/state boundaries without implementing speculative network infrastructure. Externally valuable rewards will require server authority; local scores are not proof of entitlement.

## Asset contract

Preserve the existing DumpMonkey identity: golden face, brown swept hair, large ears, half-lidded expression, pointed cheek beard and black high collar. Palette: racing yellow, charcoal, warm gray. Use deliberate geometry, readable silhouettes and selective detail rather than heavy postprocessing.

Image generation supplies concepts, loading illustrations, portraits and suitable texture sources. Playable characters still require mesh topology, UVs, skeleton, weights and animations. Bikes need separate wheels, steering assembly and mounting points. Inspect every deliverable; record provenance and prompts. Never label a raster turnaround as a rigged model.

## Validation and sources

Pin an exact stable Godot version and matching export templates when provisioning the toolchain. Measure the browser export immediately. Proposed targets: 60 FPS on a named integrated-GPU laptop; 30 FPS feasibility on a named Android device. Record resolution, preset, device, browser, build, frame timing, transfer size and startup time. These targets are not yet verified.

- https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
- https://docs.godotengine.org/en/stable/classes/class_vehiclebody3d.html

REA is optional reference research, not a dependency. No reference game build has been supplied. Do not infer internal Unity behavior from promotional images. Configuration installation and research findings must be documented separately from game implementation.
