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
