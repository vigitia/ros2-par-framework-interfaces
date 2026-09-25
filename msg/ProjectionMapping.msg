# Written by Claude Code
# Maps the table plane to projector pixels. Published latched (Transient Local) on
# /projection_mapping: subscribers must request Transient Local as well, or they only receive
# the next change.

# frame_id: the table frame, whose plane z = 0 is the table (world); stamp: calibration time
std_msgs/Header header

# Projector resolution the pixels refer to
uint32 projector_width
uint32 projector_height

# 3x3 homography, row-major: [u v w] = H [x y 1] with x, y in metres on the table plane, and the
# projector pixel is (u / w, v / w)
float64[9] homography

# RMS reprojection error of the calibration, in projector pixels
float64 reprojection_error
