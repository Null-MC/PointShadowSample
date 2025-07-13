# Point Shadow Sample
A sample shader pack for implementing point-light shadow maps, using the new Aperture pipeline from Iris.

![preview](media/preview.jpg)


## How it Works
The Point-Light manager is enabled when the shader defines a `RendererConfig.pointLight.maxCount` above zero, and is disabled by default. It scans an 8x6x8 region of sections for lights, where each section is 16x16x16 blocks. All lights are "static" by default, and only render once at the time they become active.

A limited number of "real-time" lights can be enabled via `RendererConfig.pointLight.realTimeCount`, which allows the nearest "N" lights to include entity shadows and be updated every frame. This can be expensive for performance so should be kept limited. You can also enable `RendererConfig.pointLight.cacheRealTimeTerrain` which will only render entities every frame, over a cached depth map of terrain.

### Other options
- `RendererConfig.pointLight.resolution`: Sets the resolution (per-face) for all point-light shadow maps.
- `RendererConfig.pointLight.maxUpdates`: The maximum number of shadow maps that can be rendered/updated per-frame. Helps avoid stutters when many lights change state.
- `RendererConfig.pointLight.updateThreshold`: The threshold (as a percentage) that is required for an active light to be replaced with a pending light. Higher values will provide more stable lighting by reducing changes in active vs pending lights; lower values will provide more frequent/immediate updates.
- `RendererConfig.pointLight.nearPlane`: The near-plane for point-light depth maps. Set to `0.1` for a light diameter of `0.2` blocks.
- `RendererConfig.pointLight.farPlane`: The far-plane for point-light depth maps. Set to `16` for vanilla lighting, but you may want to increase for more realistic usages.


# License/Usage
### You may:
- use any and all code in this example for your own projects; including for-profit works.

### You may NOT:
- directly redistribute this example as your own work.
