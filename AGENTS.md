# DumpMonkeyCrew development

The repository contains the existing Next.js landing page at root and DumpMonkey Racing in `game/`. Keep their build pipelines independent.

Before game work, read `docs/racing/ARCHITECTURE.md`, `PROGRESS.md`, `ROADMAP.md` and `TESTING.md`. Use current source/Git state as authority. The owner approved Godot 4/GDScript, desktop-browser-first, assisted arcade handling, and Crew Yard with practice, time trial and wheelies. Discuss material architecture/product changes before implementing them.

The target is a polished original game. Generated concepts are not playable models. Preserve the established DumpMonkey identity; record asset provenance and prompts in ASSET_MANIFEST.md. Do not describe procedural development studies as finished production characters. No wallet dependency or token-reward authority in local gameplay.

Use focused feature branches/PRs. Preserve concurrent/unrelated changes. Run the focused physics/race tests, scene integration checks and Web export described in `game/README.md` for relevant changes. Verify browser behavior separately: native screenshots, HTTP 200 and successful exports do not establish browser E2E or device performance. Keep the progress/verification record candid and current. Never claim planned tests passed.
