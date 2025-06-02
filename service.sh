#!/system/bin/sh

CHECK_INTERVAL=2
IS_LOW=0
LOW_FPS=1
HIGH_FPS=60
FPS_PATH=""

# 📢 Show persistent notification
notify_mode() {
    mode="$1"
    title="FPS-OPTIMIZER"
    text="Mode: $mode"

    if cmd -l 1000 notification post -S bigtext -t "$title" "fpsopt" "$text" > /dev/null 2>&1; then
        : # Android 11+
    else
        am broadcast --user 0 -a fpsopt.NOTIFY --es mode "$mode"
    fi
}

# 🔍 Detect real refresh_rate sysfs path
detect_fps_path() {
    for path in \
        "/sys/class/drm/card0-DSI-1/refresh_rate" \
        "/sys/class/drm/card0/card0-DSI-1/refresh_rate" \
        "/sys/class/drm/card0-eDP-1/refresh_rate" \
        "/sys/class/graphics/fb0/device/drm/card0/card0-eDP-1/refresh_rate"
    do
        if [ -e "$path" ]; then
            FPS_PATH="$path"
            log -t FPSOPT "Detected FPS path: $FPS_PATH"
            return
        fi
    done

    FPS_PATH=""
    log -t FPSOPT "No hardware FPS path, using simulation"
}

# ⚙️ Apply Low-Power Mode
apply_low_mode() {
    # UI Tuning
    settings put global animator_duration_scale 0.0
    settings put global transition_animation_scale 0.0
    settings put global window_animation_scale 0.0
    setprop debug.sf.disable_backpressure 1

    # CPU Power Save
    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
        echo powersave > "$cpu/cpufreq/scaling_governor" 2>/dev/null
        echo 800000 > "$cpu/cpufreq/scaling_max_freq" 2>/dev/null
    done

    # Brightness Down
    settings put system screen_brightness 30

    # FPS (real if available)
    if [ -n "$FPS_PATH" ]; then
        echo "$LOW_FPS" > "$FPS_PATH"
        log -t FPSOPT "Set FPS to $LOW_FPS (real)"
    else
        log -t FPSOPT "Simulating low FPS mode"
    fi

    notify_mode "Low Power"
    log -t FPSOPT "Low-power mode ON"
    IS_LOW=1
}

# ⚙️ Apply Performance Mode
apply_high_mode() {
    # UI Restore
    settings put global animator_duration_scale 1.0
    settings put global transition_animation_scale 1.0
    settings put global window_animation_scale 1.0
    setprop debug.sf.disable_backpressure 0

    # CPU Full Speed
    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
        echo performance > "$cpu/cpufreq/scaling_governor" 2>/dev/null
        echo 1984000 > "$cpu/cpufreq/scaling_max_freq" 2>/dev/null
    done

    # Brightness Restore
    settings put system screen_brightness 150

    # FPS (real if available)
    if [ -n "$FPS_PATH" ]; then
        echo "$HIGH_FPS" > "$FPS_PATH"
        log -t FPSOPT "Set FPS to $HIGH_FPS (real)"
    else
        log -t FPSOPT "Simulating high FPS mode"
    fi

    notify_mode "Performance"
    log -t FPSOPT "High-power mode ON"
    IS_LOW=0
}

# 🚀 Start
detect_fps_path

while true; do
    sf_cpu=$(top -n 1 -b | grep SurfaceFlinger | awk '{print int($9)}')

    if [ "$sf_cpu" -lt 2 ]; then
        [ "$IS_LOW" -eq 0 ] && apply_low_mode
    else
        [ "$IS_LOW" -eq 1 ] && apply_high_mode
    fi

    sleep "$CHECK_INTERVAL"
done
