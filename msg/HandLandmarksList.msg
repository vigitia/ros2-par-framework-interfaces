# All hands detected in one camera frame.
# Published for every processed frame, also when no hand is visible.
# So an empty list means "no hands" while a missing message means "no frame processed".

std_msgs/Header header
HandLandmarks[] hands
