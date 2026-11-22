# Claude Code usage documentation

This file logs the changes that Claude Code (an AI coding assistant) made in this repository.
Each change was discussed with the maintainer before it was made: the design decisions were
taken together, and Claude Code then implemented them.

Each entry records what changed and why, including the alternatives that were considered and
why they were rejected. The code Claude Code wrote is also marked in the source:
`Written by Claude Code` at the top of files it wrote entirely, `Written with the help of
Claude Code` on functions or lines it added or changed in human-written files.

## 2026-09-24: `ProjectionCorners.msg` and `SetProjectionCorners.srv`

### What changed

Two new definitions, both added to `rosidl_generate_interfaces()` in `CMakeLists.txt`:
- `msg/ProjectionCorners.msg`: a header (stamp = when the corners were selected, frame_id = the camera's optical
  frame), `image_width`/`image_height`, and `top_left`, `top_right`, `bottom_right`, `bottom_left` as
  `geometry_msgs/Point` in pixels of the raw camera image (z unused).
- `srv/SetProjectionCorners.srv`: a `ProjectionCorners` request, answered with `success` and a `message` that gives
  the reason on failure.

They only reference `std_msgs` and `geometry_msgs`, which were already declared in both `CMakeLists.txt` and
`package.xml`. Verified with a build; `ros2 interface show` resolves both types.

### Why / alternatives

The corners of the projected image, selected in `surface_selector`, used to live only in a private INI file in the
install space. Now `projection_corners_node` (in `ros2-par-framework`) holds them, publishes them latched on
`/projection_corners`, and stores new ones received through `set_projection_corners`. This mirrors the camera's
`camera_info` / `set_camera_info`.

- *`geometry_msgs/PolygonStamped`:* rejected; standard, but RViz offers it as a polygon and would draw the pixel
  values as metres.
- *Reusing the VIGITIA `GetProjectionCorners.srv`:* rejected; it is a request/response pull by camera name, with
  integer coordinates. It is left unchanged for ported nodes; nothing uses it currently.
- *A `geometry_msgs/Point[4]` array:* rejected; the named fields make the order unambiguous.

## 2026-09-24: `HandLandmarksList` and landmark units

### What changed

- New `msg/HandLandmarksList.msg` (header + `HandLandmarks[] hands`), listed in `rosidl_generate_interfaces()`. No new
  external package, so `DEPENDENCIES` and `package.xml` are unchanged.
- `HandLandmark.msg` and `HandLandmarks.msg` got comments on units and meaning: `hand_landmarks` x/y are pixels in the
  image the header refers to and z is mediapipe's relative depth in image widths; `hand_landmarks_3d` is the camera
  optical frame in the depth image's unit and currently never filled. Field definitions are unchanged.

Verified by building with the hand_landmarks node, which published `HandLandmarksList` end to end.

### Why / alternatives

