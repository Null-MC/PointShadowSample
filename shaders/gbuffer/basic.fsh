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

#include "/lib/shadow-point/common.glsl"
#include "/lib/shadow-point/sample-common.glsl"
#include "/lib/shadow-point/sample-geo.glsl"


void iris_emitFragment() {
    vec4 color = iris_sampleBaseTex(vIn.uv) * vIn.color;

    // Alpha test.
    if (iris_discardFragment(outColor)) discard;

    vec3 lightmap_block = iris_sampleLightmap(vec2(vIn.light.x, (0.5/16.0))).rgb;
    vec3 lightmap_sky = iris_sampleLightmap(vec2((0.5/16.0), vIn.light.y)).rgb;

    vec3 localNormal = normalize(vIn.localNormal);

    #if POINT_SHADOW_MAX_COUNT > 0
        if (shadowPoint_isInBounds(vIn.localPos)) {
            lightmap_block = sample_AllPointLights(vIn.localPos, localNormal);
        }
    #endif

    // Basic directional lighting
    lightmap_sky *= max(0.2, (dot(normalize(vIn.viewNormal), normalize(ap.celestial.pos)) * 0.5 + 0.5));

    outColor = color * vec4(lightmap_sky + lightmap_block, 1.0);

    float viewDist = length(vIn.localPos);

    // Basic fog. This takes care of "environmental" fog, which is the fog that is applied to the camera selectively.
    outColor = mix(outColor, ap.world.fogColor, smoothstep(ap.world.fogStart, ap.world.fogEnd, viewDist));

    // This is the "border" fog, which is applied to the edges of the render distance.
    outColor = mix(outColor, ap.world.fogColor, max(0.0, smoothstep(ap.camera.renderDistance - 3, ap.camera.renderDistance, viewDist)));
}
