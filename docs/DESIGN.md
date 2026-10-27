# Design pillars — L'Ordre Caché

## The promise
The player is not given the world's rules. The world is a system that can be questioned. Observable physical feedback is more important than a text message announcing the answer.

## Core loop
1. Inspect the object at the garden altar.
2. Tap a physical sign pedestal or choose a sign in the touch UI.
3. Apply the sign and observe the object's state change.
4. Record a law only when its corresponding transition is observed.
5. Reuse a discovered law in a new context, including a sequence of prior discoveries.

## Interaction and presentation
- The scene is a real Godot 3D world, not a painted image behind 2D controls.
- The camera is deliberately composed for portrait mobile screens and has a subtle idle drift.
- Object models are built from procedural low-poly meshes for the first vertical slice; they are placeholders for future authored art, not claims of final AAA quality.
- The central target and four sign pedestals are raycast-selectable. The same actions remain accessible through touch buttons.
- The UI lives on a `CanvasLayer`; rebuilding the HUD does not reconstruct the 3D world.
- An original synthesized ambience loop and short interaction/discovery cues give immediate audio feedback.
- The notebook records demonstrated laws, hints are optional, and experimentation has no failure penalty.

## Technical boundaries
- `puzzle_catalog.gd`: puzzle definitions, transitions, law identifiers and save-state validation.
- `puzzle_engine.gd`: state transition and law-discovery logic, independent of the scene.
- `garden_world.gd`: procedural 3D presentation, physical selection targets, ambience and state visuals.
- `localization.gd`: French, English and Arabic strings.
- `main.gd`: scene coordination, HUD, interactions, navigation and local persistence.

## Non-goals for this slice
No combat, inventory grind, timers, lives, ads, network dependency, or forced hints. This release is a first playable 3D vertical slice, not a finished commercial-scale adventure.

## Expansion direction
- Region II — Inverted Galleries: gravity, reflection and spatial transformations.
- Region III — Living Archives: symbols change based on the order of observations.
- Region IV — Heart of Laws: earlier principles combine into non-obvious deductions.

These regions are ideas only; they are not implemented content.
