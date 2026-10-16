# Racing asset manifest

## Existing identity reference

Source: public/assets/dmc/dumpmonkey_character_no_bg.png. Existing repository brand art; preserve the original. Identity: golden-tan monkey face, spiky brown hair, prominent ears, pointed cheek beard, half-lidded eyes and black high collar.

## Rider/bike/environment direction v1

Generator: built-in imagegen, 2026-10-16. Input: existing identity reference above. Intended use: production concept reference; not a playable mesh, texture atlas or rig. Saved: art/crew-yard-direction-v1.png.

Visually inspected: recognizable facial identity, coherent black/yellow riding outfit, front/side/rear rider references, detailed original bike and industrial yard vignette. Modeling caveats: views are illustrative rather than calibrated orthographic projections; verify proportions and mechanical consistency in 3D. The wet reflective yard is mood reference, not a promised browser rendering feature. Small bike markings are generated detail, not approved branding.

Prompt:

> Use case: stylized-concept. Create a premium game art direction production board for DumpMonkey Racing. Input reference: the supplied DumpMonkey character is the identity reference: preserve brown swept spiky hair, golden tan monkey face, large ears, half-lidded mischievous eyes, pointed cheek beard and black high collar. Translate to an original sophisticated stylized 3D game character, not human, not gorilla. Landscape production board with three coherent panels: left full-body rider standing in neutral pose in charcoal technical motorcycle jacket and trousers, racing yellow accents, gloves and boots; center matching full-body side profile and rear view for modeling; right original yellow and black naked street stunt motorcycle with visible mechanical construction and single low exhaust, and a small industrial street-yard environment vignette. Anatomically consistent character across views, long monkey arms suited to handlebars, readable premium game-ready shapes, clean bevels, tactile matte fabric, warm golden skin, no photoreal fur. Restrained black yellow and warm gray palette. Neutral warm-gray studio board, soft professional lighting, clear separation of silhouettes, no UI, no fake screenshots, no logos, no text, no watermark. Detailed art direction reference, not claims of an existing playable game.

## Required first-playable deliverables

| Asset | Required production form | Status |
| --- | --- | --- |
| Rider | UV-mapped skinned GLB, seated/lean/wheelie poses, hand and foot alignment | Pending |
| Motorcycle | Modular GLB, separate wheels/fork, mounting transforms, collision proxy | Pending |
| Crew Yard | Modular road/building/barrier kit, simple collision and material set | Pending |
| HUD | Godot Controls, readable typography, speed/timer/balance/results | Pending |
| Audio | Licensed/original engine loops and feedback samples, provenance | Pending |
| Loading artwork | Inspected raster illustration using established identity | Title illustration integrated |

## Integrated raster assets — 2026-10-16

Both generated with built-in imagegen, visually inspected and copied into the workspace. Generated raster images do not provide playable mesh geometry or rigging.

- `game/assets/art/title-crew-yard.png`: actual menu background. Identity reference: `art/crew-yard-direction-v1.png`. The cinematic lighting is illustration, not evidence of real-time render quality. Inspection: recognizably same monkey, black/yellow outfit, clear left-side text space. The motorcycle rear tire is airborne in this illustration; do not treat the pose as a wheelie physics specification.
- `game/assets/materials/yard-asphalt-v1.png`: integrated tiled ground albedo. Inspection: uniform overhead asphalt surface with no markings or baked directional shadows. Requested seamless edges; final in-engine tiling still requires visual review at riding distances. Not a normal, roughness or displacement map.
- `game/assets/art/garage-tuning-v1.png`: premium garage/tuning hub art-direction reference. It establishes the target for the future Garage scene: a mechanically detailed hero bike, coherent DumpMonkey rider, workshop material language, black/yellow lighting and a left-side area reserved for live navigation. It is not a runtime 3D scene, rigged character, or modular bike asset.

Garage prompt:

