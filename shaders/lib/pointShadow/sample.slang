public module sample;

import aperture;
import buffers.LightBinBuffer;
import lib.common;
import lib.lightList.common;

extern static const bool POINT_SHADOW_BIN_ENABLED;
extern static const int POINT_SHADOW_MAX_COUNT;

RWStructuredBuffer<LightBinBuffer> lightBin;


float getLightAttenuation(const in float lightDist, const in float lightRange) {
    // normalize and invert the distance factor
    float lightDistF = lightDist / lightRange;
    lightDistF = 1.0 - saturate(lightDistF);

    // square the result for a nicer looking falloff
    return lightDistF*lightDistF;
}

// returns a hardware-filtered point-light shadow map sample
float shadowPoint_sampleShadow(SamplerCubeArrayShadow pointLightFiltered, const in float3 sampleDir, const in float sampleDist, const in uint lightIndex) {
    // normalize depth to NDC space [-1 to +1]
    float ndc_depth = (ap.lights.farPlane + ap.lights.nearPlane - 2.0 * ap.lights.nearPlane * ap.lights.farPlane / sampleDist) / (ap.lights.farPlane - ap.lights.nearPlane);

    // sample the cubemap with hardware-filtering enabled
    return pointLightFiltered.SampleCmp(float4(sampleDir, lightIndex), ndc_depth * 0.5 + 0.5).r;
}

float3 shadowPoint_sampleAll(SamplerCubeArrayShadow pointLightFiltered, const in float3 localPos, const in float3 localNormal) {
    // adjust as-needed/to taste
    const float offsetBias = 0.02;
    const float normalBias = 0.16;

    // apply a normal-based offset to shadow sample position
    float3 localSamplePos = localNormal * normalBias + localPos;

    // initialize accumulated lighting to zero
    float3 accumLighting = float3(0.0);

    int lightBinIndex;
    uint maxLightCount;
    if (POINT_SHADOW_BIN_ENABLED) {
        float3 lightBinPos = lightList_getBinPos(0.02 * localNormal + localPos);
        lightBinIndex = lightList_getBinIndex(int3(lightBinPos));

        // get the light count for the current local bin
        maxLightCount = lightBin[lightBinIndex].lightCountFinal;
        maxLightCount = clamp(maxLightCount, 0u, POINT_SHADOW_BIN_COUNT);
    }
    else {
        // sample all lights in the global array
        maxLightCount = POINT_SHADOW_MAX_COUNT;
    }

    for (uint i = 0u; i < maxLightCount; i++) {
        uint lightIndex;
        if (POINT_SHADOW_BIN_ENABLED) {
            lightIndex = lightBin[lightBinIndex].lightList[i];
        }
        else {
            lightIndex = i;
        }

        // get the point-light data and skip if block is undefined
        PointLight light = ap.lights[lightIndex];

        if (!POINT_SHADOW_BIN_ENABLED) {
            // skip empty light indices; already
            if (light.block == -1) continue;
        }

        // get the range of the light from block metadata lookup
        float lightRange = ap.blocks[light.block].emission;

        float3 fragToLight = light.position - localSamplePos;

        // light depth is compared to longest depth along any axis
        float sampleDist = maxOf(abs(fragToLight));

        // skip if out-of-range for current sample
        if (sampleDist >= lightRange) continue;

        // get the color of the light from block metadata lookup
        float3 lightColor = ap.blocks[light.block].lightColor.rgb;
        lightColor = RgbToLinear(lightColor);

        float3 sampleDir = normalize(fragToLight);

        // apply shadowing from sample normal and shadow map
        float NoLm = max(dot(localNormal, sampleDir), 0.0);
        float lightShadow = shadowPoint_sampleShadow(pointLightFiltered, -sampleDir, sampleDist - offsetBias, lightIndex);
        lightShadow *= NoLm * getLightAttenuation(sampleDist, lightRange);

        // accumulate lighting additively
        accumLighting += lightShadow * lightColor;
    }

    return accumLighting;
}
