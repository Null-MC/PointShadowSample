#version 430 core

#include "/settings.glsl"

in CustomVertexData {
    vec4 color;
    vec2 light;
    vec2 uv;
    vec3 localPos;
    vec3 localNormal;
    vec3 viewNormal;
} vIn;

layout(location = 0) out vec4 outColor;

uniform samplerCubeArrayShadow pointLightFiltered;

#include "/lib/common.glsl"

#if POINT_SHADOW_MAX_COUNT > 0
    #include "/lib/shadow-point/common.glsl"
    #include "/lib/shadow-point/sample.glsl"
#endif


void iris_emitFragment() {
    vec4 color = iris_sampleBaseTex(vIn.uv) * vIn.color;
    color.rgb = RgbToLinear(color.rgb);

    // Alpha test.
    if (iris_discardFragment(color)) {discard; return;}

    bool isInPointShadowBounds = shadowPoint_isInBounds(vIn.localPos);

    vec2 lmcoord = vIn.light;
    if (isInPointShadowBounds) lmcoord.x = (0.5/16.0);

    vec3 lightmap = iris_sampleLightmap(lmcoord).rgb;

    // Basic directional lighting
    // TODO: needs to be moved to lmcoord.y
    vec3 viewNormal = normalize(vIn.viewNormal);
    vec3 skyLightViewDir = normalize(ap.celestial.pos);
    lightmap *= max(0.2, dot(viewNormal, skyLightViewDir) * 0.5 + 0.5);

    #if POINT_SHADOW_MAX_COUNT > 0
        if (isInPointShadowBounds) {
            vec3 localNormal = normalize(vIn.localNormal);
            vec3 pointLighting = shadowPoint_sampleAll(vIn.localPos, localNormal);

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
