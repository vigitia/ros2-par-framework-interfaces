# Written by Claude Code
# All gestures of one camera frame. gesture_detector publishes one for every HandLandmarksList, also when no hand makes
# a gesture, so an empty list means "no gesture" while a missing message means "no frame processed". Hands without a
# gesture are not listed.

# stamp: copied from the camera image; frame_id: the table frame (world), as in Gesture.msg
std_msgs/Header header
Gesture[] gestures
