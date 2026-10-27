# Written with the help of Claude Code
# One hand's current gesture. gesture_detector publishes all gestures of a frame together as GestureList.

# stamp: copied from the camera image the hand landmarks were detected in. frame_id: the table frame (world), in which
# position and the ray are given, in metres; the table is its plane z = 0. pixel is in the camera image.
std_msgs/Header header

# Tracking id and "Left" / "Right" of the hand, as in HandLandmarks.msg
uint64 hand_id
string handedness

# Thumb and index fingertip together; middle, ring and pinky finger curled
string PINCH="pinch"
# Following a PINCH of the same hand: the same posture, thumb and index fingertip apart again
string PINCH_OPEN="pinch_open"
# Index finger stretched; middle, ring and pinky finger curled
string POINT="point"
string gesture_type

# PINCH, PINCH_OPEN: midpoint between thumb and index fingertip. POINT: index fingertip.
# pixel: that point in pixels of the camera image (z = 0), always set, so also without any calibration.
geometry_msgs/Point pixel
# position: the same point in the table frame. Measured in 3D with a depth camera (needs the camera pose); without
# one, where the camera ray through the pixel hits the table (needs the camera pose and calibrated intrinsics).
# position_valid is false when neither is possible; position is then (0, 0, 0).
bool position_valid
geometry_msgs/Point position

# PINCH, PINCH_OPEN: distance between thumb and index fingertip in metres; -1 without depth at both tips. POINT: -1.
float64 distance
# The same distance in palm lengths (wrist to middle finger knuckle), measured in the camera image, so also without a
# depth camera. POINT: -1.
float64 distance_palm_lengths

# POINT only: the ray along the index finger (knuckle to tip, starting at the tip) and where it hits the table.
# ray_valid is false without depth at index knuckle and tip, and when the finger points away from the table.
bool ray_valid
geometry_msgs/Point ray_origin
# Unit vector
geometry_msgs/Vector3 ray_direction
geometry_msgs/Point ray_hit
