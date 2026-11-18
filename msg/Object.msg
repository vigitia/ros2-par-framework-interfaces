# One detected object
# Based on: https://github.com/mgonzs13/yolo_ros/blob/main/yolo_msgs/msg/Detection.msg

std_msgs/Header header

int16 object_id
int16 class_id
string class_name
float32 score

# Currently unused
string id

# Bounding box
float32 bbox_x0
float32 bbox_y0
float32 bbox_x1
float32 bbox_y1

# Center of the object
float32 center_x
float32 center_y

# Segmentation contour
geometry_msgs/Point[] contour

# Hull contour (if there are multiple contours, this wraps them all)
geometry_msgs/Point[] hull_contour

# Added with the help of Claude Code:
# From a depth image registered to the colour image (object_detector with use_depth, e.g. the Azure Kinect), in the
# camera's optical frame (x right, y down, z forward), in metres. The depth is the object's top surface: a low
# percentile of the depth inside its segmentation mask.
# The ray of (center_x, center_y) at the top surface's depth. All 0 without use_depth, or when the object has too
# little valid depth.
geometry_msgs/Point center_3d
# hull_contour on its rays at the top surface's depth, same order. Empty whenever center_3d is 0.
geometry_msgs/Point[] hull_contour_3d
