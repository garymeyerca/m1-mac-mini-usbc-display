# M1 Mac mini direct USB-C display test

Hardware: M1 Mac mini (2020, `apple,j274`) and ASUS PA329CRV, connected
directly by USB-C. Software: m1n1 v1.6.1; experimental Aurora
[Thunderbolt/display series](https://github.com/aurora-silicon/linux/pull/8)
at `9632d3ecdedc`, plus the local `t8103-jxxx.dtsi` alias patch.

## 2026-09-29: Device-tree handoff and console test

The prior handoff lacked the m1n1 v1.6.1 USB4 aliases expected by this kernel.
With the patched `t8103-j274.dtb`, both live ACIO nodes had nonempty
`apple,tunable-rc`, `apple,tunable-nhi`, and `apple,thunderbolt-drom` properties.
Both ACIO platform devices bound to `thunderbolt-apple-acio`.

With a Satechi Multiport Pro and the ASUS monitor both attached, the Satechi
port acquired the display crossbar route. The ASUS port's Type-C mux returned
`-EBUSY`. After unplugging the Satechi and reconnecting the monitor, the ASUS
port acquired the route. DRM `USB-2` became connected, returned a 256-byte
EDID, and completed a 3840 × 2160, 60 Hz modeset. The monitor showed a picture.

## 2026-09-29: Desktop and persistent boot

The desktop kernel `7.1.12-usbcdp+` booted with
`thunderbolt_apple.dp_display=1`. The `asahi`, `appledrm`, and
`thunderbolt_apple` modules loaded. Hyprland detected the ASUS PA329CRV on
`USB-2` at 3840 × 2160, 60 Hz, scale 1.6, with no configuration errors.

The initial desktop test had restored the original m1n1 boot bundle after
boot. A later setup kept the patched bundle installed, set the USB-C desktop
GRUB entry as default, and disabled the desktop restore service. The machine
restarted at 10:07 EDT and booted the same USB-C desktop kernel. The patched
bundle was still active, DRM `USB-2` was connected, and Hyprland again drove
the ASUS monitor at 3840 × 2160, 60 Hz. The USB-C controller retry unit
completed successfully.

This verifies one direct-display reconnect, a desktop boot, and one normal
restart with the persistent setup. Repeated hotplug, suspend/resume, docked
display, and longer-term reliability remain untested.
