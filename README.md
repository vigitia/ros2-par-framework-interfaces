# Custom Interfaces for the ROS2 Projected Augmented Reality Framework

Shared ROS 2 message, service and action definitions for the
[PAR framework](https://github.com/vigitia/ros2-par-framework) — the contract every node in the framework
talks over. Provides the package `par_framework_interfaces`.

## Using it from a ROS 2 Node

Add dependency in package.xml:

```xml
<!-- package.xml -->
<depend>par_framework_interfaces</depend>
```

Import what you need in your Python code, e.g.:
```python
from par_framework_interfaces.msg import Object, ObjectList
from par_framework_interfaces.srv import GetHomography
```

## Adding an interface

1. Add the `.msg`, `.srv` or `.action` file under `msg/`, `srv/` or `action/`.
2. Register its path in `rosidl_generate_interfaces()` in `CMakeLists.txt` — a file that is not listed there
   is simply not generated, with no warning.
3. If it references a package not already used (`std_msgs`, `geometry_msgs`, `sensor_msgs`, …), declare it in
   **both** the `DEPENDENCIES` list in `CMakeLists.txt` **and** as `<depend>` in `package.xml`.

This package is `ament_cmake` rather than `ament_python` because `rosidl_generate_interfaces()` is a CMake
macro. Interface generation is not available to Python packages, which is why these definitions live in a
package of their own instead of alongside the nodes that use them.

---

Readme written with the help of Claude Code