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
