# USB-C display on an M1 Mac mini running Linux

Field notes and a device-tree alias patch for a direct USB-C DisplayPort
connection on an M1 Mac mini (2020, `apple,j274`, T8103). This work builds on
the experimental [Aurora Thunderbolt/display kernel series](https://github.com/aurora-silicon/linux/pull/8).

## Verified result

An ASUS PA329CRV connected directly to the Mac mini's USB-C port appeared as
DRM `USB-2` and ran at 3840 × 2160, 60 Hz. Hyprland used the display at scale
1.6. The setup also worked after one normal restart with the patched m1n1 boot
bundle and the USB-C desktop kernel selected by GRUB. See
[the test record](docs/RESULT.md) for the sequence and limits.

## What the patch does

The [alias patch](patches/t8103-usb4-m1n1-aliases.patch) adds six underscore
USB4 aliases to `t8103-jxxx.dtsi`, alongside the existing hyphenated aliases.
With m1n1 v1.6.1, these names allow the booted `t8103-j274.dtb` to receive
nonempty ACIO and NHI tunables and Thunderbolt DROM properties. Both ACIO
controllers then bound to `thunderbolt-apple-acio` in the test.

The patch was made against commit
[`9632d3ecdedc`](https://github.com/iconidentify/linux/commit/9632d3ecdedcbcb170620ad222058b8f69679dae)
of the Aurora series. The tested desktop kernel identified itself as
`7.1.12-usbcdp+` and used `thunderbolt_apple.dp_display=1`. The alias patch
alone does not implement DisplayPort tunneling; the Aurora series supplies
the experimental kernel support.

## Display compatibility

The patch addresses the **M1 Mac mini's USB4 device-tree handoff**, not the
ASUS monitor model. Other USB-C monitors that receive DisplayPort video may
work with this kernel series, but this repository verifies only the PA329CRV
connected directly to this machine. A different monitor, cable, port,
resolution, or dock can exercise a different link configuration and needs its
own test.

"USB display" can also mean a DisplayLink or similar USB graphics adapter.
Those send video as USB data and need a separate graphics driver; this patch
does not provide that driver. The alias patch is also specific to T8103-based
M1 devices and is not a general fix for every computer with USB-C.

## Reproducing the test

1. Build the Aurora series for the target machine with the alias patch applied.
   Build a `t8103-j274.dtb` and a kernel with the display and GPU modules.
2. Arrange for m1n1 to load that DTB. On the tested installation, the active
   m1n1 stage-2 boot bundle contained the distribution DTBs, so a test bundle
   replaced only `t8103-j274.dtb`. Keep a verified copy of the original boot
   bundle and a working fallback boot path before replacing it.
3. Boot a separate GRUB entry with `thunderbolt_apple.dp_display=1`. The test
   kernel required `thunderbolt_apple`, `appledrm`, `asahi`, `phy_apple_atc`,
   and `mux_apple_display_crossbar` in its initramfs.
4. Connect the monitor directly by USB-C and check the live device tree,
   `thunderbolt-apple-acio` bindings, `/sys/class/drm/*/status`, the monitor's
   EDID, and the compositor's active mode. With a Satechi Multiport Pro also
   attached, its port took the display crossbar route first; unplugging it and
   reconnecting the monitor let the monitor take the route.

The included [controller retry script](scripts/retry-usbc-controller.sh) and
[systemd unit](scripts/aurora-usbc-controller-retry.service) are the exact
hardware-specific examples used on this Mac mini. Review device addresses,
driver paths, unit conditions, and timing before using them elsewhere.

## Scope of this repository

This repository contains the source patch, test record, and small supporting
script. It excludes raw diagnostic captures, EFI boot bundles, kernels,
initramfs images, recovery credentials, and machine-specific GRUB entries.
Those artifacts may contain private information or be unsafe to reuse on
another machine. Hotplug reliability, docked display, and suspend/resume have
not been established.