The hand_landmarks node published one `HandLandmarks` per hand and nothing when no hand was visible, so consumers
(gesture, pointing, the planned touch detection) could not tell "no hands" from "no frames" or when all hands of a
frame had arrived. The list follows `ObjectList` / `FiducialsList`. The units were only knowable by reading the node
source (x/y converted to pixels in place, z left in mediapipe's scale).

- *Arrays directly in one message per frame (flattened landmarks):* rejected; it would change `HandLandmarks` itself
  and break the element type the ported VIGITIA consumers already know. Wrapping keeps it.
- *Units in `HandLandmark.msg`:* rejected; the same type holds pixels in one array and camera coordinates in the
  other, so the units are documented on the arrays.

## 2026-09-24: `HandLandmarksList` holds only hands of the current frame

### What changed

Comment in `HandLandmarksList.msg`: the list holds only the hands detected in that frame; a hand missing for less
than 1 s keeps its id when it reappears but is not listed while missing. No field changes.

### Why / alternatives

The hand_landmarks node stopped publishing stale hands (reasoning in `claude_usage_documentation.md` of the
`hand_landmarks` repository), and consumers need to know that absence from the list does not mean the id is gone.

## 2026-09-24: `ProjectionMapping.msg` and `SetProjectionMapping.srv`

### What changed

Both are new and added to `rosidl_generate_interfaces()`.
- `msg/ProjectionMapping.msg`:
  - header (`frame_id` = the table frame `world`, stamp = calibration time);
  - `projector_width`/`projector_height`;
  - `float64[9] homography`, row-major: `[u v w] = H [x y 1]`, x/y in metres on the table plane, pixel =
    `(u/w, v/w)`;
  - `reprojection_error`, RMS in projector pixels.
- `srv/SetProjectionMapping.srv`: `ProjectionMapping mapping` → `success`, `message`.

Only `std_msgs` is referenced, already declared. Verified with a build and `ros2 interface show`; the synthetic
end-to-end run in `ros2-par-framework` used both.

### Why / alternatives

The table-to-projector homography, fitted by `projection_calibrator` (in `surface_selector`) and held by
`projection_mapping_node` (in `ros2-par-framework`), which publishes it latched on `/projection_mapping`. It replaces
VIGITIA's `GetHomography`/`GetTransformedCoordinates` round trips for new nodes. Those legacy definitions stay for
ported code.

- *A camera → projector homography:* rejected; the table in metres is the framework's common frame. It carries the
  lens undistortion, and RViz and projection share it.
- *`float32[]` of any length (as in `GetHomography`):* rejected; the fixed `float64[9]` states the shape and keeps
  precision.

## 2026-09-25: `HandLandmarks.hand_landmarks_3d` comment up to date

### What changed

The comment on `hand_landmarks_3d` in `msg/HandLandmarks.msg` now says what the hand_landmarks node fills in: metres
(not "the unit of the depth image"), in the optical frame, from a depth image registered to the colour image, only
with `use_depth`, and in the same order as `hand_landmarks`. It also says when -1, -1, -1 is used (no measurement,
outside the image, too far from the rest of the hand). "Currently never filled" is gone. Only a comment changed, so
the type hash and all dependent builds stay as they are; the package still builds.

### Why / alternatives

The field is filled since hand_landmarks computes depth per landmark, and `rviz_bridge` draws the hands in 3D from it.

## 2026-09-25: `Fiducial.corners_3d`

### What changed

`msg/Fiducial.msg` gets `geometry_msgs/Point[] corners_3d`: the four vertices in the optical frame, in metres, in the
order of x0/y0 ... x3/y3, from a plane fitted to the depth inside the marker. Empty without depth. `geometry_msgs`
was already a dependency, so no other edits were needed. Verified by building this package and then the dependents.

### Why / alternatives

fiducials_detector with `use_depth` fills it, and `rviz_bridge` draws the markers in 3D. The new field changes the
type hash, so every package using `Fiducial` must be rebuilt (fiducials_detector, surface_selector, rviz_bridge).

## 2026-09-29: `Object.center_3d` and `Object.hull_contour_3d`

### What changed

`msg/Object.msg` gets `geometry_msgs/Point center_3d` and `geometry_msgs/Point[] hull_contour_3d`: the object's
centre and hull outline on their rays at the depth of its top surface, in the optical frame, in metres. `center_3d`
is all 0 and `hull_contour_3d` empty without depth. Verified by building this package, `object_detector` and
`rviz_bridge`. The type hash changes, so every package using `Object` must be rebuilt.

### Why / alternatives

object_detector with `use_depth` fills them, as fiducials_detector fills `Fiducial.corners_3d`, and `rviz_bridge`
draws the objects in 3D. Height above the table is not a field: consumers get it from `center_3d` via TF.

- *One depth value per contour point:* rejected; contour pixels lie on the edge, where the depth mixes the object
  with the table behind it.
- *An oriented 3D bounding box:* rejected for now; no use case needs the orientation yet.

## 2026-10-01: `PageList.msg`, `Page.msg` corner order documented

### What changed

New `PageList` (header + `Page[] pages`) for `page_locator`, added to `rosidl_generate_interfaces()`. `Page.msg` gets
a comment: corners are raw camera pixels in the order top left, bottom left, bottom right, top right, and `id` is the
page number (markers `4n .. 4n + 3`). No new dependencies (`std_msgs` is already declared).

### Why / alternatives

The old VIGITIA node published one `Page` per message and only when a page moved, so a removed page was never
announced. `page_locator` now publishes all current pages as one list for every fiducials message, like
`FiducialsList`; an absent page means it is gone. The corner order is the old node's and is kept so ported consumers
keep working; it is written down because it differs from `Fiducial` (top left, top right, ...).

- *Keep single `Page` messages and add a "removed" flag:* rejected; consumers would have to track state, and the list
  is the convention every other detector here follows.
- *Reorder the corners to match `Fiducial`:* rejected for now; nothing in the new framework uses `Page` yet, but old
  VIGITIA consumers expect this order.

## 2026-10-10: `Gesture.msg` reworked, new `GestureList.msg`

### What changed

`Gesture.msg` replaces the VIGITIA fields (`string hand_observation_id`, `type`, bare `x`, `y`, `z`) with
`uint64 hand_id`, `handedness`, `gesture_type` (constants `PINCH`, `PINCH_OPEN`, `POINT`), a `geometry_msgs/Point
position` in the table frame, the thumb-index `distance` in metres and in palm lengths, and a pointing ray
(`ray_valid`, `ray_origin`, `ray_direction`, `ray_hit`). New `GestureList` (header + `Gesture[] gestures`), added to
`rosidl_generate_interfaces()`. No new dependencies (`geometry_msgs` is already declared in `CMakeLists.txt` and
`package.xml`).

### Why / alternatives

The new `gesture_detector` node publishes the current gesture of every hand per frame. The old fields had no frame, a
string id that did not match `HandLandmarks.id`, and no room for a distance or a ray. Positions are in the table
frame (`world`, metres), the framework's common coordinates, so consumers map them to the projector with
`par_geometry.table_to_projector`. `type` became `gesture_type`, as the old TODO asked (`type` shadows a Python
builtin). The palm-length distance exists because without a depth camera there is no metric one.

- *Keep `Gesture.msg` and add new message names:* rejected; nothing consumes `Gesture`, so a second, similar message
  would only add confusion.
- *One event message per gesture start/end (as the VIGITIA node published):* rejected; a per-frame list like
  `HandLandmarksList` keeps the detector stateless towards consumers, which derive clicks or holds themselves.
- *Projector pixels in the message:* rejected; that would tie the detector to the projector calibration.

## 2026-10-12: `Gesture.msg` gets `pixel` and `position_valid`

### What changed

`Gesture.msg` gets `geometry_msgs/Point pixel` (the gesture point in camera pixels, always set) and
`bool position_valid` before `position`. The header comment says `frame_id` applies to `position` and the ray.

### Why / alternatives

`gesture_detector` should also work without calibration, e.g. with a bare webcam. Without intrinsics and camera pose
there is no table position, so the gesture needs a location that never depends on calibration.

- *Reusing `position` with the camera frame as `frame_id` and pixels in x/y:* rejected; the unit of `position` would
  silently depend on `frame_id`, and a consumer that does not check it reads pixels as metres.
- *NaN in `position` instead of a flag:* rejected; NaN propagates silently through arithmetic, and `ray_valid` already
  sets the flag pattern in this message.

## 2026-10-12: `ProjectionMapping.msg` gets `projector_center`

### What changed

`ProjectionMapping.msg` gets `bool projector_center_valid` and `geometry_msgs/Point projector_center`, the
projector's optical centre in the table frame, in metres. No new dependencies (`geometry_msgs` is already declared in
`CMakeLists.txt` and `package.xml`).

