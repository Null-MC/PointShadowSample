import type {} from 'iris'


export function initShader(dimension : NamespacedId) {
    worldSettings.disableShade = false;
    worldSettings.ambientOcclusionLevel = 1.0;

    pointShadowSettings.nearPlane = 0.1;
    pointShadowSettings.farPlane = 16.0;
    pointShadowSettings.maxCount = getIntSetting('POINT_SHADOW_MAX_COUNT');
    pointShadowSettings.resolution = getIntSetting('POINT_SHADOW_RESOLUTION');
    pointShadowSettings.cacheRealTimeTerrain = true;
}

function applySettings() {
    pointShadowSettings.realTimeCount = getIntSetting('POINT_SHADOW_REALTIME_COUNT');
    pointShadowSettings.maxUpdates = getIntSetting('POINT_SHADOW_MAX_UPDATES');
    pointShadowSettings.updateThreshold = getIntSetting('POINT_SHADOW_THRESHOLD') * 0.01;
}

export function setupShader(dimension : NamespacedId) {
    defineGlobally('POINT_SHADOW_MAX_COUNT', pointShadowSettings.maxCount);

    const texFinal = new Texture('texFinal')
        .format(Format.RGBA16F)
        .width(screenWidth)
        .height(screenHeight)
        .mipmap(false)
        .clear(false)
        .build();

    registerShader(new ObjectShader('point-shadow', Usage.POINT)
        .vertex('gbuffer/shadow-point.vsh')
        .fragment('gbuffer/shadow-point.fsh')
        .build());

    registerShader(new ObjectShader('skybox', Usage.SKYBOX)
        .vertex('gbuffer/skybox.vsh')
        .fragment('gbuffer/skybox.fsh')
        .target(0, texFinal)
        .build());

    registerShader(new ObjectShader('terrain', Usage.TEXTURED)
        .vertex('gbuffer/basic.vsh')
        .fragment('gbuffer/basic.fsh')
        .target(0, texFinal)
        .define('RENDER_TERRAIN', '1')
        .build());

    registerShader(new ObjectShader('entities', Usage.ENTITY_SOLID)
        .vertex('gbuffer/basic.vsh')
        .fragment('gbuffer/basic.fsh')
        .target(0, texFinal)
        .define('RENDER_ENTITIES', '1')
        .build());

    setCombinationPass(new CombinationPass('gbuffer/final.fsh')
        .build());

    applySettings();
}

export function onSettingsChanged(state : WorldState) {
    applySettings();
}
