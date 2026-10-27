# Architecture — L'Ordre Caché 3D

## Runtime scene

`scenes/main.tscn` has a `Node3D` root running `scripts/main.gd`. At startup the controller creates a `GardenWorld` node and an independent `CanvasLayer` HUD. The world remains instantiated while the HUD is refreshed, so changing a language, selecting a sign or opening the notebook does not reconstruct meshes, camera, lights or ambience.

The `GardenWorld` builds a compact garden from primitive meshes: ground, stone path, plants, trees, altar, four sign pedestals and a central target. A `Camera3D`, `WorldEnvironment`, directional light and altar fill light establish the scene. Small emissive motes and restrained camera drift add movement. The current geometry is intentionally procedural so the project has no commercial asset dependencies.

## Interaction path

1. The controller receives an unhandled touch or mouse press outside UI controls.
2. The active camera projects the screen position into a 3D ray.
3. A physics query checks `Area3D` interaction targets on collision layer 1.
4. `GardenWorld.activate_interaction()` emits a target or sign selection signal.
5. The controller updates selection or calls `PuzzleEngine.observe()`.
6. The state returned by the rule engine is rendered by `GardenWorld.set_object_state()` and displayed in the HUD.

Touch UI symbol buttons provide an accessible alternative to hitting the world-space pedestals. The 3D world and UI therefore share the same gameplay actions.

## Rule engine

`puzzle_catalog.gd` owns the transition map and the mapping from a valid transition to a law identifier. `puzzle_engine.gd` accepts a state, selected symbol and puzzle index. It returns whether the state changed, which law the transition demonstrated, whether that law is new, and whether the current goal has been reached. It knows nothing about cameras, controls, sounds or scene trees.

The stone sequence discovers each law on its own observed transition. The final wind transition does not artificially award the two earlier laws again. The final puzzle combines the learned seed → sprout → sapling → bloom sequence.

## Persistence

Progress is stored in `user://ordre_cache_save.cfg`, which remains local and offline. `save_service.gd` is responsible for loading, writing and sanitizing the snapshot; `main.gd` no longer parses `ConfigFile` directly. Save version 2 stores the current puzzle, state, discovered law identifiers, selected sign, language and completion state. Values are checked against known languages, symbols, law IDs and puzzle-compatible states. Unknown future schema versions preserve a recognized language preference but fall back to a safe first-puzzle state instead of trusting incompatible data. The pure `sanitize_snapshot()` method is covered by regression tests without requiring writes to the device's actual save path.

## Testing and CI

`tests/smoke_test.gd` tests representative rules and goals, law discovery, invalid transitions, save-state compatibility, scene structure, symbol hit targets, notebook navigation and controller-to-world updates. GitHub Actions imports/parses the project, runs the headless tests, packages diagnostics and exports an Android debug APK. CI artifacts include logs and a source snapshot; the APK is debug-signed for sideload tests and is not a Google Play release build.
