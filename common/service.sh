# This script will be executed in late_start service mode
# More info in the main Magisk thread

if [ "$(getprop sys.fp.goodix)" == 1 ] || [ -f /system/bin/gx_fpd ]; then
  goodix=true
fi

sleep 15
(
  while true; do
    echo $(pgrep fingerprintd) > /dev/cpuset/foreground/boost/tasks
    renice -n -20 $(pgrep fingerprintd)
    $goodix && {
      echo $(pgrep gx_fpd) > /dev/cpuset/foreground/boost/tasks
      renice -n -20 $(pgrep gx_fpd)
    }
    sleep 800
  done
) &
