#!/usr/bin/env bash
set -euo pipefail

driver=/sys/bus/i2c/drivers/tps6598x
for device in 0-0038 0-003f; do
  [[ -e /sys/bus/i2c/devices/$device ]] || continue
  [[ -L /sys/bus/i2c/devices/$device/driver ]] && continue
  for attempt in 1 2 3 4 5; do
    printf '%s' "$device" > "$driver/bind" || true
    if [[ -L /sys/bus/i2c/devices/$device/driver ]]; then
      printf 'USB-C controller %s bound on attempt %s\n' "$device" "$attempt"
      break
    fi
    sleep 2
  done
  if [[ ! -L /sys/bus/i2c/devices/$device/driver ]]; then
    printf 'USB-C controller %s still unbound after retries\n' "$device" >&2
    exit 1
  fi
done
