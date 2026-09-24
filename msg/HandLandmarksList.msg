# Written by Claude Code
# All hands of one camera frame. Published for every processed frame, also when no hand is visible, so an empty
# list means "no hands" while a missing message means "no frame processed".

# stamp and frame_id: copied from the camera image the landmarks were detected in
std_msgs/Header header
HandLandmarks[] hands
