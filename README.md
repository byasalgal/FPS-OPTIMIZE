# KernelSU Dynamic FPS Module

This module simulates dynamic FPS behavior on devices without hardware variable refresh rate (like Galaxy Note 10), by reducing SurfaceFlinger and animation workload on idle.

### Features:
- Detects idle state by monitoring SurfaceFlinger CPU usage.
- Reduces animation/rendering load on idle.
- Restores full UI speed on touch/activity.

### Requirements:
- Rooted Android with KernelSU
- Android 10–15

### Install:
1. Clone or download repo
2. Push to `/data/adb/modules/kernelsu-dynamic-fps/`
3. Reboot

### Author:
[@byaslgal](https://github.com/byasalgal)