### Why / alternatives

The projection mask (`ros2-par-framework-projection-mask`) has to find the projector pixel that lights a point above
the table, e.g. a hand. The homography only covers the table plane; with the centre, the point is projected along its
projector ray onto the table and then through the homography. The centre is calibrated with a raised board and
travels with the mapping, because it belongs to the same projector setup and goes stale with it.

- *All-zero coordinates as "not calibrated":* rejected; the message already uses explicit validity flags
  (`Gesture.msg`), and a consumer that skips the check would use the table origin as the centre.
- *A second homography for a raised plane instead of the centre:* rejected; it fixes one more height, while the
  centre covers every height with three numbers.
- *A separate message and topic:* rejected; the centre is only meaningful together with this homography, and two
  latched topics could disagree after a recalibration.

## 2026-10-22: Package renamed to `par_framework_interfaces`

### What changed

`<name>` in `package.xml` and `project()` in `CMakeLists.txt` are now `par_framework_interfaces` (formerly
`custom_interfaces`); the README uses the new name and tells how to port VIGITIA nodes that still import
`custom_interfaces`. Every consumer was renamed in the same pass (see `claude_usage_documentation.md` in
`ros2-par-framework`).

### Why / alternatives

The old name described how the package came to exist rather than what it contains.

- *A compatibility package under the old name:* rejected; nothing outside the framework's repositories needs it.

