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

# The projector's optical centre in the table frame, in metres: every projector pixel's ray starts
# there. With it, a point above the table maps to the pixel that lights it (par_geometry's
# project_to_table, then the homography); the homography alone only covers the table plane.
# Valid only when projector_center_valid is true, i.e. after the calibration with a raised board.
bool projector_center_valid
geometry_msgs/Point projector_center
