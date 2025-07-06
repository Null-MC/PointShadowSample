import type {} from 'iris'


export function initShader(dimension : NamespacedId) {
    worldSettings.disableShade = false;
    worldSettings.ambientOcclusionLevel = 1.0;

    pointShadowSettings.nearPlane = 0.1;
    pointShadowSettings.farPlane = 16.0;
    pointShadowSettings.maxCount = 64;
    pointShadowSettings.resolution = 256;
    pointShadowSettings.cacheRealTimeTerrain = true;
}

function applySettings() {
    pointShadowSettings.maxUpdates = 4;
    pointShadowSettings.realTimeCount = 4;
    pointShadowSettings.updateThreshold = 0.08;
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