## 2026-10-28: `Page.msg` corners clockwise

### What changed

The comment now gives the corner order top left, top right, bottom right, bottom left, which `page_locator` publishes
from now on. Comment only: the fields and the type hash are unchanged.

### Why / alternatives

The same order as `Fiducial` and every other quad in the framework; the old order was kept only for VIGITIA consumers
that are not part of the framework (reasoning in `claude_usage_documentation.md` of the `page_locator` repository).

## 2026-11-06: `FIST` gesture in `Gesture.msg`

### What changed

New constant `FIST="fist"` (all four fingers curled in); `pixel`/`position` of a fist are the mean of the fingers'
middle joints, `distance` and `distance_palm_lengths` are -1. The PINCH comment says "not stretched" instead of
"curled" for middle, ring and pinky, as `gesture_detector` now checks.

### Why / alternatives

`gesture_detector` publishes the fist as its own gesture; with depth, its height above the table is the basis for
detecting knocks later.

- *A separate message for hand postures:* rejected; the fist is one more `gesture_type` with the same fields, so a new
  message would duplicate `Gesture`.

## 2026-11-14: `UpdateModel.model_name` renamed to `model_file_name`

### What changed

The request field of `srv/UpdateModel.srv` is `model_file_name`; comments say what it holds (a weights file in the
detector's `models_dir`, empty for the detector's `model_file_name` parameter) and what `success` means (false: the
detector keeps its current model). Callers: `object_detector` (server) and `transfer_learning_service` in
`ros2-par-framework-object-teaching` (client), both updated.

### Why / alternatives

The field carries a file name, not a model's display name; the detector's parameter has the same name now, so the
request and the setting read alike.

- *Keeping `model_name` and only documenting it:* rejected; it avoids an interface change, but leaves the one name in
  the chain that does not say it is a file.

## 2026-11-18: Unused VIGITIA services removed, `sensor_msgs` dropped

### What changed

- Removed `GetExtrinsicCalibration`, `GetHomography`, `GetIntrinsicCalibration`, `GetProjectionAreaFrame`,
  `GetProjectionCorners` and `GetTransformedCoordinates` from `srv/` and `rosidl_generate_interfaces()`. No package
  of the framework used them.
- `GetProjectionAreaFrame` was the only interface referencing `sensor_msgs`, so `sensor_msgs` is gone from
  `find_package`, `DEPENDENCIES` and `package.xml`. No framework package relied on getting it through this one.
- `Fiducial.msg` documents `angle`: the top edge (vertex 0 to 1) against the image x axis, whole degrees, 0 to 359,
  clockwise in the image, as `fiducials_detector` computes it.
- `CMakeLists.txt` explains why the copyright linter and cpplint are skipped: the license is declared once in
  `package.xml` without per-file headers, and the package has no C++ code.
- README: the title no longer says "Custom", and the import example uses `SetProjectionMapping`.

### Why / alternatives

The removed services are VIGITIA's pull-style calibration round trips. `/projection_mapping`, `/projection_corners`,
`camera_info` and TF replace them, and `par_geometry` converts points locally. `GetProjectionAreaFrame` also sent
images through a service, which the framework avoids.

- *Keeping them for VIGITIA nodes that are not ported yet:* rejected; a node being ported has to move to the
  framework's topics anyway, and git history keeps the definitions.
- *Copyright headers in every file so the linter can run:* rejected; one license declaration in `package.xml` is
  enough for a package of message definitions.
