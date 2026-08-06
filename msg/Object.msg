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