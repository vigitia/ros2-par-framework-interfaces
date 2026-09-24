# Unit comments co-authored by Claude Code

# ID between 0 and 20, see mediapipe documentation for more details
# (0 wrist, 4 thumb tip, 8 index finger tip, 12 middle finger tip, 16 ring finger tip, 20 pinky tip)
uint8 id

# Units depend on the array in HandLandmarks.msg that holds this landmark, see there
float64 x
float64 y
float64 z
