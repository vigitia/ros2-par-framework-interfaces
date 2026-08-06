# ros2-par-framework-interfaces

Readme written mostly with Claude Code

Shared ROS 2 message, service and action definitions for the
[PAR framework](https://github.com/vigitia/ros2-par-framework) — the contract every node in the framework
talks over. Provides the package `custom_interfaces`.

You do not need to clone this repository directly: it is listed in the framework's `config/nodes.list`, and
`./setup.sh` there checks it out into the workspace along with the nodes.

## Using it from a node

```xml
<!-- package.xml -->
<depend>custom_interfaces</depend>
```

```python
from custom_interfaces.msg import Object, ObjectList
from custom_interfaces.srv import GetHomography
```

## Adding an interface

1. Add the `.msg`, `.srv` or `.action` file under `msg/`, `srv/` or `action/`.
2. Register its path in `rosidl_generate_interfaces()` in `CMakeLists.txt` — a file that is not listed there
   is simply not generated, with no warning.
3. If it references a package not already used (`std_msgs`, `geometry_msgs`, `sensor_msgs`, …), declare it in
   **both** the `DEPENDENCIES` list in `CMakeLists.txt` **and** as `<depend>` in `package.xml`. The framework's
   container image installs dependencies from `package.xml` alone, so a package declared only to CMake builds
   by luck — it works as long as the base image happens to ship it.

This package is `ament_cmake` rather than `ament_python` because `rosidl_generate_interfaces()` is a CMake
macro. Interface generation is not available to Python packages, which is why these definitions live in a
package of their own instead of alongside the nodes that use them.

## Note on the package name

`custom_interfaces` is inherited from the earlier VIGITIA framework, where nodes already import it under that
name. Keeping it means those nodes port over without touching a single import, which is the only reason it is
still called that.

It is not a good name in the long run — it describes how the package came to exist rather than what it
contains, and it will read as generic next to the other packages in the framework. Something like
`par_framework_interfaces` or `par_interfaces` would be more fitting.

Renaming is mechanical but touches every consumer: the `<name>` in `package.xml`, `project()` in
`CMakeLists.txt`, the `<depend>` entry in each node's `package.xml`, every Python import, and the entry in the
framework's `config/nodes.list`. That cost only grows as nodes are added, so if the old VIGITIA nodes are ever
migrated rather than ported as-is, do the rename in the same pass.
