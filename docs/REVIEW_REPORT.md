# Review report — 3D refactor follow-up

## Scope

Reviewed the resulting source tree after the initial implementation, concentrating on scene architecture, rule correctness, the 3D interaction path, HUD layout, persistence, regression tests and Android automation. This was a source-level review in a container where no Godot executable was installed and DNS prevented downloading one; therefore the report does not claim an actual Godot compile, APK export or on-device run.

## Findings fixed in the review pass

1. **The UI no longer owns or recreates the world.** The main scene root is `Node3D`; `GardenWorld` and the `CanvasLayer` HUD are separate siblings. HUD refresh removes only HUD children, leaving the world, camera, object, lights and ambience alive.
2. **Interactions now follow one route.** Screen taps raycast against collision-layer-1 `Area3D` targets. `GardenWorld.activate_interaction()` emits one target-selection or sign-selection signal. UI controls call the same controller methods, so touch buttons and world-space objects use the same logic.
3. **Rule discovery is transition-specific.** The stone's sun, moon and wind laws are recorded on their actual transitions. The final transition no longer awards all three laws as a special case.
4. **The last-puzzle test now checks the real sequence in order.** It asserts seed → sprout (sun) → sapling (rain) → bloom (moon), with checks performed before the next state overwrites the prior one.
5. **Notebook navigation remembers its caller.** Returning from the notebook restores home, gameplay or the finish screen, instead of always opening a puzzle.
6. **Save input is checked against known data.** Language, symbols, law IDs, puzzle indexes and puzzle-compatible object states are validated; saves have schema version 2 and newer unknown schemas fall back to a safe starting state.
7. **The 3D objects are visible above the mobile HUD.** The camera aim and foreground sign-pedestal positions were adjusted to keep the key object/pedestals in the top scene window while preserving room for touch controls.
8. **UI selection callbacks are bound explicitly.** World selection and the touch-grid use the same validated symbol IDs. Symbol-selection/discovery/no-change audio feedback is handled independently from the rule engine.
9. **Headless tests and CI diagnostics are more useful.** The smoke suite checks rule transitions, discovery, invalid inputs, scene structure, four symbol targets, notebook navigation and controller-to-engine integration. CI preserves logs and reports even if a job fails.
10. **The project metadata and docs match the new architecture.** The entry scene, project description, architecture document and README no longer describe a single-image 2D game.
11. **Selection feedback no longer relies on child indexes.** Sign-cap selection uses a named `SymbolCap` node, and regression tests assert that all four signs retain ray-pickable targets and the expected visual node.
12. **Fast consecutive state changes cannot stack scale tweens.** A running object-state tween is killed before the next state animation starts.
13. **Ambient audio has explicit loop points.** The WAV loop start/end are set in sample frames, so the original ambience is looped rather than stopping after its initial playback.
14. **The UI-refresh regression test captures a live control instance.** It verifies that a routine symbol selection updates the current HUD rather than rebuilding the control tree.
15. **Phone-only upload instructions are synchronized.** The ZIP filename, companion workflow name, artifact names and GitHub path now match the delivered files.
16. **Save parsing is separated from the scene controller.** `save_service.gd` owns ConfigFile I/O, schema handling and sanitization. `sanitize_snapshot()` is exercised with invalid languages, out-of-domain states, unknown/duplicate laws, invalid symbols, inconsistent completion flags and future schema versions.
17. **Portrait camera safe area is tested.** The four sign pedestals were repositioned inward and the smoke suite checks their horizontal angle against a conservative safe-area bound so important world controls are less likely to clip on narrow phones.

## Static consistency checks performed for this archive

- Archive source tree includes the Godot project, Android export preset, GitHub Actions workflow, scripts, tests, localization and original WAV audio assets.
- Main scene references `scripts/main.gd`; that controller preloads the catalog, engine, world, save service and localization scripts plus the SFX assets.
- The test file references the puzzle catalog, rule engine and save service, and emits a nonzero exit on failed assertions.
- All `res://` paths referenced by source/scenes were checked against the package tree. The 74 localization keys match across French, English and Arabic, and all statically referenced translation keys exist.
- A static transition-graph check confirms that each of the six puzzle goals is reachable from its start state, and every transition's law identifier is in the known-law catalog.
- All sound assets are locally generated PCM WAVs; there are no remote runtime dependencies.
- Both GitHub Actions workflow YAML files were parsed successfully by Ruby's YAML loader. The workflow configuration matches the Godot 4.4 Android export path documented by Godot, including Java 17 and the documented debug-keystore environment variables.
- The renderer remains Godot Compatibility for broad Android device coverage; the garden uses standard 3D meshes, materials, camera, environment, lights and raycast Areas.

## Remaining verification and known limits

- Godot is not installed in this environment, and DNS prevented retrieving the engine or an offline GDScript parser. As a result, no Godot runtime parse/import, smoke-test execution, APK export or on-device interaction test was possible here. GitHub Actions must confirm those engine-level checks. The static checks reported above are not a substitute for a successful CI run.
- The included models are procedural and stylized, not bespoke production art. Frame rate, materials, touch hit areas and audio loudness must be checked on the target phone.
- Arabic typography still needs visual QA on Android with a bundled/verified Arabic-capable font before a public release.
- The CI APK is debug-signed. Store-ready signing, store assets, privacy/product compliance and a release build remain separate work.
