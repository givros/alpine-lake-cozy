# Alpine Reference Reconstruction â€” final review

The editable Blender scene and independently built local WebGPU viewer are available. The environment is navigable and contains the requested three residences, lake, stream, footbridge, trails, rocks, conifer groves and alpine groundcover. **Photographic reconstruction acceptance remains open.** This is a 3D approximation of the supplied image, not a verified near-identical reproduction.

## Current deliverables

- `Alpine_Lake.blend`, packed textures, nine named inspection/reference cameras and meaningful editable component collections.
- `viewer/`: pinned source and lockfile, current production build, full uncompressed GLB, original-resolution photographic assets and first-person controller.
- Shared spatial specification, semantic layout, region graph, asset registry and animation manifest.
- `renders/nine_views.png`, actual full-size render sets, source detail views and `comparisons/final_reference_grid.png`.
- Local viewer: http://127.0.0.1:4182/ . No remote hosting or desktop/browser control was used.

## Reference and construction review

The original attached image stayed authoritative. Existing local original architecture and verified CC0 botanical/rock assets were reused in an independent copy; earlier project validation was not reused. The recorded changes constrain the massif against observed screen-space ridge anchors, rebuild supported snow, replant affected trees, strengthen full branching crowns, re-ground rocks, align timber grain to the actual parts, and refine the stream surface and lighting.

Representative tree review: `renders/tree_representative.png`. Three complete current-view sets: `renders/pass1_*.png`, `renders/pass2_*.png`, `renders/pass3_*.png`. Pass 1 exposed a too-warm sky and weak contacts; pass 2 checked corrected sky, full crowns and grain, and exposed the flat stream optical normal; pass 3 checks corrected water normals, reduced ridge spikes and solar placement. The source was reopened in a fresh Blender 5.1.2 process and rendered with Cycles on the GPU; `reopen_validation.json` records the final reference, cabin and bridge renders. The separate nine-view contact sheet uses actual runtime renders.

Remaining visible limitations: the mountain ridge/snow morphology is inferred from one view and still reads as CG; conifer distribution and repeated silhouettes differ from the reference; some surrounding ground patches remain broad and regular; water cascades/foam remain less convincing than the photograph. No 9/10 similarity or full photographic compliance is claimed. Unseen backs and woodland continuation are authored inferences. Cabin doors are closed; furnished interiors were not requested.

## Source and transfer

`source_validation.json`, `transfer_validation.json`, `color_transfer_validation.json` and `delivery_integrity.json` bind the current source and export. All 696,407,851 instance-expanded triangles are retained; this is an inventory, not triangles drawn each frame. All exported positions and normals are finite and normals are nonzero. Six inherited source normal-fan defects were repaired without changing positions/faces/UVs; the independent GLB normal audit already passed. All source file images are packed. No Draco, Meshopt transport compression or texture downsampling is applied. Distant vegetation uses preloaded source-derived multiview representations while complete near geometry and full shadow models remain.

Terrain, foliage and optical water shaders are translated explicitly into TSL. Source and runtime lighting are calibrated separately; they are not pixel-identical transport solutions. The warm valley directional fill in the viewer is an authored approximation. Water has a 12-second optical cycle; no physical fluid simulation or character animation is claimed.

## Desktop runtime

Owned headless Chromium 156.0.8078.4, actual NVIDIA RTX 3080 WebGPU, 1440 x 810, native DPR 1, four-sample scene MSAA. Eight-second named-view measurements, ordinary live-controller routes and real GPU completion counters. No user applications were closed. Operating-system/driver caches were not reset. First complete frame: 26.02 seconds from GLB/resource-load start in the final fresh context (initial renderer, sky and config setup precedes this timer).

| View | Mean FPS | Completion p95 ms | Completion p99 ms |
|---|---:|---:|---:|
| reference | 59.62 | 17.60 | 38.10 |
| aerial | 59.75 | 17.40 | 37.70 |
| forest | 59.49 | 17.90 | 39.90 |
| cabin | 59.61 | 18.00 | 39.20 |
| bridge | 60.00 | 17.20 | 20.40 |
| reverse | 60.04 | 22.90 | 30.60 |

The original per-frame CPU/GPU synchronization reduced throughput to about 25-27 FPS. Allowing at most three submissions in flight and evaluating static object transforms once restored approximately 60 FPS without reducing models, textures, resolution, reflections or shadows. GPU completion notifications can arrive in batches: the independent 16-second reverse check reports 16.67 ms mean and 17.2 ms p95 submission intervals, versus 27 ms p95 completion-notification delivery. The strict notification-tail `target60` flag remains false and is not relabeled. Occasional longer tails remain recorded. GPU resource byte counts are allocator estimates, not measured VRAM.

All five routes completed through the real keyboard-driven controller: primary chalet, upper chalet, central cabin, bridge/shore loop and connecting trail. Water and solid buildings block travel. Small transient foot/support gaps on descents are gravity motion, not zero-error claims. Mouse look, pause, input release and reset/focus handling are tested within the application.

Two repeated fullscreen cycles verify continuing completed frames and real main/reflection framebuffer growth and shrink at 1920x1080 and odd 1601x901, returning to 1440x810 with water visible. Physical-browser long-hold Escape behavior was not tested. Reload preserved one canvas and the same 82 shader programs/823 geometry resources. A mocked no-WebGPU context stopped before any submission and showed a readable capability message. Detailed evidence: `viewer/runtime_validation.json`, `viewer/lifecycle_validation.json`, `viewer/verification_final.log`.

## Final compliance review

| Criterion | Status | Evidence and limit |
|---|---|---|
| CAMERA | verified | Dedicated reference camera and observed landmark anchors; exact photogrammetric calibration is unavailable. |
| CONSTRUCTION | verified | Editable split-log cabins, roof structure, glazing, porches, open flues, deck/rail bridge, scanned rock families and complete branching conifer assemblies. Source and runtime close views inspected. |
| SUPPORT | verified | 2,396 rock contacts corrected against actual terrain; mountain tree datums recomputed after landform edits. Five routes traversed through the live controller. |
| FIDELITY | failed | Composition and principal elements are reconstructed, but the mountain surface/snow pattern, conifer character/density, sky cloud pattern and stream cascade/foam appearance remain visibly different. The requested photographic similarity gate is not closed. |
| MOTION | verified | Actual keyboard walking, mouse look, water optical flow, pause/focus handling, and repeated completed frames tested. Vegetation remains static as requested; no inhabitants added. |
| TRANSFER | verified | 696,407,851 source/export instance-expanded triangles match exactly; uncompressed export, native textures, FLOAT32 colors and finite nonzero exported normals audited. |
| PERFORMANCE | verified | Six named views and five live routes averaged approximately 59.5-60.0 FPS on RTX 3080 at 1440x810 DPR1. Floor30 passes. The stricter completion-notification p95 flag is false in one view; independent reverse submission p95 is 17.2ms. This is no locked-60 or other-hardware guarantee. |
| WHOLE_SCOPE | failed | Nine-view reviews cover the core, side/rear surroundings and close assets. Repeated conifer silhouettes and broad ground/forest distribution still fall below the primary photographic target. |

The requested files and working local exploration are delivered; the strong photographic-fidelity target remains unmet. Technical success and measured frame rate do not close that visual gap.

Final reset/water check: `viewer/reset_water_validation.json`. Real R-key reset returned exactly to the supported spawn. Water at t=3 changed 52,052 pixels; t=12 versus t=0 had no changes greater than one byte.
