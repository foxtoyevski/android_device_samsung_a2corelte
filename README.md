# android_device_samsung_a2corelte

LineageOS 17.1 (Android 10) device tree for Samsung Galaxy A2 Core (a2corelte, Exynos 7870).

## Dependencies

- Common tree: [foxtoyevski/android_device_samsung_universal7870-common](https://github.com/foxtoyevski/android_device_samsung_universal7870-common), branch `lineage-17.1`. A fork of the samsungexynos7870 community tree with a2corelte fixes.
- Source patches: [foxtoyevski/a2corelte-17.1-fixes](https://github.com/foxtoyevski/a2corelte-17.1-fixes). Most boot-critical fixes live in AOSP/Lineage source, not in this tree. Run `apply-fixes.sh` from the source root after `repo sync`.

## Local manifest

Add this to `.repo/local_manifests/a2corelte.xml`, then run `repo sync`:

    <manifest>
      <project name="foxtoyevski/android_device_samsung_a2corelte"
               path="device/samsung/a2corelte"
               remote="github" revision="lineage-17.1" />
      <project name="foxtoyevski/android_device_samsung_universal7870-common"
               path="device/samsung/universal7870-common"
               remote="github" revision="lineage-17.1" />
      <project name="LineageOS/android_packages_resources_devicesettings"
               path="packages/resources/devicesettings"
               remote="github" revision="lineage-17.1" />
    </manifest>

## Credits

- Jan Altensen (stricted), Francesco Duca and the samsungexynos7870 community for universal7870-common
- The LineageOS and CyanogenMod projects

## Notes

Prebuilt blobs in `prebuilt/` belong to their respective owners (Samsung etc.).

## Kernel

`prebuilt/kernel` and `prebuilt/kernel.stock` are prebuilt Linux kernel images. The Linux kernel is licensed under GPL-2.0. Source for the Samsung stock kernel is published by Samsung at https://opensource.samsung.com (search for SM-A260F). The exact source used to build `prebuilt/kernel` is not documented here. If you need it, please open an issue.
