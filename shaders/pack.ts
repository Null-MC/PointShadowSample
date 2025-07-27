import type {} from 'iris'

const pointShadow_regionSize = 128;
const pointShadow_binSize = 8;


export function configureRenderer(renderer : RendererConfig) {
    renderer.disableShade = false;
    renderer.ambientOcclusionLevel = 1.0;
    renderer.mergedHandDepth = true;

    // all point lights have 0.1m radius, and max of 16m falloff
    renderer.pointLight.nearPlane = 0.1;
    renderer.pointLight.farPlane = 16.0;

    renderer.pointLight.maxCount = getIntSetting('POINT_SHADOW_MAX_COUNT');
    renderer.pointLight.resolution = getIntSetting('POINT_SHADOW_RESOLUTION');

    // enabling this option caches terrain rendering, and only does realtime updates for entities
    renderer.pointLight.cacheRealTimeTerrain = true;

    renderer.shadow.enabled = false;

    applyRealTimeSettings(renderer);
}

function applyRealTimeSettings(renderer: RendererConfig) {
    renderer.pointLight.realTimeCount = getIntSetting('POINT_SHADOW_REALTIME_COUNT');
    renderer.pointLight.maxUpdates = getIntSetting('POINT_SHADOW_MAX_UPDATES');
    renderer.pointLight.updateThreshold = getIntSetting('POINT_SHADOW_THRESHOLD') * 0.01;
}

export function configurePipeline(pipeline : PipelineConfig) {
    // Custom Light Colors
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

    const renderConfig = pipeline.getRendererConfig();

    // Define Global Settings
    let lightListEnabled = false;
    let lightListBinCount = 0;

    // only define settings when point light shadows are enabled
    if (renderConfig.pointLight.maxCount > 0) {
        defineGlobally('POINT_SHADOW_ENABLED', 1);
        defineGlobally('POINT_SHADOW_MAX_COUNT', renderConfig.pointLight.maxCount);

        if (getBoolSetting('POINT_SHADOW_DEBUG'))
            defineGlobally('POINT_SHADOW_DEBUG', 1);

        lightListEnabled = getBoolSetting('POINT_SHADOW_BIN_ENABLED');

        if (lightListEnabled) {
            defineGlobally('POINT_SHADOW_BIN_ENABLED', 1);
            defineGlobally('POINT_SHADOW_BIN_REGION', pointShadow_regionSize);
            defineGlobally('POINT_SHADOW_BIN_SIZE', pointShadow_binSize);

            lightListBinCount = getIntSetting('POINT_SHADOW_BIN_COUNT');
            defineGlobally('POINT_SHADOW_BIN_COUNT', lightListBinCount);
        }
    }

    // Create Textures & Buffers
    const texFinal = pipeline.createTexture('texFinal')
        .format(Format.RGBA16F)
        .width(screenWidth)
        .height(screenHeight)
        .mipmap(false)
        .clear(false)
        .build();

    let lightListBuffer: BuiltBuffer | null = null;
    if (lightListEnabled) {
        const binByteSize = 4 * (2 + lightListBinCount);
        const binsPerAxis = Math.ceil(pointShadow_regionSize / pointShadow_binSize);
        const bufferSize = binByteSize * cubed(binsPerAxis) + 4;
        print(`Light-List Buffer Size: ${bufferSize.toLocaleString()}`);

        lightListBuffer = pipeline.createBuffer(bufferSize, false);
    }

    // Build Shader Pipeline
    if (lightListEnabled) {
        const preRenderQueue = pipeline.forStage(Stage.PRE_RENDER);

        const binsPerAxis = Math.ceil(pointShadow_regionSize / pointShadow_binSize);
        const binGroupCount = Math.ceil(binsPerAxis / 4);

        // reset all light bin counters to zero
        preRenderQueue.createCompute('light-list-clear')
            .location('pre/light-list-clear.csh')
            .workGroups(binGroupCount, binGroupCount, binGroupCount)
            .ssbo(0, lightListBuffer)
            .compile();

        const pointGroupCount = Math.ceil(renderConfig.pointLight.maxCount / (4*4*4));

        // populate local light bins from global light list
        preRenderQueue.createCompute('light-list')
            .location('pre/light-list.csh')
            .workGroups(pointGroupCount, pointGroupCount, pointGroupCount)
            .ssbo(0, lightListBuffer)
            .compile();

        preRenderQueue.barrier(SSBO_BIT);

        // populate neighboring local light bins with current bins data
        preRenderQueue.createCompute('light-list-neighbors')
            .location('pre/light-list-neighbors.csh')
            .workGroups(binGroupCount, binGroupCount, binGroupCount)
            .ssbo(0, lightListBuffer)
            .compile();

        preRenderQueue.end();
    }

    if (renderConfig.pointLight.maxCount > 0) {
        // depth rendering pass for point-light shadows
        pipeline.createObjectShader('point-shadow', Usage.POINT)
            .vertex('gbuffer/shadow-point.vsh')
            .fragment('gbuffer/shadow-point.fsh')
            .compile();
    }

    pipeline.createObjectShader('skybox', Usage.SKYBOX)
        .vertex('gbuffer/skybox.vsh')
        .fragment('gbuffer/skybox.fsh')
        .target(0, texFinal)
        .compile();

    const terrainShader = pipeline.createObjectShader('terrain', Usage.TEXTURED)
        .vertex('gbuffer/basic.vsh')
        .fragment('gbuffer/basic.fsh')
        .target(0, texFinal)
        .define('RENDER_TERRAIN', '1');

    const entitiesShader = pipeline.createObjectShader('entities', Usage.ENTITY_SOLID)
        .vertex('gbuffer/basic.vsh')
        .fragment('gbuffer/basic.fsh')
        .target(0, texFinal)
        .define('RENDER_ENTITIES', '1');

    const finalPass = pipeline.createCombinationPass('post/final.fsh');

    if (lightListEnabled) {
        terrainShader.ssbo(0, lightListBuffer);
        entitiesShader.ssbo(0, lightListBuffer);
        finalPass.ssbo(0, lightListBuffer);
    }

    terrainShader.compile();
    entitiesShader.compile();
    finalPass.compile();
}

// export function onSettingsChanged(pipeline : PipelineConfig) {
//     const config = pipeline.getRendererConfig();
//     applyRealTimeSettings(config);
// }

// HELPERS

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

function cubed(x) {return x*x*x;}
