#version 430 core

in CustomVertexData {
    vec4 color;
    vec2 light;
    vec2 uv;
    vec3 localPos;
    vec3 localNormal;
    //vec3 viewNormal;

    #ifdef RENDER_TERRAIN
        flat uint blockId;
    #endif
} vIn;

layout(location = 0) out vec4 outColor;

uniform samplerCubeArrayShadow pointLightFiltered;

#include "/lib/common.glsl"

#ifdef POINT_SHADOW_ENABLED
    #ifdef POINT_SHADOW_BIN_ENABLED
        #include "/lib/light-list/buffer.glsl"
        #include "/lib/light-list/common.glsl"
    #endif

    #include "/lib/point-shadow/common.glsl"
    #include "/lib/point-shadow/sample.glsl"
#endif


void iris_emitFragment() {
    vec4 color = iris_sampleBaseTex(vIn.uv) * vIn.color;
    color.rgb = RgbToLinear(color.rgb);

    // Alpha test.
    if (iris_discardFragment(color)) {discard; return;}

    vec2 lmcoord = vIn.light;

    #ifdef POINT_SHADOW_ENABLED
        bool isInPointShadowBounds = pointShadow_isInBounds(vIn.localPos);

        if (isInPointShadowBounds) lmcoord.x = (0.5/16.0);
    #endif

    // Basic directional sky lighting
    vec3 viewNormal = normalize(mat3(ap.camera.view) * vIn.localNormal);
    vec3 skyLightViewDir = normalize(ap.celestial.pos);
    lmcoord.y *= max(0.2, dot(viewNormal, skyLightViewDir) * 0.5 + 0.5);

    vec3 lightmap = iris_sampleLightmap(lmcoord).rgb;

    #ifdef POINT_SHADOW_ENABLED
        if (isInPointShadowBounds) {
            vec3 localNormal = normalize(vIn.localNormal);
            vec3 pointLighting = shadowPoint_sampleAll(vIn.localPos, localNormal);

            #ifdef RENDER_TERRAIN
                // for terrain only, apply self-emission to replace lightmap block light
                int emission = iris_getEmission(vIn.blockId);
                pointLighting += emission / 15.0;
            #endif

            // apply a simple tonemap to only point-lighting
            lightmap += pointLighting / (1.0 + pointLighting);
        }
    #endif

    outColor = color * vec4(lightmap, 1.0);

    float viewDist = length(vIn.localPos);

    // Basic fog. This takes care of "environmental" fog, which is the fog that is applied to the camera selectively.
    outColor = mix(outColor, ap.world.fogColor, smoothstep(ap.world.fogStart, ap.world.fogEnd, viewDist));

    // This is the "border" fog, which is applied to the edges of the render distance.
    outColor = mix(outColor, ap.world.fogColor, max(0.0, smoothstep(ap.camera.renderDistance - 3, ap.camera.renderDistance, viewDist)));
}
