# L'Ordre Caché — 3D Android vertical slice

**Engine:** Godot 4.4.1 · **Code:** GDScript · **Target:** Android portrait · **Languages:** French, English and Arabic · **Connectivity:** offline

> Le monde ne t'explique pas ses lois. Il répond à tes expériences.

This is an upgraded, playable **3D prototype**, not a claim that a finished commercial game is complete. It replaces the previous single-image 2D scene with a procedural 3D garden, a real camera, lighting, physical objects, raycast selection, a separated HUD, save validation, original synthesized ambience and interaction sounds.

## What's in this build

- A small 3D garden made from procedural meshes: trees, plants, a stone path, altar, four sign pedestals and a central object.
- Touch or click the central object to inspect it. Tap a world-space sign pedestal to select Sun, Rain, Moon or Wind; the same signs are also available as mobile-friendly UI buttons.
- Apply the selected sign and watch the 3D object's model change. A successful observation can record a law in the notebook.
- Six experiments and seven possible laws from the first chapter remain in the project.
- Optional hints, reset, progress, notebook, French/English/Arabic text, local save, ambient sound, discovery cue and no-change feedback.
- Puzzle rules, world rendering, save handling and localization live in separate scripts; the main controller coordinates the HUD, session and touch events.
- GitHub Actions parses/imports the project, runs the regression suite, uploads logs/test reports/source snapshot and exports an Android debug APK.

## What it is not yet

The environment and object models are procedural low-poly geometry. This gives the game true 3D interactions and provides a foundation for art direction, but it is **not yet comparable to a major-studio release**. It still needs bespoke environment/object art, more varied animation, sound design, narrative and puzzle content, device testing and a dedicated visual-polish pass before commercial release.

## Run in Godot

1. Install **Godot 4.4.1 Standard** (not .NET).
2. Open `project.godot` and press **F6/F5**.
3. For the automated regression tests, run:

   ```bash
   godot --headless --editor --path . --quit
   godot --headless --path . --script res://tests/smoke_test.gd
   ```

## Build an Android APK with GitHub Actions

### Option A — upload the extracted project

Upload the *contents* of this ZIP into the root of a GitHub repository, preserving `.github/workflows/build.yml`. Push to `main`, or open **Actions → Build L'Ordre Caché 3D Android → Run workflow**. The CI creates a debug APK and downloadable logs/reports.

### Option B — upload this ZIP as one file (phone-friendly)

1. Upload `LOrdreCache_3D_Refonte_ANDROID_CI.zip` to the root of a repository.
2. Create `.github/workflows/build-from-zip.yml` in that repository using the companion workflow file `LOrdreCache_3D_GitHub_Build_From_Zip.yml` delivered alongside the ZIP.
3. Run the workflow from the GitHub **Actions** tab.

With Option A, the Android artifact is named `lordre-cache-3d-android-apk-<run number>` and the validation artifact `lordre-cache-validation-<run number>`. With Option B, the matching names are `lordre-cache-zip-android-apk-<run number>` and `lordre-cache-zip-validation-<run number>`. The Android artifact contains `LOrdreCache-3D-debug.apk`, import/export logs and the APK SHA-256; validation artifacts contain import/test logs and a source snapshot.

The APK uses debug signing for sideload testing; it is **not** signed for Google Play release. The workflow generates a temporary debug keystore on the runner, so Android may require uninstalling a previous test APK before installing one from a later CI run; uninstalling can erase local progress. The CI has not been run in your GitHub account from this environment, and the current environment did not have the Godot executable available to perform an actual local engine build. The uploaded GitHub Actions logs will be the first authoritative engine/export validation.

## Code layout

```text
.github/workflows/build.yml    CI validation + APK export
scenes/main.tscn               Node3D entry scene
scripts/main.gd                scene coordination, HUD and interaction events
scripts/garden_world.gd        procedural 3D world, raycast targets, ambience
scripts/puzzle_catalog.gd      puzzle data, transitions and valid puzzle states
scripts/puzzle_engine.gd       renderer-independent state machine
scripts/save_service.gd        versioned save/load and untrusted-data sanitization
scripts/localization.gd        FR / EN / AR text
assets/audio/                  original synthesized ambience and cues
tests/smoke_test.gd            regression tests
export_presets.cfg             Android debug export preset
docs/ARCHITECTURE.md            runtime and data-flow overview
docs/REVIEW_REPORT.md           implementation review findings and checks
```

## Licence and release note

The code and original synthesized sound files are included in the archive. Before public/commercial release, select a formal licence and review all third-party dependencies/assets you add later. Never commit a private release keystore or signing passwords.
