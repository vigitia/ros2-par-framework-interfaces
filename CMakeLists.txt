cmake_minimum_required(VERSION 3.16)
project(par_framework_interfaces)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# find dependencies
find_package(ament_cmake REQUIRED)
find_package(rosidl_default_generators REQUIRED)
find_package(std_msgs REQUIRED)
find_package(geometry_msgs REQUIRED)

rosidl_generate_interfaces(${PROJECT_NAME}
  "action/TransferLearning.action"
  "msg/Fiducial.msg"
  "msg/FiducialsList.msg"
  "msg/Gesture.msg"
  "msg/GestureList.msg"
  "msg/HandLandmark.msg"
  "msg/HandLandmarks.msg"
  "msg/HandLandmarksList.msg"
  "msg/Movement.msg"
  "msg/Object.msg"
  "msg/ObjectList.msg"
  "msg/Page.msg"
  "msg/PageList.msg"
  "msg/ProjectionCorners.msg"
  "msg/ProjectionMapping.msg"
  "srv/AddTrainingData.srv"
  "srv/SetProjectionCorners.srv"
  "srv/SetProjectionMapping.srv"
  "srv/SetPrompt.srv"
  "srv/SetROI.srv"
  "srv/UpdateModel.srv"
  DEPENDENCIES std_msgs geometry_msgs
 )
# uncomment the following section in order to fill in
# further dependencies manually.
# find_package(<dependency> REQUIRED)

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  # The license is declared once in package.xml; the files carry no copyright headers, so
  # the copyright linter is skipped. The package contains no C++ code to run cpplint on.
  set(ament_cmake_copyright_FOUND TRUE)
  set(ament_cmake_cpplint_FOUND TRUE)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()
