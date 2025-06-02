# KernelSU Dynamic FPS Module

This module simulates dynamic FPS behavior on devices without hardware variable refresh rate (like Galaxy Note 10), by reducing SurfaceFlinger and animation workload on idle.

### Features:
- Detects idle state by monitoring SurfaceFlinger CPU usage.
- Reduces animation/rendering load on idle.
- Restores full UI speed on touch/activity.
- Optimizes the kernel
- Dynamically adjusts the cpu/gpu frequency
- Detects for dynamic refresh rate or not

### Requirements:
- Rooted Android with KernelSU
- Android 10–15

### Install:
1. Go into releases and download latest
2. Go into the kernelsu app
3. Click module and install
4. Click FPS-OPTIMIZE.zip
5. And let it do its magic
6. Reboot

### Author:
[@byaslgal](https://github.com/byasalgal)
