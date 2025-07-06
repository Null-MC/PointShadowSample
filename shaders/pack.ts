import type {} from 'iris'


export function initShader(dimension : NamespacedId) {
    worldSettings.disableShade = false;
    worldSettings.ambientOcclusionLevel = 1.0;
    worldSettings.mergedHandDepth = true;

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
    setLightColorEx('#362b21', 'brown_mushroom');
    setLightColorEx('#f39849', 'campfire');
    setLightColorEx('#935b2c', 'cave_vines', "cave_vines_plant");
    setLightColorEx('#d39f6d', 'copper_bulb', 'waxed_copper_bulb');
    setLightColorEx('#d39255', 'exposed_copper_bulb', 'waxed_exposed_copper_bulb');
    setLightColorEx('#cf833a', 'weathered_copper_bulb', 'waxed_weathered_copper_bulb');
    setLightColorEx('#87480b', 'oxidized_copper_bulb', 'waxed_oxidized_copper_bulb');
    setLightColorEx('#7f17a8', 'crying_obsidian', 'respawn_anchor');
    setLightColorEx('#371559', 'enchanting_table');
    setLightColorEx('#bea935', 'firefly_bush');
    setLightColorEx('#5f9889', 'glow_lichen');
    setLightColorEx('#d3b178', 'glowstone');
    setLightColorEx('#c2985a', 'jack_o_lantern');
    setLightColorEx('#f39e49', 'lantern');
    setLightColorEx('#b8491c', 'lava', 'magma_block');
    setLightColorEx('#650a5e', 'nether_portal');
    setLightColorEx('#dfac47', 'ochre_froglight');
    setLightColorEx('#e075e8', 'pearlescent_froglight');
    setLightColorEx('#f9321c', 'redstone_torch', 'redstone_wall_torch');
    setLightColorEx('#e0ba42', 'redstone_lamp');
    setLightColorEx('#f9321c', 'redstone_ore', 'deepslate_redstone_ore');
    setLightColorEx('#8bdff8', 'sea_lantern');
    setLightColorEx('#918f34', 'shroomlight');
    setLightColorEx('#28aaeb', 'soul_torch', 'soul_wall_torch', 'soul_campfire');
    setLightColorEx('#f3b549', 'torch', 'wall_torch');
    setLightColorEx('#6e0000', 'vault');
    setLightColorEx('#63e53c', 'verdant_froglight');

    setLightColorEx("#322638", "tinted_glass");
    setLightColorEx("#ffffff", "white_stained_glass", "white_stained_glass_pane");
    setLightColorEx("#999999", "light_gray_stained_glass", "light_gray_stained_glass_pane");
    setLightColorEx("#4c4c4c", "gray_stained_glass", "gray_stained_glass_pane");
    setLightColorEx("#191919", "black_stained_glass", "black_stained_glass_pane");
    setLightColorEx("#664c33", "brown_stained_glass", "brown_stained_glass_pane");
    setLightColorEx("#993333", "red_stained_glass", "red_stained_glass_pane");
    setLightColorEx("#d87f33", "orange_stained_glass", "orange_stained_glass_pane");
    setLightColorEx("#e5e533", "yellow_stained_glass", "yellow_stained_glass_pane");

    setLightColorEx("#7fcc19", "lime_stained_glass", "lime_stained_glass_pane");
    setLightColorEx("#667f33", "green_stained_glass", "green_stained_glass_pane");
    setLightColorEx("#4c7f99", "cyan_stained_glass", "cyan_stained_glass_pane");
    setLightColorEx("#6699d8", "light_blue_stained_glass", "light_blue_stained_glass_pane");
    setLightColorEx("#334cb2", "blue_stained_glass", "blue_stained_glass_pane");
    setLightColorEx("#7f3fb2", "purple_stained_glass", "purple_stained_glass_pane");
    setLightColorEx("#b24cd8", "magenta_stained_glass", "magenta_stained_glass_pane");
    setLightColorEx("#f27fa5", "pink_stained_glass", "pink_stained_glass_pane");

    setLightColorEx("#c07047", "candle", "white_candle", "light_gray_candle", "gray_candle", "black_candle",
        "brown_candle", "red_candle", "orange_candle", "yellow_candle", "lime_candle", "green_candle", "cyan_candle",
        "light_blue_candle", "blue_candle", "purple_candle", "magenta_candle", "pink_candle");

    if (pointShadowSettings.maxCount > 0) {
        defineGlobally('POINT_SHADOW_ENABLED', 1);
        defineGlobally('POINT_SHADOW_MAX_COUNT', pointShadowSettings.maxCount);

        if (getBoolSetting('POINT_SHADOW_DEBUG'))
            defineGlobally('POINT_SHADOW_DEBUG', 1);
    }

    const texFinal = new Texture('texFinal')
        .format(Format.RGBA16F)
        .width(screenWidth)
        .height(screenHeight)
        .mipmap(false)
        .clear(false)
        .build();

    if (pointShadowSettings.maxCount > 0) {
        registerShader(new ObjectShader('point-shadow', Usage.POINT)
            .vertex('gbuffer/shadow-point.vsh')
            .fragment('gbuffer/shadow-point.fsh')
            .build());
    }

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


export function hexToRgb(hex: string) {
    const bigint = parseInt(hex.substring(1), 16);
    const r = (bigint >> 16) & 255;
    const g = (bigint >> 8) & 255;
    const b = bigint & 255;
    return {r, g, b};
}

export function setLightColorEx(hex: string, ...blocks: string[]) {
    const color = hexToRgb(hex);
    blocks.forEach(block => setLightColor(new NamespacedId(block), color.r, color.g, color.b, 255));
}
