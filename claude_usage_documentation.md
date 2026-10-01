# Claude Code usage documentation

Changes Claude Code made to this repository, with the reasoning and the alternatives considered.

### `ProjectionCorners.msg` and `SetProjectionCorners.srv` (2026-09-24)

**What:** two new definitions, both added to `rosidl_generate_interfaces()` in `CMakeLists.txt`:
- `msg/ProjectionCorners.msg`: a header (stamp = when the corners were selected, frame_id = the camera's optical
  frame), `image_width`/`image_height`, and `top_left`, `top_right`, `bottom_right`, `bottom_left` as
  `geometry_msgs/Point` in pixels of the raw camera image (z unused).
- `srv/SetProjectionCorners.srv`: a `ProjectionCorners` request, answered with `success` and a `message` that gives
  the reason on failure.

They only reference `std_msgs` and `geometry_msgs`, which were already declared in both `CMakeLists.txt` and
`package.xml`.

**Why:** the corners of the projected image, selected in `surface_selector`, used to live only in a private INI file
in the install space. Now `projection_corners_node` (in `ros2-par-framework`) holds them, publishes them latched on
`/projection_corners`, and stores new ones received through `set_projection_corners`. This mirrors the camera's
`camera_info` / `set_camera_info`.

**Alternatives:**
- *`geometry_msgs/PolygonStamped`:* standard, but RViz offers it as a polygon and would draw the pixel values as
  metres.
- *Reusing the VIGITIA `GetProjectionCorners.srv`:* it is a request/response pull by camera name, with integer
  coordinates. It is left unchanged for ported nodes; nothing uses it currently.
- *A `geometry_msgs/Point[4]` array:* the named fields make the order unambiguous.

**Tested:** built on the host; `ros2 interface show` resolves both types.

## HandLandmarksList and landmark units

**What changed:**
- New `msg/HandLandmarksList.msg` (header + `HandLandmarks[] hands`), listed in `rosidl_generate_interfaces()`. No new
  external package, so `DEPENDENCIES` and `package.xml` are unchanged.
- `HandLandmark.msg` and `HandLandmarks.msg` got comments on units and meaning: `hand_landmarks` x/y are pixels in the
  image the header refers to and z is mediapipe's relative depth in image widths; `hand_landmarks_3d` is the camera
  optical frame in the depth image's unit and currently never filled. Field definitions are unchanged.

