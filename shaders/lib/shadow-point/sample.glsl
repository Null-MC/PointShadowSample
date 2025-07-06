float getLightAttenuation(const in float lightDist, const in float lightRange) {
    // normalize and invert the distance factor
    float lightDistF = lightDist / lightRange;
    lightDistF = 1.0 - saturate(lightDistF);

    // square the result for a nicer looking falloff
    return lightDistF*lightDistF;
}

// returns a hardware-filtered point-light shadow map sample
float shadowPoint_sampleShadow(const in vec3 sampleDir, const in float sampleDist, const in uint lightIndex) {
    // convert sample distance to normalized depth value
    float sampleDepth = (sampleDist - ap.point.nearPlane) / (ap.point.farPlane - ap.point.nearPlane);

    // sample the cubemap with hardware-filtering enabled
    return texture(pointLightFiltered, vec4(sampleDir, lightIndex), sampleDepth).r;
}

vec3 shadowPoint_sampleAll(const in vec3 localPos, const in vec3 localNormal) {
    // adjust as-needed/to taste
    const float offsetBias = 0.02;
    const float normalBias = 0.16;

    // apply a normal-based offset to shadow sample position
    vec3 localSamplePos = localNormal * normalBias + localPos;

    // initialize accumulated lighting to zero
    vec3 accumLighting = vec3(0.0);

    for (uint i = 0u; i < POINT_SHADOW_MAX_COUNT; i++) {
        // get the point-light data and skip if block is undefined
        ap_PointLight light = iris_getPointLight(i);
        if (light.block == -1) continue;

        // get the range of the light from block metadata lookup
        float lightRange = iris_getEmission(light.block);

        vec3 fragToLight = light.pos - localSamplePos;
        float sampleDist = length(fragToLight);
        vec3 sampleDir = fragToLight / sampleDist;

        // skip if out-of-range for current sample
        if (sampleDist >= lightRange) continue;

        // get the color of the light from block metadata lookup
        vec3 lightColor = iris_getLightColor(light.block).rgb;
        lightColor = RgbToLinear(lightColor);

        // apply shadowing from sample normal and shadow map
        float NoLm = max(dot(localNormal, sampleDir), 0.0);
        float lightShadow = shadowPoint_sampleShadow(-sampleDir, sampleDist - offsetBias, i);
        lightShadow *= NoLm * getLightAttenuation(sampleDist, lightRange);

        // accumulate lighting additively
        accumLighting += lightShadow * lightColor;
    }

    return accumLighting;
}
