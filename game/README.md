# DumpMonkey Racing — Crew Yard development build

Godot **4.7.2 stable**, GDScript, Compatibility rendering. This is the first riding slice, not the finished premium-art milestone. The rider and motorcycle are procedural 3D studies. Production skinned models, animation, sound design, real browser/device validation and external playtesting remain.

## Windows setup

Requires Node.js 24 and PowerShell. From the repository root:

```powershell
powershell -File tools/setup-godot.ps1
& ./.tools/godot/Godot_v4.7.2-stable_win64_console.exe --path game
```

The setup downloads the pinned official engine, verifies its published SHA512 checksum, and installs matching single-threaded web templates. Engine binaries and build output are ignored by Git. Template downloads use HTTP ranges and ZIP CRC checks to avoid downloading the unrelated native export templates.

## Browser build

```powershell
New-Item -ItemType Directory -Force game/build/web
& ./.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path game --export-release Web build/web/index.html
node tools/serve-game.mjs
```

Open http://127.0.0.1:4173. The development server binds only to localhost, serves WASM with its correct MIME type, and compresses responses. Production hosting must supply equivalent MIME/compression settings and HTTPS. No cross-origin isolation is required by this single-threaded build.

## Controls

W/up: accelerate. S/down: brake. A/D or arrows: steer. Hold Space: wheelie. Q/E: lower/raise balance. R: respawn. Esc: pause. M: sound. Brake before tight corners. Follow numbered gates clockwise around the central workshop. Respawning makes a trial unranked; restart the run for a fresh attempt.

Gamepad mappings exist for triggers, left-stick steering, right-stick balance, A wheelie, Y reset and Start pause. Hardware/browser mappings remain unverified. Touch controls are deferred.

## Verification

```powershell
& ./.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/run_tests.gd
& ./.tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path game --script res://tests/integration.gd
```

The integration test uses a separate save filename. It verifies UI signals and gate/finish integration, not a human-driven complete lap. Visual captures can be generated with `--script res://tests/capture.gd` and optionally `-- --capture-ride`; output stays in ignored `game/test-output/`.

See [architecture](../docs/racing/ARCHITECTURE.md), [roadmap](../docs/racing/ROADMAP.md), [asset manifest](../docs/racing/ASSET_MANIFEST.md), and [verification evidence](../docs/racing/TESTING.md).
