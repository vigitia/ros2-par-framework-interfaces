# A single detected fiduical marker (e.g. an ArUco Marker)

int64 id

# Angle in whole degrees, 0 to 359
int32 angle

# vertices
float64 x0
float64 y0
float64 x1
float64 y1
float64 x2
float64 y2
float64 x3
float64 y3

# centroid
float64 x_centroid
float64 y_centroid

# Added with the help of Claude Code:
# The four vertices in the camera's optical frame (x right, y down, z forward), in metres, in the same order as
# x0/y0 ... x3/y3. From a depth image registered to the Colour/IR image (fiducials_detector with use_depth, e.g. the
# Azure Kinect): a plane fitted to the depth inside the marker, intersected with the vertices' rays.
# Empty without use_depth, or when the marker has too little valid depth.
geometry_msgs/Point[] corners_3d
