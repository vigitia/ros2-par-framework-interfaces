# One hand detected by mediapipe.
# The hand_landmarks node publishes all hands of a frame together as HandLandmarksList.

std_msgs/Header header

# Tracking id: stays the same while the hand is tracked.
# A hand that reappears after the tracker dropped it gets a new one
uint64 id

# "Left" or "Right", as classified by mediapipe
string handedness

# Score of the handedness classification, 0.0 - 1.0
float64 confidence

# x, y: pixels in the camera image the header refers to (origin top left, x right, y down).
# z: mediapipe's relative depth. Origin at the wrist, smaller values are closer to the camera. Roughly the scale of
#    x before the pixel conversion, i.e. in image widths, not pixels. Low accuracy.
HandLandmark[] hand_landmarks

# Comments added by Claude Code
# Position in the camera's optical frame (x right, y down, z forward), in metres (ROS 2 wants meters, not mm), from a
# depth image registered to the colour image (hand_landmarks with use_depth, e.g. the Azure Kinect). Same order as
# hand_landmarks. -1, -1, -1 for landmarks without a usable depth (no measurement, outside the image, or too far from
# the rest of the hand, e.g. a fingertip whose depth hit the surface behind it). Empty without use_depth.
HandLandmark[] hand_landmarks_3d
