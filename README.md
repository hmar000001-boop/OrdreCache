# L'Ordre Caché — Godot 2D prototype

**Genre:** experimental puzzle adventure · **Engine:** Godot 4.4.1 · **Code:** GDScript · **Target:** Android portrait / desktop preview · **Languages:** French, English, Arabic (RTL layout)

> The world doesn't explain. It responds.

This repository contains a playable first chapter prototype, not a claim that a finished commercial release already exists. The core loop is implemented: choose a sign, observe a world-state transition, infer a law, record it in the notebook, then apply previously learned rules to a more complex puzzle.

## What is implemented

- Six handcrafted experiments in the Still Garden chapter.
- Four signs: Sun, Rain, Moon, Wind.
- Persistent state transitions and feedback for experiments that do not change the world.
- A notebook that records laws after the player observes them.
- Optional hints, retry/reset, save/load through Godot's local `user://` config file.
- Language switch: French / English / Arabic with right-to-left layout for Arabic.
- Original vector-drawn atmosphere and a self-contained SVG launcher icon.
- GitHub Actions validation, gameplay smoke tests, Android debug APK export, and downloadable logs/test reports.

## The six experiments

1. Wake the silent seed with sunlight.
2. Grow the awakened sprout with rain.
3. Open the grown plant with moonlight.
4. Discover that wind can move a seed.
5. Experiment with a cold stone: sunlight warms it, moonlight reveals a mark, wind parts it.
6. Reconstruct the sequence to bloom a seed using the laws already observed.

No lives, timer, or failure penalty: experiments are the main mechanic. Incorrect attempts deliberately give a meaningful observation rather than a generic “wrong answer.”

## Run locally

1. Install Godot **4.4.1 Standard** (not .NET).
2. Open this folder's `project.godot` in Godot.
3. Press **F6/F5** or click Run.

For gameplay smoke tests:

```bash
godot --headless --editor --path . --quit
godot --headless --path . --script res://tests/smoke_test.gd
```

## Android build from GitHub Actions

1. Create a GitHub repository and upload these files preserving their folder structure.
2. Commit/push to `main`, or use **Actions → Build L'Ordre Caché → Run workflow**.
3. Wait for the workflow to complete.
4. Download the artifact named `lordre-cache-android-apk-<run number>` to get `LOrdreCache-debug.apk` and Android export logs. Download `lordre-cache-validation-<run number>` for import logs, smoke test logs and a source archive.
5. On Android, allow installs from the browser/file app you use, then install the debug APK.

The workflow uses Godot export templates, the Android SDK and Java 17. It does **not** require Unity, Unity activation, any paid plugin, or a game service. The debug APK is for sideload testing, not Google Play release signing.

## Important limitations / next milestones

- This is an initial playable vertical slice, not yet the proposed 25–35 puzzle, 4–6 hour commercial game.
- Illustrations are original vector shapes and symbols rendered by code; there is not yet frame-by-frame character animation, a licensed music score, professional voice acting, or a full set of bespoke background paintings.
- Arabic strings are included and the UI direction is RTL, but a native-speaker QA pass and appropriate Arabic font asset should be added before public release.
- No Google Play release keystore or store assets are included. Never commit a private keystore or password to the repository.
- GitHub Actions has not run from this environment. The first hosted build is the final authority on APK export; its logs are uploaded even when a step fails.

## Repository layout

```text
.github/workflows/build.yml   CI validation + Android APK + artifacts
assets/app_icon.svg           original launcher icon
scenes/main.tscn              main scene
scripts/main.gd               UI, puzzle state machine, saves, localisation
tests/smoke_test.gd           gameplay regression smoke test
export_presets.cfg            Android debug export preset
```

## Licence

Prototype source code is supplied for continued development. Replace the placeholder publisher details and establish a formal product/content licence before distribution. No third-party game assets are bundled.

## Phone-friendly ZIP workflow

If you prefer not to upload the extracted project tree, upload `LOrdreCache_Godot_Project_and_CI.zip` to the **root** of the GitHub repository, then create `.github/workflows/build-from-zip.yml` from the companion file `LOrdreCache_GitHub_Build_From_Zip.yml`. The workflow name in the Actions tab is **L'Ordre Caché — build Android from ZIP**. It validates the project, runs the smoke test, exports a debug APK, and uploads the APK plus logs as a single artifact.
