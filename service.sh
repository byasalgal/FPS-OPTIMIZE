#!/system/bin/sh

CHECK_INTERVAL=2
IS_LOW=0
LOW_FPS=1
HIGH_FPS=60
FPS_PATH=""

logtag="FPSOPT"

# 📢 Persistent notification
notify_mode() {
    local mode="$1"
    if cmd -l 1000 notification post -S bigtext -t "FPS-OPTIMIZER" "fpsopt" "Mode: $mode" >/dev/null 2>&1; then
        : # works on Android 11+
    else
        am broadcast --user 0 -a fpsopt.NOTIFY --es mode "$mode"
    fi
}

# 🔍 Detect real sysfs FPS path
detect_fps_path() {
    for path in \
        "/sys/class/drm/card0-DSI-1/refresh_rate" \
        "/sys/class/drm/card0/card0-DSI-1/refresh_rate" \
        "/sys/class/drm/card0-eDP-1/refresh_rate" \
        "/sys/class/graphics/fb0/device/drm/card0/card0-eDP-1/refresh_rate"
    do
        [ -e "$path" ] && FPS_PATH="$path" && log -t "$logtag" "Detected FPS path: $FPS_PATH" && return
    done

    log -t "$logtag" "No FPS path detected; simulation mode"
}

# ⚙️ Low power mode
apply_low_mode() {
    settings put global animator_duration_scale 0
    settings put global transition_animation_scale 0
    settings put global window_animation_scale 0
    setprop debug.sf.disable_backpressure 1

    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
        echo powersave > "$cpu/cpufreq/scaling_governor" 2>/dev/null
        echo 800000 > "$cpu/cpufreq/scaling_max_freq" 2>/dev/null
    done

    settings put system screen_brightness 30

    if [ -n "$FPS_PATH" ]; then
        echo "$LOW_FPS" > "$FPS_PATH" && log -t "$logtag" "Set FPS to $LOW_FPS"
    else
        log -t "$logtag" "Simulated Low FPS mode"
    fi

    notify_mode "Low Power"
    log -t "$logtag" "Low-power mode applied"
    IS_LOW=1
}

# ⚙️ Performance mode
apply_high_mode() {
    settings put global animator_duration_scale 1
    settings put global transition_animation_scale 1
    settings put global window_animation_scale 1
    setprop debug.sf.disable_backpressure 0

    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
        echo performance > "$cpu/cpufreq/scaling_governor" 2>/dev/null
        echo 1984000 > "$cpu/cpufreq/scaling_max_freq" 2>/dev/null
    done

    settings put system screen_brightness 150

    if [ -n "$FPS_PATH" ]; then
        echo "$HIGH_FPS" > "$FPS_PATH" && log -t "$logtag" "Set FPS to $HIGH_FPS"
    else
        log -t "$logtag" "Simulated High FPS mode"
    fi

    notify_mode "Performance"
    log -t "$logtag" "High-power mode applied"
    IS_LOW=0
}

# 🚀 Main loop
detect_fps_path

while :; do
    sf_cpu=$(top -n 1 -b | grep -m1 SurfaceFlinger | awk '{print int($9)}')
    if [ -z "$sf_cpu" ]; then
        log -t "$logtag" "SurfaceFlinger CPU not found"
    elif [ "$sf_cpu" -lt 2 ]; then
        [ "$IS_LOW" -eq 0 ] && apply_low_mode
    else
        [ "$IS_LOW" -eq 1 ] && apply_high_mode
    fi
    sleep "$CHECK_INTERVAL"
done
