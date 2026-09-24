# Written by Claude Code
# Corners of the projected image as seen by the camera, in pixels of the raw camera image.
# Published latched (Transient Local) on /projection_corners: subscribers must request Transient
# Local as well, or they only receive the next change.

# stamp: when the corners were selected; frame_id: optical frame of the camera the pixels belong to
std_msgs/Header header

# Camera resolution the pixels refer to
uint32 image_width
uint32 image_height

# x, y in pixels, z unused
geometry_msgs/Point top_left
geometry_msgs/Point top_right
geometry_msgs/Point bottom_right
geometry_msgs/Point bottom_left