**Why:** the hand_landmarks node published one `HandLandmarks` per hand and nothing when no hand was visible, so
consumers (gesture, pointing, the planned touch detection) could not tell "no hands" from "no frames" or when all
hands of a frame had arrived. The list follows `ObjectList` / `FiducialsList`. The units were only knowable by
reading the node source (x/y converted to pixels in place, z left in mediapipe's scale).

**Alternatives:**
- *Arrays directly in one message per frame (flattened landmarks):* would change `HandLandmarks` itself and break the
  element type the ported VIGITIA consumers already know; wrapping keeps it.
- *Units in `HandLandmark.msg`:* the same type holds pixels in one array and camera coordinates in the other, so the
  units are documented on the arrays.

**Tested:** built on the host with the hand_landmarks node; the node published `HandLandmarksList` end to end.

## HandLandmarksList: only hands of the current frame

**What changed:** comment in `HandLandmarksList.msg`: the list holds only the hands detected in that frame; a hand
missing for less than 1 s keeps its id when it reappears but is not listed while missing. No field changes.

**Why:** the hand_landmarks node stopped publishing stale hands (see its documentation), and consumers need to know
that absence from the list does not mean the id is gone.

### `ProjectionMapping.msg` and `SetProjectionMapping.srv` (2026-09-24)

**What:** both are new and added to `rosidl_generate_interfaces()`.
- `msg/ProjectionMapping.msg`:
  - header (`frame_id` = the table frame `world`, stamp = calibration time);
  - `projector_width`/`projector_height`;
  - `float64[9] homography`, row-major: `[u v w] = H [x y 1]`, x/y in metres on the table plane, pixel =
    `(u/w, v/w)`;
  - `reprojection_error`, RMS in projector pixels.
- `srv/SetProjectionMapping.srv`: `ProjectionMapping mapping` → `success`, `message`.

Only `std_msgs` is referenced, already declared.

**Why:** the table-to-projector homography, fitted by `projection_calibrator` (in `surface_selector`) and held by
`projection_mapping_node` (in `ros2-par-framework`), which publishes it latched on `/projection_mapping`. It
replaces VIGITIA's `GetHomography`/`GetTransformedCoordinates` round trips for new nodes. Those legacy definitions
stay for ported code.

**Alternatives:**
- *A camera → projector homography:* the table in metres is the framework's common frame. It carries the lens
  undistortion, and RViz and projection share it.
- *`float32[]` of any length (as in `GetHomography`):* the fixed `float64[9]` states the shape and keeps precision.

**Tested:** built on the host; `ros2 interface show` resolves both; the synthetic end-to-end run in
`ros2-par-framework` used them.

### HandLandmarks.hand_landmarks_3d comment up to date (2026-09-25)

**What:** the comment on `hand_landmarks_3d` in `msg/HandLandmarks.msg` now says what the hand_landmarks node fills
in: metres (not "the unit of the depth image"), in the optical frame, from a depth image registered to the colour
image, only with `use_depth`, and in the same order as `hand_landmarks`. It also says when -1, -1, -1 is used (no
measurement, outside the image, too far from the rest of the hand). "Currently never filled" is gone. Changed on
`main`, at your request.

**Why:** the field is filled since hand_landmarks computes depth per landmark, and `rviz_bridge` draws the hands in
3D from it.

**Tested:** `colcon build --packages-select custom_interfaces` passes. Only a comment changed, so the type hash and
all dependent builds stay as they are.

### Fiducial.corners_3d (2026-09-25)

**What:** `msg/Fiducial.msg` gets `geometry_msgs/Point[] corners_3d`: the four vertices in the optical frame, in metres,
in the order of x0/y0 ... x3/y3, from a plane fitted to the depth inside the marker. Empty without depth. Changed on
`main`, at your request. `geometry_msgs` was already a dependency, so no other edits were needed.

**Why:** fiducials_detector with `use_depth` fills it, and `rviz_bridge` draws the markers in 3D. The new field changes
the type hash, so every package using `Fiducial` must be rebuilt (fiducials_detector, surface_selector, rviz_bridge).

**Tested:** `colcon build --packages-select custom_interfaces`, then the dependents built.

### Object.center_3d and Object.hull_contour_3d (2026-09-29)

**What:** `msg/Object.msg` gets `geometry_msgs/Point center_3d` and `geometry_msgs/Point[] hull_contour_3d`: the
object's centre and hull outline on their rays at the depth of its top surface, in the optical frame, in metres.
`center_3d` is all 0 and `hull_contour_3d` empty without depth. Changed on `main`, at your request.

**Why:** object_detector with `use_depth` fills them, as fiducials_detector fills `Fiducial.corners_3d`, and
`rviz_bridge` draws the objects in 3D.
- Alternative: one depth value per contour point. Rejected: contour pixels lie on the edge, where the depth mixes the
  object with the table behind it.
- Alternative: an oriented 3D bounding box. Rejected for now: no use case needs the orientation yet.
- Height above the table is not a field: consumers get it from `center_3d` via TF.

**Tested:** `colcon build --packages-select custom_interfaces object_detector rviz_bridge` passes. The type hash
changes, so every package using `Object` must be rebuilt.

### `PageList.msg`, `Page.msg` corner order documented (2026-10-01)

**What:** new `PageList` (header + `Page[] pages`) for `page_locator`, added to `rosidl_generate_interfaces()`.
`Page.msg` gets a comment: corners are raw camera pixels in the order top left, bottom left, bottom right, top
right, and `id` is the page number (markers `4n .. 4n + 3`).

**Why:** the old VIGITIA node published one `Page` per message and only when a page moved, so a removed page was
never announced. `page_locator` now publishes all current pages as one list for every fiducials message, like
`FiducialsList`; an absent page means it is gone. The corner order is the old node's and is kept so ported
consumers keep working; it is written down because it differs from `Fiducial` (top left, top right, ...).

**Alternatives:** keep single `Page` messages and add a "removed" flag: rejected, consumers would have to track
state; the list is the convention every other detector here follows. Reorder the corners to match `Fiducial`:
rejected for now, nothing in the new framework uses `Page` yet, but old VIGITIA consumers expect this order.

**Dependencies:** none new (`std_msgs` is already declared).