> Use case: stylized-concept. Asset type: premium in-game garage showroom background for DumpMonkey Racing. Input image is a visual quality reference only; do not copy its UI, text, branding, character, models, or layout. Create an original, console-quality 16:9 3D game environment for a motorcycle garage and tuning hub. Sophisticated industrial motorcycle workshop at night after rain, polished concrete floor, dark charcoal structural steel, warm yellow practical lights, black-and-yellow racing accents, organized workbench, lift platform, tool wall, tire racks, suspended shop lights, subtle haze and realistic depth. One original DumpMonkey-inspired golden-faced monkey rider in a premium black technical riding suit with restrained racing-yellow panels stands beside one original yellow-and-black naked street stunt motorcycle on a service stand. The bike has believable mechanical construction: exposed engine, frame, fork, disc brakes, chain, rear suspension, sculpted tank, dual wheels, detailed exhaust and cable routing. High-end stylized 3D console racing game render, premium PBR materials, clean bevels, realistic proportions, tactile fabric and rubber, authored art direction, no primitive low-poly geometry or generic asset-store look. Wide 16:9 establishing shot, hero subject right-center, calm dark negative space on the left for live garage navigation and tuning UI. No words, text, logos, interface, menus, buttons, badges, watermark, copied game assets, extra motorcycles, duplicated wheels, floating parts or impossible anatomy.

Title prompt:

> Use case: stylized-concept. Asset type: actual title-screen background illustration for DumpMonkey Racing. Use supplied production board as strict identity and art direction reference: same golden-faced monkey with swept brown spiky hair, large ears, black technical riding outfit with yellow accents, same original yellow naked street bike. Landscape 16:9 cinematic premium stylized 3D game illustration. Rider on bike doing a controlled modest wheelie on right half, industrial racing yard with black yellow barriers, warehouses and distant cranes, warm late afternoon sunlight, subtle suspended dust, expressive cool attitude. Left half remains dark charcoal warehouse shade with low visual complexity and ample empty space for live menu text. Clear silhouette, tactile materials, art-directed light, believable motorcycle proportions. No writing, no text, no logos, no HUD, no watermark. Not photorealistic and not a screenshot claim.

Asphalt prompt:

> Use case: stylized-concept. Asset type: seamless tileable 3D game albedo material texture. Create a square seamless asphalt surface for a premium stylized motorcycle game industrial yard. Orthographic directly overhead surface only, uniform neutral diffuse lighting with absolutely no directional shadows or perspective. Dark cool charcoal asphalt, subtle small mineral aggregate, faint wear and tiny restrained cracks distributed evenly, no big potholes, no road lines, no writing, no objects, no borders, no watermark. Consistent exposure edge to edge. Handcrafted game art material, restrained realistic surface detail, seamless on all four edges. This is a texture map, not a scene illustration.

## Current procedural geometry and audio

`bike/bike_visual.gd` creates the actual 3D riding study with separate wheel rotation, steering, rider silhouette and rear-wheel wheelie pivot. This is not yet the production skinned character or modular GLB promised by the milestone. `tracks/crew_yard.gd` creates the industrial circuit, workshops, barriers, containers and cranes. `core/crew_yard.gd` creates an original looped PCM engine tone; it is a functional audio study, not final sound design. No third-party game models or sounds were extracted.

## Existing brand assets reused

`game/assets/brand/crew-symbol.png` and `crew-logo.png` are copies of the existing repository symbol/logo. Used for application icon and engine startup splash. Originals preserved. `art/title-native-capture.png` and `art/riding-native-capture.png` are actual native-engine verification captures; the riding capture shows the current development geometry, not the final production art target.

## Onboarding update

`game/assets/art/onboarding-crew-yard-v2.png` is the new generated title background. See ONBOARDING_ART.md for the exact prompt and inspection. The original title art remains in the repository for reference. The current export includes both, so payload optimization remains.

Barlow Medium and Barlow Condensed ExtraBold come from the official Google Fonts repository (`https://github.com/google/fonts/tree/main/ofl/barlow` and `/ofl/barlowcondensed`). Copyright 2017 The Barlow Project Authors. Unmodified SIL Open Font License files accompany both in `game/assets/fonts/`. Use ASCII arrows/control names where browser fonts lack arrow glyphs; native system fallback is not a web guarantee. `core/feedback_audio.gd` synthesizes original short confirmation/skill-completion PCM samples for web-compatible playback; final sound design remains pending.

Use meters, consistent axes, sensible pivots and named mounting points. Establish measured geometry/texture budgets during the feasibility slice. Keep concept boards outside runtime imports until an explicit runtime use exists. Add provenance for third-party and generated assets; do not extract reference-game art into this project.
